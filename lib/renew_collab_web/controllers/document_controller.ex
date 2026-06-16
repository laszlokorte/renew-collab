defmodule RenewCollabWeb.DocumentController do
  use RenewCollabWeb, :controller

  alias RenewCollab.ViewBox
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher

  action_fallback(RenewCollabWeb.FallbackController)

  def show(conn, %{"id" => id}) do
    case %Views.DocumentWithContent{
           document_id: id
         }
         |> Fetcher.fetch_as(conn.assigns.current_account) do
      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.json(%{message: "Not found"})
        |> halt()

      document ->
        render(conn, :show, document: document)
    end
  end

  def thumbnail(conn, %{"id" => id, "layer_id" => layer_id}) do
    import Phoenix.Component, only: [sigil_H: 2]

    case %Views.DocumentWithContent{
           document_id: id,
           root_layer_id: layer_id
         }
         |> Fetcher.fetch_as(conn.assigns.current_account) do
      nil ->
        assigns = %{}

        conn
        |> put_resp_content_type("image/svg+xml")
        |> send_resp(
          :not_found,
          ~H"""
          <svg xmlns="http://www.w3.org/2000/svg" width="200" height="200">
            <circle cx="100" cy="100" r="100" stroke="none" stroke-width="4" fill="red" />
          </svg>
          """
          |> Phoenix.HTML.Safe.to_iodata()
          |> IO.iodata_to_binary()
        )
        |> halt()

      document ->
        assigns = %{
          layer_id: layer_id,
          document: document,
          viewbox: RenewCollab.ViewBox.calculate(document)
        }

        svg = ~H"""
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width="200"
          height="200"
          viewBox={RenewCollab.ViewBox.into_string(RenewCollab.ViewBox.stretch(@viewbox))}
        >
          <%= with %ViewBox{x: x, y: y, width: width, height: height} <- @viewbox do %>
            <ellipse
              cx={x + width / 2}
              cy={y + height / 2}
              rx={width / 2}
              ry={height / 2}
              stroke="none"
              fill={
                if(@layer_id == :thumbnail,
                  do: if(@document.thumbnail, do: "green", else: "#eee"),
                  else: "orange"
                )
              }
            />
            <text
              font-size="100"
              x={x + width / 2}
              y={y + height / 2}
              text-anchor="middle"
              dominant-baseline="central"
            >
              <%= with %{layer_id: lid} <- @document.thumbnail, true <- @layer_id == :thumbnail do %>
                <tspan x={x + width / 2}>{@document.layers |> Enum.count()}</tspan>

                <tspan x={x + width / 2} dy="100">{lid}</tspan>
                <% else _ -> %>
                  ⊗
              <% end %>
            </text>
          <% end %>
        </svg>
        """

        conn
        |> put_resp_content_type("image/svg+xml")
        |> send_resp(200, svg |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary())
    end
  end

  def thumbnail(conn, %{"id" => id}) do
    thumbnail(conn, %{"id" => id, "layer_id" => :thumbnail})
  end

  def delete(conn, %{"id" => document_id}) do
    %Actions.DocumentDeleteAsUser{document_id: document_id}
    |> Dispatcher.perform_as(conn.assigns.current_account)

    conn
    |> put_status(:accepted)
    |> json(%{message: "ok"})
  end

  def duplicate(conn, %{"id" => document_id, "project_id" => project_id}) do
    %Actions.DocumentDuplicateInProject{document_id: document_id, project_id: project_id}
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      {:ok, new_document} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/documents/#{new_document}")
        |> json(%{id: new_document.id, url: ~p"/api/documents/#{new_document}"})
    end
  end

  def check(conn, %{"id" => id}) do
    case %Views.DocumentWithContent{
           document_id: id
         }
         |> Fetcher.fetch_as(conn.assigns.current_account) do
      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.json(%{message: "Not found"})
        |> halt()

      document ->
        issues = inscription_issues(document)

        conn
        |> json(%{
          ok: issues == [],
          issue_count: length(issues),
          issues: issues
        })
    end
  end

  def export(conn, %{"id" => id} = params) do
    case %Views.DocumentWithContent{
           document_id: id
         }
         |> Fetcher.fetch_as(conn.assigns.current_account) do
      nil ->
        conn
        |> put_status(:not_found)
        |> Phoenix.Controller.json(%{message: "Not found"})
        |> halt()

      document ->
        {:ok, output} =
          RenewCollab.Export.DocumentExport.export(document,
            synthetic:
              params
              |> Map.get("synthetic")
              |> case do
                "1" -> true
                _ -> false
              end
          )

        conn
        |> put_resp_header(
          "content-disposition",
          "#{if(Map.has_key?(params, "inline"), do: "inline", else: "attachment")}; filename=\"#{document.name |> String.trim_trailing(".rnw")}.rnw\""
        )
        |> put_resp_header(
          "content-type",
          "text/plain+renew"
        )
        |> text(output)
    end
  end

  defp inscription_issues(%{layers: layers}) when is_list(layers) do
    by_id = Map.new(layers, &{&1.id, &1})

    layers
    |> Enum.filter(&inscription_layer?/1)
    |> Enum.flat_map(&inscription_layer_issues(&1, by_id))
  end

  defp inscription_issues(_document), do: []

  defp inscription_layer?(%{text: %{renew_type: renew_type}, semantic_tag: tag}) do
    renew_type in [1, 3] or
      (is_nil(renew_type) and is_binary(tag) and String.ends_with?(tag, ".CPNTextFigure"))
  end

  defp inscription_layer?(_layer), do: false

  defp inscription_layer_issues(layer, by_id) do
    target = inscription_target(layer, by_id)

    cond do
      is_nil(target) ->
        [
          %{
            layer_id: layer.id,
            title: "Syntax Error",
            message: "Inscription is not connected to a net element.",
            detail:
              "Renew accepts inscriptions on places and arcs. Connect the inscription to a supported net element before simulating or exporting the drawing."
          }
        ]

      qualified_inscription_target?(target) ->
        []

      true ->
        [
          %{
            layer_id: layer.id,
            target_layer_id: target.id,
            title: "Syntax Error",
            message: "The connected figure cannot carry inscriptions.",
            detail:
              "Renew accepts inscriptions on places and arcs. Remove the inscription from this figure, or attach it to a supported net element."
          }
        ]
    end
  end

  defp inscription_target(%{outgoing_link: %{target_layer_id: target_layer_id}}, by_id)
       when is_binary(target_layer_id),
       do: Map.get(by_id, target_layer_id)

  defp inscription_target(%{direct_parent_hood: %{ancestor_id: target_layer_id}}, by_id)
       when is_binary(target_layer_id),
       do: Map.get(by_id, target_layer_id)

  defp inscription_target(_layer, _by_id), do: nil

  defp qualified_inscription_target?(%{edge: %Ecto.Association.NotLoaded{}}), do: false

  defp qualified_inscription_target?(%{edge: nil}), do: false

  defp qualified_inscription_target?(%{edge: _edge}), do: true

  defp qualified_inscription_target?(%{semantic_tag: tag}) when is_binary(tag) do
    String.ends_with?(tag, ".PlaceFigure") or String.ends_with?(tag, ".VirtualPlaceFigure")
  end

  defp qualified_inscription_target?(_layer), do: false

  def inspect(conn, %{"id" => id}) do
    %Views.DocumentStripped{
      document_id: id,
      original_ids: true
    }
    |> Fetcher.fetch_as(conn.assigns.current_account)
    |> case do
      document ->
        conn
        |> put_resp_header(
          "content-disposition",
          "inline; filename=\"#{document.content.name}.rnx\""
        )
        |> put_resp_header(
          "content-type",
          "text/plain"
        )
        |> text(Kernel.inspect(Map.from_struct(document), pretty: true, limit: :infinity))
    end
  end
end
