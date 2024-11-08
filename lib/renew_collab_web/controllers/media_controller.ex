defmodule RenewCollabWeb.MediaController do
  use RenewCollabWeb, :controller

  def show(conn, %{"id" => id}) do
    case RenewCollab.Media.get_svg(id) do
      nil -> conn |> put_status(:not_found) |> json(%{"message" => "not found"}) |> halt()
      svg -> conn |> put_resp_content_type("image/svg+xml") |> text(svg.xml)
    end
  end

  def create(conn, %{"svg" => svg}) do
    RenewCollab.Media.create_svg(svg)
    |> case do
      {:ok, svg} -> render(conn, :create, %{svg: svg})
    end
  end
end
