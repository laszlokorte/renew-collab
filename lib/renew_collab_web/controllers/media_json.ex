defmodule RenewCollabWeb.MediaJSON do
  use RenewCollabWeb, :verified_routes

  def show(%{svg: svg}) do
    svg.xml
  end

  def create(%{svg: svg}) do
    %{
      "url" => url(~p"/api/media/svg/#{svg.id}")
    }
  end
end
