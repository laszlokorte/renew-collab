defmodule RenewCollabWeb.ThumbnailController do
  use RenewCollabWeb, :controller

  alias RenewCollab.ViewBox
  alias RenewCollab.Renew
  alias RenewCollab.Document.Document
  alias RenewCollab.Import.DocumentImport
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Dispatcher

  action_fallback(RenewCollabWeb.FallbackController)

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
          viewBox={RenewCollab.ViewBox.into_string(@viewbox)}
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
                  do: if(@document.thumbnail, do: "green", else: "#ddd"),
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
end
