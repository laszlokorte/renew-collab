defmodule RenewCollabWeb.ThumbnailController do
  use RenewCollabWeb, :controller

  alias RenewCollabWeb.ThumbnailSVG
  alias RenewCollabCtrl.Views
  alias RenewCollabCtrl.Fetcher

  action_fallback(RenewCollabWeb.FallbackController)

  def thumbnail(conn, %{"id" => id, "layer_id" => layer_id}) do
    case %Views.DocumentWithContent{
           document_id: id,
           root_layer_id: layer_id
         }
         |> Fetcher.fetch_as(conn.assigns.current_account) do
      nil ->
        conn
        |> put_resp_content_type("image/svg+xml")
        |> send_resp(
          :not_found,
          ThumbnailSVG.document(%{
            layer_id: nil,
            document: nil,
            viewbox: %RenewCollab.ViewBox{x: -100, y: -100, width: 200, height: 200}
          })
          |> Phoenix.HTML.Safe.to_iodata()
          |> IO.iodata_to_binary()
        )

      document ->
        conn
        |> put_resp_content_type("image/svg+xml")
        |> send_resp(
          200,
          ThumbnailSVG.document(%{
            layer_id: layer_id,
            document: document,
            viewbox: RenewCollab.ViewBox.calculate(document)
          })
          |> Phoenix.HTML.Safe.to_iodata()
          |> IO.iodata_to_binary()
        )
    end
  end

  def thumbnail(conn, %{"id" => id}) do
    thumbnail(conn, %{"id" => id, "layer_id" => :thumbnail})
  end
end
