defmodule RenewCollabWeb.LayerJSON do
  alias RenewCollab.Hierarchy.Layer
  use RenewCollabWeb, :verified_routes

  @doc """
  Renders a list of element.
  """
  def index(%{elements: elements}) do
    %{
      data: for(element <- elements, do: list_data(element))
    }
  end

  @doc """
  Renders a single element.
  """
  def show(%{element: element}) do
    %{data: detail_data(element)}
  end

  defp detail_data(%Layer{} = element) do
    %{
      # id: element.id,
      document: %{
        href: url(~p"/api/documents/#{element.document_id}")
      },
      href: url(~p"/api/documents/#{element.document_id}/elements/#{element}"),
      z_index: element.z_index
    }
  end

  defp list_data(%Layer{} = element) do
    %{
      # id: element.id,
      href: url(~p"/api/documents/#{element.document_id}/elements/#{element}"),
      z_index: element.z_index
    }
  end
end
