defmodule RenewCollabWeb.ShadowNetController do
  use RenewCollabWeb, :controller

  alias RenewCollabSim.Simulator

  action_fallback RenewCollabWeb.FallbackController

  def download(conn, %{"id" => id}) do
    content_type =
      with %{query_params: %{"text" => _}} <- conn do
        "text/plain"
      else
        _ -> "application/binary"
      end

    Simulator.find_shadow_net_system(id)
    |> case do
      sns ->
        conn
        |> put_resp_header(
          "content-disposition",
          "inline; filename=\"#{sns.id}.sns\""
        )
        |> put_resp_header(
          "content-type",
          content_type
        )
        |> send_resp(:ok, sns.compiled)
    end
  end
end
