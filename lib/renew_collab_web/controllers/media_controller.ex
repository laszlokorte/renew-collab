defmodule RenewCollabWeb.MediaController do
  alias RenewCollabCtrl.Dispatcher
  alias RenewCollabCtrl.Actions
  alias RenewCollabCtrl.Fetcher
  alias RenewCollabCtrl.Views
  use RenewCollabWeb, :controller

  def show(conn, %{"id" => id}) do
    %Views.MediaData{media_id: id}
    |> Fetcher.fetch_as(nil)
    |> case do
      nil -> conn |> put_status(:not_found) |> json(%{"message" => "not found"}) |> halt()
      svg -> conn |> put_resp_content_type("image/svg+xml") |> text(svg.xml)
    end
  end

  def create(conn, %{"project_id" => project_id, "svg" => svg}) do
    %Actions.ProjectMediaCreateSvg{project_id: project_id, svg: svg}
    |> Dispatcher.perform_as(conn.assigns.current_account)
    |> case do
      {:ok, svg} -> render(conn, :create, %{svg: svg, project_id: project_id})
    end
  end
end
