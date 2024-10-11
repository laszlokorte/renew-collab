defmodule RenewCollabWeb.DocumentJSON do
  alias RenewCollab.ViewBox
  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Waypoint

  use RenewCollabWeb, :verified_routes

  @doc """
  Renders a list of document.
  """
  def index(%{documents: documents}) do
    %{
      href: url(~p"/api/documents"),
      topic: "redux_documents",
      content: index_content(%{documents: documents})
    }
  end

  def index_content(%{documents: documents}) do
    %{
      items: for(document <- documents, do: list_data(document))
    }
  end

  @doc """
  Renders a single document.
  """
  def show(%{document: document}) do
    detail_data(document)
  end

  @doc """
  Renders a single document.
  """
  def import(%{document: document}) do
    list_data(document)
  end

  defp list_data(%Document{} = document) do
    %{
      # id: document.id,
      href: url(~p"/api/documents/#{document}"),
      name: document.name,
      kind: document.kind,
      id: document.id,
      links: %{
        export: %{
          href: url(~p"/api/documents/#{document.id}/export")
        }
      }
    }
  end

  def show_content(%Document{} = document) do
    %{
      name: document.name,
      kind: document.kind,
      viewbox: viewbox_data(RenewCollab.ViewBox.calculate(document)),
      layers:
        case document.layers do
          %Ecto.Association.NotLoaded{} -> %{}
          _ -> %{items: document.layers |> Enum.map(&layer_data(&1))}
        end
    }
  end

  def viewbox_data(%ViewBox{x: x, y: y, width: width, height: heiht}) do
    %{x: x, y: y, width: width, height: heiht}
  end

  defp detail_data(%Document{} = document) do
    %{
      # id: document.id,
      href: url(~p"/api/documents/#{document}"),
      topic: "redux_document:#{document.id}",
      id: document.id,
      content: show_content(document)
    }
  end

  def layer_data(%Layer{} = layer) do
    %{
      # id: layer.id,
      id: layer.id,
      semantic_tag: layer.semantic_tag,
      z_index: layer.z_index,
      hidden: layer.hidden,
      parent_id:
        case layer.direct_parent do
          nil -> nil
          p -> p.ancestor_id
        end,
      text:
        case layer.text do
          nil ->
            nil

          %Ecto.Association.NotLoaded{} ->
            nil

          v ->
            %{
              "position_x" => v.position_x,
              "position_y" => v.position_y,
              "body" => v.body,
              "style" =>
                case v.style do
                  nil ->
                    nil

                  %Ecto.Association.NotLoaded{} ->
                    nil

                  v ->
                    %{
                      "italic" => v.italic,
                      "underline" => v.underline,
                      "alignment" => v.alignment,
                      "font_size" => v.font_size,
                      "font_family" => v.font_family,
                      "bold" => v.bold,
                      "text_color" => v.text_color
                    }
                end
            }
        end,
      box:
        case layer.box do
          nil ->
            nil

          %Ecto.Association.NotLoaded{} ->
            nil

          v ->
            %{
              "position_x" => v.position_x,
              "position_y" => v.position_y,
              "width" => v.width,
              "height" => v.height,
              "shape_attributes" => v.symbol_shape_attributes,
              "shape" =>
                case v.symbol_shape do
                  nil -> nil
                  symbol -> symbol.name
                end
            }
        end,
      edge:
        case layer.edge do
          nil ->
            nil

          %Ecto.Association.NotLoaded{} ->
            nil

          v ->
            %{
              "source_x" => v.source_x,
              "source_y" => v.source_y,
              "target_x" => v.target_x,
              "target_y" => v.target_y,
              "source_bond" => bond_data(v.source_bond),
              "target_bond" => bond_data(v.target_bond),
              "cyclic" => v.cyclic,
              "waypoints" =>
                case v.waypoints do
                  [_ | _] = w ->
                    w
                    |> Enum.map(fn
                      %Waypoint{position_x: x, position_y: y} ->
                        %{"x" => x, "y" => y}
                    end)

                  nil ->
                    []

                  %Ecto.Association.NotLoaded{} ->
                    []

                  [] ->
                    []

                  _ ->
                    []
                end,
              "style" =>
                case v.style do
                  nil ->
                    nil

                  %Ecto.Association.NotLoaded{} ->
                    nil

                  v ->
                    %{
                      "stroke_width" => v.stroke_width,
                      "stroke_color" => v.stroke_color,
                      "stroke_join" => v.stroke_join,
                      "stroke_cap" => v.stroke_cap,
                      "stroke_dash_array" => v.stroke_dash_array,
                      "source_tip" => v.source_tip,
                      "target_tip" => v.target_tip,
                      "smoothness" => v.smoothness
                    }
                end
            }
        end,
      style:
        case layer.style do
          nil ->
            nil

          %Ecto.Association.NotLoaded{} ->
            nil

          v ->
            %{
              "opacity" => v.opacity,
              "background_color" => v.background_color,
              "border_color" => v.border_color,
              "border_width" => v.border_width,
              "border_dash_array" => v.border_dash_array
            }
        end
    }
  end

  def bond_data(bond) do
    case bond do
      nil ->
        nil

      %Ecto.Association.NotLoaded{} ->
        nil

      %RenewCollab.Connection.Bond{
        socket_id: socket_id,
        layer_id: layer_id
      } ->
        %{
          socket_id: socket_id,
          layer_id: layer_id
        }
    end
  end
end
