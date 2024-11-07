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

  @doc """
  Generate a element_parenthood.
  """
  def element_parenthood_fixture(attrs \\ %{}) do
    {:ok, element_parenthood} =
      attrs
      |> Enum.into(%{
        depth: 42
      })
      |> RenewCollab.Renew.create_element_parenthood()

    element_parenthood
  end

  @doc """
  Generate a element_box.
  """
  def element_box_fixture(attrs \\ %{}) do
    {:ok, element_box} =
      attrs
      |> Enum.into(%{
        height: 120.5,
        width: 120.5
      })
      |> RenewCollab.Renew.create_element_box()

    element_box
  end

  @doc """
  Generate a element_text.
  """
  def element_text_fixture(attrs \\ %{}) do
    {:ok, element_text} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> RenewCollab.Renew.create_element_text()

    element_text
  end

  @doc """
  Generate a element_connection.
  """
  def element_connection_fixture(attrs \\ %{}) do
    {:ok, element_connection} =
      attrs
      |> Enum.into(%{
        source_x: 120.5,
        source_y: 120.5,
        target_x: 120.5,
        target_y: 120.5
      })
      |> RenewCollab.Renew.create_element_connection()

    element_connection
  end

  @doc """
  Generate a element_socket.
  """
  def element_socket_fixture(attrs \\ %{}) do
    {:ok, element_socket} =
      attrs
      |> Enum.into(%{
        kind: "some kind",
        name: "some name"
      })
      |> RenewCollab.Renew.create_element_socket()

    element_socket
  end

  @doc """
  Generate a element_connection_waypoint.
  """
  def element_connection_waypoint_fixture(attrs \\ %{}) do
    {:ok, element_connection_waypoint} =
      attrs
      |> Enum.into(%{
        position_x: 120.5,
        position_y: 120.5,
        sort: 42
      })
      |> RenewCollab.Renew.create_element_connection_waypoint()

    element_connection_waypoint
  end

  @doc """
  Generate a element_connection_source_bond.
  """
  def element_connection_source_bond_fixture(attrs \\ %{}) do
    {:ok, element_connection_source_bond} =
      attrs
      |> Enum.into(%{})
      |> RenewCollab.Renew.create_element_connection_source_bond()

    element_connection_source_bond
  end

  @doc """
  Generate a element_connection_target_bond.
  """
  def element_connection_target_bond_fixture(attrs \\ %{}) do
    {:ok, element_connection_target_bond} =
      attrs
      |> Enum.into(%{})
      |> RenewCollab.Renew.create_element_connection_target_bond()

    element_connection_target_bond
  end

  @doc """
  Generate a element_style.
  """
  def element_style_fixture(attrs \\ %{}) do
    {:ok, element_style} =
      attrs
      |> Enum.into(%{
        background_color: "some background_color",
        border_color: "some border_color",
        border_width: "some border_width",
        border_width: "some border_width",
        opacity: 120.5
      })
      |> RenewCollab.Renew.create_element_style()

    element_style
  end

  @doc """
  Generate a element_connection_style.
  """
  def element_connection_style_fixture(attrs \\ %{}) do
    {:ok, element_connection_style} =
      attrs
      |> Enum.into(%{
        smoothness: "some smoothness",
        stroke_cap: "some stroke_cap",
        stroke_color: "some stroke_color",
        stroke_dash_array: "some stroke_dash_array",
        stroke_joint: "some stroke_joint",
        stroke_width: "some stroke_width"
      })
      |> RenewCollab.Renew.create_element_connection_style()

    element_connection_style
  end

  @doc """
  Generate a element_text_style.
  """
  def element_text_style_fixture(attrs \\ %{}) do
    {:ok, element_text_style} =
      attrs
      |> Enum.into(%{
        alignment: :left,
        bold: true,
        font_family: "some font_family",
        font_size: 120.5,
        italic: true,
        italic: true,
        text_color: "some text_color",
        underline: true
      })
      |> RenewCollab.Renew.create_element_text_style()

    element_text_style
  end
end
