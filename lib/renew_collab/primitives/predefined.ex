defmodule RenewCollab.Primitives.Predefined do
  def all() do
    import Phoenix.Component, only: [sigil_H: 2]

    assigns = %{}
    shape_ids = RenewCollab.Symbols.ids_by_name()
    socket_schema_ids = RenewCollab.Sockets.schemas_by_name()

    shape_id = fn name, fallback -> Map.get(shape_ids, name, fallback) end
    socket_schema_id = fn name, fallback -> Map.get(socket_schema_ids, name, fallback) end

    place_socket_schema_id =
      socket_schema_id.("simple-ellipse", "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC")

    transition_socket_schema_id =
      socket_schema_id.("simple-rect", "4FDF577B-DB81-462E-971E-FA842F0ABA1E")

    rect_shape_id = shape_id.("rect", "2DD432FE-CC8A-4259-8A84-63F75AF0ECE0")
    round_rect_shape_id = shape_id.("rect-round", rect_shape_id)
    circle_shape_id = shape_id.("ellipse", "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42")
    virtual_place_shape_id = shape_id.("ellipse-double-in", circle_shape_id)
    triangle_shape_id = shape_id.("triangle-up", rect_shape_id)

    [
      %{
        id: "c9ab0adf-f5ed-4179-b8f7-dacb8fe6f8ce",
        name: "Nodes",
        primitives: [
          %{
            name: "Place",
            data: %{
              content: %{
                semantic_tag: "de.renew.gui.PlaceFigure",
                shape_id: circle_shape_id,
                socket_schema_id: place_socket_schema_id,
                width: 20,
                height: 20
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<circle fill="#24d188" cx="16" cy="16" r="15" stroke="#047138" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Transition",
            data: %{
              content: %{
                semantic_tag: "de.renew.gui.TransitionFigure",
                shape_id: rect_shape_id,
                socket_schema_id: transition_socket_schema_id,
                width: 24,
                height: 16
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<rect fill="#24d188" x="1" y="5" width="30" height="22" stroke="#047138" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Virtual Place",
            data: %{
              content: %{
                semantic_tag: "de.renew.gui.VirtualPlaceFigure",
                shape_id: virtual_place_shape_id,
                socket_schema_id: place_socket_schema_id,
                width: 20,
                height: 20
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<circle fill="none" cx="16" cy="16" r="14" stroke="#047138" stroke-width="2" />
<circle fill="#24d188" cx="16" cy="16" r="9" stroke="#047138" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Virtual Transition",
            data: %{
              content: %{
                semantic_tag: "de.renew.gui.VirtualTransitionFigure",
                shape_id: rect_shape_id,
                socket_schema_id: transition_socket_schema_id,
                width: 24,
                height: 16
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<rect fill="none" x="2" y="5" width="28" height="22" stroke="#047138" stroke-width="2" />
<rect fill="#24d188" x="7" y="10" width="18" height="12" stroke="#047138" stroke-width="2" />)
              |> html_to_string
          }
        ]
      },
      %{
        id: "9817a141-3c60-4b59-beb7-6829d13d7d83",
        name: "Shapes",
        primitives: [
          %{
            name: "Round Rectangle",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.RoundRectangleFigure",
                shape_id: round_rect_shape_id,
                shape_attributes: %{"rx" => 8, "ry" => 8},
                width: 40,
                height: 28
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<rect
  fill="#f2df60"
  x="2"
  y="6"
  width="28"
  height="20"
  rx="6"
  ry="6"
  stroke="#111"
  stroke-width="2"
/>)
              |> html_to_string
          },
          %{
            name: "Triangle",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.contrib.TriangleFigure",
                shape_id: triangle_shape_id,
                width: 32,
                height: 28
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<path d="M16 4 L30 28 L2 28 Z" fill="#f2df60" stroke="#111" stroke-width="2" />)
              |> html_to_string
          }
        ]
      },
      %{
        id: "e94f3d28-ab5a-4564-9ca1-e8c8447bc18c",
        name: "Text",
        primitives: [
          %{
            name: "Free Text",
            data: %{
              content: %{
                body: "Text",
                semantic_tag: "CH.ifa.draw.figures.TextFigure",
                style: %{
                  :font_size => 12
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<text text-anchor="middle" font-size="32" x="16" y="29" font-family="serif">T</text>)
              |> html_to_string
          },
          %{
            name: "Inscription",
            data: %{
              content: %{
                body: "[]",
                hyperlink: true,
                renew_type: 1,
                semantic_tag: "de.renew.gui.CPNTextFigure",
                style: %{
                  :font_size => 12
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<text text-anchor="middle" font-size="28" x="19" y="29" font-family="serif">A</text>

<rect x="1" y="3" width="9" height="14" fill="none" rx="5" ry="5" stroke="#555" stroke-width="2" />
<rect x="3" y="9" width="5" height="14" fill="#555" rx="3" ry="3" stroke="none" />)
              |> html_to_string
          }
        ]
      },
      %{
        id: "c32a1e6a-9935-45e0-9060-b124a10a478b",
        name: "FA",
        primitives: [
          %{
            name: "State",
            data: %{
              content: %{
                semantic_tag: "de.renew.fa.figures.FAStateFigure",
                shape_id: circle_shape_id,
                socket_schema_id: place_socket_schema_id,
                width: 40,
                height: 40,
                style: %{
                  background_color: "white",
                  border_color: "black",
                  border_width: "2"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<circle fill="#fff" cx="16" cy="16" r="15" stroke="#111" stroke-width="2" />)
              |> html_to_string
          }
        ]
      }
    ]
  end

  defp html_to_string(html) do
    html
    |> Phoenix.HTML.Safe.to_iodata()
    |> List.to_string()
  end
end
