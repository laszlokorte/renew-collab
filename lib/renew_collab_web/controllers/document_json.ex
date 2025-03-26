defmodule RenewCollabWeb.DocumentJSON do
  alias RenewCollab.ViewBox
  alias RenewCollab.Document.Document
  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Connection.Waypoint
  alias RenewCollab.Versioning.Snapshot

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
  def import(%{imported: documents}) do
    %{
      items: for(document <- documents, do: list_data(document))
    }
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
      snapshot: snapshot_data(document),
      layers:
        case document.layers do
          %Ecto.Association.NotLoaded{} -> %{}
          _ -> %{items: document.layers |> Enum.map(&layer_data(&1))}
        end
    }
  end

  defp viewbox_data(%ViewBox{x: x, y: y, width: width, height: heiht}) do
    %{x: x, y: y, width: width, height: heiht}
  end

  defp snapshot_data(%Document{
         current_snaptshot: %Snapshot{
           id: id,
           predecessor: %Snapshot{id: prev_id},
           successors: successors
         }
       }) do
    %{current_id: id, prev_id: prev_id, next_ids: successors |> Enum.map(& &1.id)}
  end

  defp snapshot_data(%Document{}) do
    %{current_id: nil, prev_id: nil, next_ids: []}
  end

  defp detail_data(%Document{} = document) do
    %{
      # id: document.id,
      href: url(~p"/api/documents/#{document}"),
      topic: "redux_document:#{document.id}",
      id: document.id,
      links: %{
        symbols: %{
          href: url(~p"/api/symbols"),
          method: "get"
        },
        socket_schemas: %{
          href: url(~p"/api/socket_schemas"),
          method: "get"
        },
        semantic_tags: %{
          href: url(~p"/api/semantic_tags"),
          method: "get"
        },
        blueprints: %{
          href: url(~p"/api/blueprints"),
          method: "get"
        },
        semantics: %{
          href: url(~p"/api/semantic_rules"),
          method: "get"
        },
        primitives: %{
          href: url(~p"/api/primitives"),
          method: "get"
        },
        export: %{
          href: url(~p"/api/documents/#{document.id}/export"),
          method: "get"
        },
        download_json: %{
          href: url(~p"/api/documents/#{document.id}/download.json"),
          method: "get"
        },
        download_struct: %{
          href: url(~p"/api/documents/#{document.id}/download.iex"),
          method: "get"
        },
        duplicate: %{
          href: url(~p"/api/documents/#{document.id}/duplicate"),
          method: "post"
        },
        linked_simulations: %{
          href: url(~p"/api/documents/#{document.id}/simulations"),
          method: "get"
        }
      },
      content: show_content(document)
    }
  end

  def layer_data(%Layer{} = layer) do
    %{
      # id: layer.id,
      id: layer.id,
      semantic_tag: layer.semantic_tag,
      interface_id: layer.interface |> then(&if(&1, do: &1.socket_schema_id, else: nil)),
      z_index: layer.z_index,
      hidden: layer.hidden,
      hyperlink:
        case layer.outgoing_link do
          nil -> nil
          ol -> ol.target_layer_id
        end,
      parent_id:
        case layer.direct_parent_hood do
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
              "hint" =>
                case layer.text.size_hint do
                  %RenewCollab.Style.TextSizeHint{
                    position_x: position_x,
                    position_y: position_y,
                    width: width,
                    height: height
                  } ->
                    %{
                      x: position_x,
                      y: position_y,
                      width: width,
                      height: height
                    }

                  _ ->
                    nil
                end,
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
                      "text_color" => v.text_color,
                      "blank_lines" => v.blank_lines,
                      "rich" => v.rich
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
                  symbol -> symbol.id
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
                      %Waypoint{id: id, position_x: x, position_y: y} ->
                        %{"x" => x, "y" => y, "id" => id}
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
                      "source_tip_symbol_shape_id" => v.source_tip_symbol_shape_id,
                      "target_tip_symbol_shape_id" => v.target_tip_symbol_shape_id,
                      "source_tip_size" => v.source_tip_size,
                      "target_tip_size" => v.target_tip_size,
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
              "background_url" => v.background_url,
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
