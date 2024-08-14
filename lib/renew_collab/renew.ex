defmodule RenewCollab.Renew do
  @moduledoc """
  The Renew context.
  """

  import Ecto.Query, warn: false
  alias RenewCollab.Repo

  alias RenewCollab.Document.Document
  alias RenewCollab.Element.Element
  alias RenewCollab.Connection.ElementConnectionWaypoint
  alias RenewCollab.Hierarchy.ElementParenthood

  @doc """
  Returns the list of document.

  ## Examples

      iex> list_documents()
      [%Document{}, ...]

  """
  def list_documents do
    Repo.all(Document)
  end

  @doc """
  Gets a single document.

  Raises `Ecto.NoResultsError` if the Document does not exist.

  ## Examples

      iex> get_document!(123)
      %Document{}

      iex> get_document!(456)
      ** (Ecto.NoResultsError)

  """
  def get_document!(id), do: Repo.get!(Document, id)

  def get_document_with_elements!(id),
    do:
      Repo.get!(Document, id)
      |> Repo.preload(
        elements:
          from(e in Element,
            order_by: [asc: :z_index],
            preload: [
              box: [],
              text: [style: []],
              connection: [
                waypoints: ^from(w in ElementConnectionWaypoint, order_by: [asc: :sort]),
                style: []
              ],
              style: [],
              sockets: []
            ]
          )
      )

  @doc """
  Creates a document.

  ## Examples

      iex> create_document(%{field: value})
      {:ok, %Document{}}

      iex> create_document(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_document(attrs \\ %{}) do
    %Document{elements: []}
    |> Document.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a document.

  ## Examples

      iex> update_document(document, %{field: new_value})
      {:ok, %Document{}}

      iex> update_document(document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_document(%Document{} = document, attrs) do
    document
    |> Document.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a document.

  ## Examples

      iex> delete_document(document)
      {:ok, %Document{}}

      iex> delete_document(document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_document(%Document{} = document) do
    Repo.delete(document)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking document changes.

  ## Examples

      iex> change_document(document)
      %Ecto.Changeset{data: %Document{}}

  """
  def change_document(%Document{} = document, attrs \\ %{}) do
    Document.changeset(document, attrs)
  end

  alias RenewCollab.Element.Element

  @doc """
  Returns the list of element.

  ## Examples

      iex> list_elements()
      [%Element{}, ...]

  """
  def list_elements(%Document{} = document) do
    Repo.all(from e in Element, where: e.document_id == ^document.id)
  end

  @doc """
  Gets a single element.

  Raises `Ecto.NoResultsError` if the Element does not exist.

  ## Examples

      iex> get_element!(123)
      %Element{}

      iex> get_element!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element!(%Document{} = document, id),
    do: Repo.one!(from e in Element, where: e.document_id == ^document.id, where: e.id == ^id)

  @doc """
  Creates a element.

  ## Examples

      iex> create_element(%{field: value})
      {:ok, %Element{}}

      iex> create_element(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element(%Document{} = document, attrs \\ %{}) do
    {:ok, %{insert_element: element}} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(
        :insert_element,
        Element.changeset(%Element{document_id: document.id}, attrs)
      )
      |> Ecto.Multi.insert(
        :insert_parenthood,
        fn %{insert_element: new_element} ->
          ElementParenthood.changeset(%ElementParenthood{}, %{
            depth: 0,
            document_id: new_element.document_id,
            ancestor_id: new_element.id,
            descendant_id: new_element.id
          })
        end
      )
      |> Repo.transaction()

    {:ok, element}
  end

  @doc """
  Updates a element.

  ## Examples

      iex> update_element(element, %{field: new_value})
      {:ok, %Element{}}

      iex> update_element(element, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element(%Element{} = element, attrs) do
    element
    |> Element.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element.

  ## Examples

      iex> delete_element(element)
      {:ok, %Element{}}

      iex> delete_element(element)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element(%Element{} = element) do
    Repo.delete(element)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element changes.

  ## Examples

      iex> change_element(element)
      %Ecto.Changeset{data: %Element{}}

  """
  def change_element(%Element{} = element, attrs \\ %{}) do
    Element.changeset(element, attrs)
  end

  alias RenewCollab.Hierarchy.ElementParenthood

  @doc """
  Returns the list of element_parenthood.

  ## Examples

      iex> list_element_parenthood()
      [%ElementParenthood{}, ...]

  """
  def list_element_parenthood do
    Repo.all(ElementParenthood)
  end

  @doc """
  Gets a single element_parenthood.

  Raises `Ecto.NoResultsError` if the Element parenthood does not exist.

  ## Examples

      iex> get_element_parenthood!(123)
      %ElementParenthood{}

      iex> get_element_parenthood!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_parenthood!(id), do: Repo.get!(ElementParenthood, id)

  @doc """
  Creates a element_parenthood.

  ## Examples

      iex> create_element_parenthood(%{field: value})
      {:ok, %ElementParenthood{}}

      iex> create_element_parenthood(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_parenthood(attrs \\ %{}) do
    %ElementParenthood{}
    |> ElementParenthood.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_parenthood.

  ## Examples

      iex> update_element_parenthood(element_parenthood, %{field: new_value})
      {:ok, %ElementParenthood{}}

      iex> update_element_parenthood(element_parenthood, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_parenthood(%ElementParenthood{} = element_parenthood, attrs) do
    element_parenthood
    |> ElementParenthood.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_parenthood.

  ## Examples

      iex> delete_element_parenthood(element_parenthood)
      {:ok, %ElementParenthood{}}

      iex> delete_element_parenthood(element_parenthood)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_parenthood(%ElementParenthood{} = element_parenthood) do
    Repo.delete(element_parenthood)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_parenthood changes.

  ## Examples

      iex> change_element_parenthood(element_parenthood)
      %Ecto.Changeset{data: %ElementParenthood{}}

  """
  def change_element_parenthood(%ElementParenthood{} = element_parenthood, attrs \\ %{}) do
    ElementParenthood.changeset(element_parenthood, attrs)
  end

  alias RenewCollab.Element.ElementBox

  @doc """
  Returns the list of element_box.

  ## Examples

      iex> list_element_box()
      [%ElementBox{}, ...]

  """
  def list_element_box do
    Repo.all(ElementBox)
  end

  @doc """
  Gets a single element_box.

  Raises `Ecto.NoResultsError` if the Element box does not exist.

  ## Examples

      iex> get_element_box!(123)
      %ElementBox{}

      iex> get_element_box!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_box!(id), do: Repo.get!(ElementBox, id)

  @doc """
  Creates a element_box.

  ## Examples

      iex> create_element_box(%{field: value})
      {:ok, %ElementBox{}}

      iex> create_element_box(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_box(attrs \\ %{}) do
    %ElementBox{}
    |> ElementBox.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_box.

  ## Examples

      iex> update_element_box(element_box, %{field: new_value})
      {:ok, %ElementBox{}}

      iex> update_element_box(element_box, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_box(%ElementBox{} = element_box, attrs) do
    element_box
    |> ElementBox.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_box.

  ## Examples

      iex> delete_element_box(element_box)
      {:ok, %ElementBox{}}

      iex> delete_element_box(element_box)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_box(%ElementBox{} = element_box) do
    Repo.delete(element_box)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_box changes.

  ## Examples

      iex> change_element_box(element_box)
      %Ecto.Changeset{data: %ElementBox{}}

  """
  def change_element_box(%ElementBox{} = element_box, attrs \\ %{}) do
    ElementBox.changeset(element_box, attrs)
  end

  alias RenewCollab.Element.ElementText

  @doc """
  Returns the list of element_text.

  ## Examples

      iex> list_element_text()
      [%ElementText{}, ...]

  """
  def list_element_text do
    Repo.all(ElementText)
  end

  @doc """
  Gets a single element_text.

  Raises `Ecto.NoResultsError` if the Element text does not exist.

  ## Examples

      iex> get_element_text!(123)
      %ElementText{}

      iex> get_element_text!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_text!(id), do: Repo.get!(ElementText, id)

  @doc """
  Creates a element_text.

  ## Examples

      iex> create_element_text(%{field: value})
      {:ok, %ElementText{}}

      iex> create_element_text(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_text(attrs \\ %{}) do
    %ElementText{}
    |> ElementText.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_text.

  ## Examples

      iex> update_element_text(element_text, %{field: new_value})
      {:ok, %ElementText{}}

      iex> update_element_text(element_text, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_text(%ElementText{} = element_text, attrs) do
    element_text
    |> ElementText.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_text.

  ## Examples

      iex> delete_element_text(element_text)
      {:ok, %ElementText{}}

      iex> delete_element_text(element_text)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_text(%ElementText{} = element_text) do
    Repo.delete(element_text)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_text changes.

  ## Examples

      iex> change_element_text(element_text)
      %Ecto.Changeset{data: %ElementText{}}

  """
  def change_element_text(%ElementText{} = element_text, attrs \\ %{}) do
    ElementText.changeset(element_text, attrs)
  end

  alias RenewCollab.Connection.ElementConnection

  @doc """
  Returns the list of element_connection.

  ## Examples

      iex> list_element_connection()
      [%ElementConnection{}, ...]

  """
  def list_element_connection do
    Repo.all(ElementConnection)
  end

  @doc """
  Gets a single element_connection.

  Raises `Ecto.NoResultsError` if the Element connection does not exist.

  ## Examples

      iex> get_element_connection!(123)
      %ElementConnection{}

      iex> get_element_connection!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_connection!(id), do: Repo.get!(ElementConnection, id)

  @doc """
  Creates a element_connection.

  ## Examples

      iex> create_element_connection(%{field: value})
      {:ok, %ElementConnection{}}

      iex> create_element_connection(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_connection(attrs \\ %{}) do
    %ElementConnection{}
    |> ElementConnection.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_connection.

  ## Examples

      iex> update_element_connection(element_connection, %{field: new_value})
      {:ok, %ElementConnection{}}

      iex> update_element_connection(element_connection, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_connection(%ElementConnection{} = element_connection, attrs) do
    element_connection
    |> ElementConnection.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_connection.

  ## Examples

      iex> delete_element_connection(element_connection)
      {:ok, %ElementConnection{}}

      iex> delete_element_connection(element_connection)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_connection(%ElementConnection{} = element_connection) do
    Repo.delete(element_connection)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_connection changes.

  ## Examples

      iex> change_element_connection(element_connection)
      %Ecto.Changeset{data: %ElementConnection{}}

  """
  def change_element_connection(%ElementConnection{} = element_connection, attrs \\ %{}) do
    ElementConnection.changeset(element_connection, attrs)
  end

  alias RenewCollab.Element.ElementSocket

  @doc """
  Returns the list of element_socket.

  ## Examples

      iex> list_element_socket()
      [%ElementSocket{}, ...]

  """
  def list_element_socket do
    Repo.all(ElementSocket)
  end

  @doc """
  Gets a single element_socket.

  Raises `Ecto.NoResultsError` if the Element socket does not exist.

  ## Examples

      iex> get_element_socket!(123)
      %ElementSocket{}

      iex> get_element_socket!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_socket!(id), do: Repo.get!(ElementSocket, id)

  @doc """
  Creates a element_socket.

  ## Examples

      iex> create_element_socket(%{field: value})
      {:ok, %ElementSocket{}}

      iex> create_element_socket(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_socket(attrs \\ %{}) do
    %ElementSocket{}
    |> ElementSocket.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_socket.

  ## Examples

      iex> update_element_socket(element_socket, %{field: new_value})
      {:ok, %ElementSocket{}}

      iex> update_element_socket(element_socket, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_socket(%ElementSocket{} = element_socket, attrs) do
    element_socket
    |> ElementSocket.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_socket.

  ## Examples

      iex> delete_element_socket(element_socket)
      {:ok, %ElementSocket{}}

      iex> delete_element_socket(element_socket)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_socket(%ElementSocket{} = element_socket) do
    Repo.delete(element_socket)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_socket changes.

  ## Examples

      iex> change_element_socket(element_socket)
      %Ecto.Changeset{data: %ElementSocket{}}

  """
  def change_element_socket(%ElementSocket{} = element_socket, attrs \\ %{}) do
    ElementSocket.changeset(element_socket, attrs)
  end

  alias RenewCollab.Connection.ElementConnectionWaypoint

  @doc """
  Returns the list of element_connection_waypoint.

  ## Examples

      iex> list_element_connection_waypoint()
      [%ElementConnectionWaypoint{}, ...]

  """
  def list_element_connection_waypoint do
    Repo.all(ElementConnectionWaypoint)
  end

  @doc """
  Gets a single element_connection_waypoint.

  Raises `Ecto.NoResultsError` if the Element connection waypoint does not exist.

  ## Examples

      iex> get_element_connection_waypoint!(123)
      %ElementConnectionWaypoint{}

      iex> get_element_connection_waypoint!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_connection_waypoint!(id), do: Repo.get!(ElementConnectionWaypoint, id)

  @doc """
  Creates a element_connection_waypoint.

  ## Examples

      iex> create_element_connection_waypoint(%{field: value})
      {:ok, %ElementConnectionWaypoint{}}

      iex> create_element_connection_waypoint(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_connection_waypoint(attrs \\ %{}) do
    %ElementConnectionWaypoint{}
    |> ElementConnectionWaypoint.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_connection_waypoint.

  ## Examples

      iex> update_element_connection_waypoint(element_connection_waypoint, %{field: new_value})
      {:ok, %ElementConnectionWaypoint{}}

      iex> update_element_connection_waypoint(element_connection_waypoint, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_connection_waypoint(
        %ElementConnectionWaypoint{} = element_connection_waypoint,
        attrs
      ) do
    element_connection_waypoint
    |> ElementConnectionWaypoint.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_connection_waypoint.

  ## Examples

      iex> delete_element_connection_waypoint(element_connection_waypoint)
      {:ok, %ElementConnectionWaypoint{}}

      iex> delete_element_connection_waypoint(element_connection_waypoint)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_connection_waypoint(
        %ElementConnectionWaypoint{} = element_connection_waypoint
      ) do
    Repo.delete(element_connection_waypoint)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_connection_waypoint changes.

  ## Examples

      iex> change_element_connection_waypoint(element_connection_waypoint)
      %Ecto.Changeset{data: %ElementConnectionWaypoint{}}

  """
  def change_element_connection_waypoint(
        %ElementConnectionWaypoint{} = element_connection_waypoint,
        attrs \\ %{}
      ) do
    ElementConnectionWaypoint.changeset(element_connection_waypoint, attrs)
  end

  alias RenewCollab.Connection.ElementConnectionSourceBond

  @doc """
  Returns the list of element_connection_source_bond.

  ## Examples

      iex> list_element_connection_source_bond()
      [%ElementConnectionSourceBond{}, ...]

  """
  def list_element_connection_source_bond do
    Repo.all(ElementConnectionSourceBond)
  end

  @doc """
  Gets a single element_connection_source_bond.

  Raises `Ecto.NoResultsError` if the Element connection source bond does not exist.

  ## Examples

      iex> get_element_connection_source_bond!(123)
      %ElementConnectionSourceBond{}

      iex> get_element_connection_source_bond!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_connection_source_bond!(id), do: Repo.get!(ElementConnectionSourceBond, id)

  @doc """
  Creates a element_connection_source_bond.

  ## Examples

      iex> create_element_connection_source_bond(%{field: value})
      {:ok, %ElementConnectionSourceBond{}}

      iex> create_element_connection_source_bond(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_connection_source_bond(attrs \\ %{}) do
    %ElementConnectionSourceBond{}
    |> ElementConnectionSourceBond.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_connection_source_bond.

  ## Examples

      iex> update_element_connection_source_bond(element_connection_source_bond, %{field: new_value})
      {:ok, %ElementConnectionSourceBond{}}

      iex> update_element_connection_source_bond(element_connection_source_bond, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_connection_source_bond(
        %ElementConnectionSourceBond{} = element_connection_source_bond,
        attrs
      ) do
    element_connection_source_bond
    |> ElementConnectionSourceBond.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_connection_source_bond.

  ## Examples

      iex> delete_element_connection_source_bond(element_connection_source_bond)
      {:ok, %ElementConnectionSourceBond{}}

      iex> delete_element_connection_source_bond(element_connection_source_bond)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_connection_source_bond(
        %ElementConnectionSourceBond{} = element_connection_source_bond
      ) do
    Repo.delete(element_connection_source_bond)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_connection_source_bond changes.

  ## Examples

      iex> change_element_connection_source_bond(element_connection_source_bond)
      %Ecto.Changeset{data: %ElementConnectionSourceBond{}}

  """
  def change_element_connection_source_bond(
        %ElementConnectionSourceBond{} = element_connection_source_bond,
        attrs \\ %{}
      ) do
    ElementConnectionSourceBond.changeset(element_connection_source_bond, attrs)
  end

  alias RenewCollab.Connection.ElementConnectionTargetBond

  @doc """
  Returns the list of element_connection_target_bond.

  ## Examples

      iex> list_element_connection_target_bond()
      [%ElementConnectionTargetBond{}, ...]

  """
  def list_element_connection_target_bond do
    Repo.all(ElementConnectionTargetBond)
  end

  @doc """
  Gets a single element_connection_target_bond.

  Raises `Ecto.NoResultsError` if the Element connection target bond does not exist.

  ## Examples

      iex> get_element_connection_target_bond!(123)
      %ElementConnectionTargetBond{}

      iex> get_element_connection_target_bond!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_connection_target_bond!(id), do: Repo.get!(ElementConnectionTargetBond, id)

  @doc """
  Creates a element_connection_target_bond.

  ## Examples

      iex> create_element_connection_target_bond(%{field: value})
      {:ok, %ElementConnectionTargetBond{}}

      iex> create_element_connection_target_bond(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_connection_target_bond(attrs \\ %{}) do
    %ElementConnectionTargetBond{}
    |> ElementConnectionTargetBond.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_connection_target_bond.

  ## Examples

      iex> update_element_connection_target_bond(element_connection_target_bond, %{field: new_value})
      {:ok, %ElementConnectionTargetBond{}}

      iex> update_element_connection_target_bond(element_connection_target_bond, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_connection_target_bond(
        %ElementConnectionTargetBond{} = element_connection_target_bond,
        attrs
      ) do
    element_connection_target_bond
    |> ElementConnectionTargetBond.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_connection_target_bond.

  ## Examples

      iex> delete_element_connection_target_bond(element_connection_target_bond)
      {:ok, %ElementConnectionTargetBond{}}

      iex> delete_element_connection_target_bond(element_connection_target_bond)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_connection_target_bond(
        %ElementConnectionTargetBond{} = element_connection_target_bond
      ) do
    Repo.delete(element_connection_target_bond)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_connection_target_bond changes.

  ## Examples

      iex> change_element_connection_target_bond(element_connection_target_bond)
      %Ecto.Changeset{data: %ElementConnectionTargetBond{}}

  """
  def change_element_connection_target_bond(
        %ElementConnectionTargetBond{} = element_connection_target_bond,
        attrs \\ %{}
      ) do
    ElementConnectionTargetBond.changeset(element_connection_target_bond, attrs)
  end

  alias RenewCollab.Style.ElementStyle

  @doc """
  Returns the list of element_style.

  ## Examples

      iex> list_element_style()
      [%ElementStyle{}, ...]

  """
  def list_element_style do
    Repo.all(ElementStyle)
  end

  @doc """
  Gets a single element_style.

  Raises `Ecto.NoResultsError` if the Element style does not exist.

  ## Examples

      iex> get_element_style!(123)
      %ElementStyle{}

      iex> get_element_style!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_style!(id), do: Repo.get!(ElementStyle, id)

  @doc """
  Creates a element_style.

  ## Examples

      iex> create_element_style(%{field: value})
      {:ok, %ElementStyle{}}

      iex> create_element_style(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_style(attrs \\ %{}) do
    %ElementStyle{}
    |> ElementStyle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_style.

  ## Examples

      iex> update_element_style(element_style, %{field: new_value})
      {:ok, %ElementStyle{}}

      iex> update_element_style(element_style, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_style(%ElementStyle{} = element_style, attrs) do
    element_style
    |> ElementStyle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_style.

  ## Examples

      iex> delete_element_style(element_style)
      {:ok, %ElementStyle{}}

      iex> delete_element_style(element_style)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_style(%ElementStyle{} = element_style) do
    Repo.delete(element_style)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_style changes.

  ## Examples

      iex> change_element_style(element_style)
      %Ecto.Changeset{data: %ElementStyle{}}

  """
  def change_element_style(%ElementStyle{} = element_style, attrs \\ %{}) do
    ElementStyle.changeset(element_style, attrs)
  end

  alias RenewCollab.Style.ElementConnectionStyle

  @doc """
  Returns the list of element_connection_style.

  ## Examples

      iex> list_element_connection_style()
      [%ElementConnectionStyle{}, ...]

  """
  def list_element_connection_style do
    Repo.all(ElementConnectionStyle)
  end

  @doc """
  Gets a single element_connection_style.

  Raises `Ecto.NoResultsError` if the Element connection style does not exist.

  ## Examples

      iex> get_element_connection_style!(123)
      %ElementConnectionStyle{}

      iex> get_element_connection_style!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_connection_style!(id), do: Repo.get!(ElementConnectionStyle, id)

  @doc """
  Creates a element_connection_style.

  ## Examples

      iex> create_element_connection_style(%{field: value})
      {:ok, %ElementConnectionStyle{}}

      iex> create_element_connection_style(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_connection_style(attrs \\ %{}) do
    %ElementConnectionStyle{}
    |> ElementConnectionStyle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_connection_style.

  ## Examples

      iex> update_element_connection_style(element_connection_style, %{field: new_value})
      {:ok, %ElementConnectionStyle{}}

      iex> update_element_connection_style(element_connection_style, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_connection_style(%ElementConnectionStyle{} = element_connection_style, attrs) do
    element_connection_style
    |> ElementConnectionStyle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_connection_style.

  ## Examples

      iex> delete_element_connection_style(element_connection_style)
      {:ok, %ElementConnectionStyle{}}

      iex> delete_element_connection_style(element_connection_style)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_connection_style(%ElementConnectionStyle{} = element_connection_style) do
    Repo.delete(element_connection_style)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_connection_style changes.

  ## Examples

      iex> change_element_connection_style(element_connection_style)
      %Ecto.Changeset{data: %ElementConnectionStyle{}}

  """
  def change_element_connection_style(
        %ElementConnectionStyle{} = element_connection_style,
        attrs \\ %{}
      ) do
    ElementConnectionStyle.changeset(element_connection_style, attrs)
  end

  alias RenewCollab.Style.ElementTextStyle

  @doc """
  Returns the list of element_text_style.

  ## Examples

      iex> list_element_text_style()
      [%ElementTextStyle{}, ...]

  """
  def list_element_text_style do
    Repo.all(ElementTextStyle)
  end

  @doc """
  Gets a single element_text_style.

  Raises `Ecto.NoResultsError` if the Element text style does not exist.

  ## Examples

      iex> get_element_text_style!(123)
      %ElementTextStyle{}

      iex> get_element_text_style!(456)
      ** (Ecto.NoResultsError)

  """
  def get_element_text_style!(id), do: Repo.get!(ElementTextStyle, id)

  @doc """
  Creates a element_text_style.

  ## Examples

      iex> create_element_text_style(%{field: value})
      {:ok, %ElementTextStyle{}}

      iex> create_element_text_style(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_element_text_style(attrs \\ %{}) do
    %ElementTextStyle{}
    |> ElementTextStyle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a element_text_style.

  ## Examples

      iex> update_element_text_style(element_text_style, %{field: new_value})
      {:ok, %ElementTextStyle{}}

      iex> update_element_text_style(element_text_style, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_element_text_style(%ElementTextStyle{} = element_text_style, attrs) do
    element_text_style
    |> ElementTextStyle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a element_text_style.

  ## Examples

      iex> delete_element_text_style(element_text_style)
      {:ok, %ElementTextStyle{}}

      iex> delete_element_text_style(element_text_style)
      {:error, %Ecto.Changeset{}}

  """
  def delete_element_text_style(%ElementTextStyle{} = element_text_style) do
    Repo.delete(element_text_style)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking element_text_style changes.

  ## Examples

      iex> change_element_text_style(element_text_style)
      %Ecto.Changeset{data: %ElementTextStyle{}}

  """
  def change_element_text_style(%ElementTextStyle{} = element_text_style, attrs \\ %{}) do
    ElementTextStyle.changeset(element_text_style, attrs)
  end
end
