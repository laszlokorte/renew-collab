defmodule RenewCollab.RenewFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RenewCollab.Renew` context.
  """

  @doc """
  Generate a document.
  """
  def document_fixture(attrs \\ %{}) do
    {:ok, document} =
      attrs
      |> Enum.into(%{
        kind: "some kind",
        name: "some name"
      })
      |> RenewCollab.Renew.create_document()

    document
  end

  @doc """
  Generate a element.
  """
  def element_fixture(attrs \\ %{}) do
    {:ok, element} =
      attrs
      |> Enum.into(%{
        position_x: 120.5,
        position_y: 120.5,
        z_index: 42
      })
      |> RenewCollab.Renew.create_element()

    element
  end
end
