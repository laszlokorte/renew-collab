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

  def duplicate(conn, %{"id" => document_id}) do
    %Actions.DocumentDuplicateInProject{document_id: document_id}
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      {:ok, %{insert_document: new_document}} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/documents/#{new_document}")
        |> json(%{id: new_document.id, url: ~p"/api/documents/#{new_document}"})
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
        {:ok, output} = RenewCollab.Export.DocumentExport.export(document, synthetic: true)

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
