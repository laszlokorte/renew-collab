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
    virtual_transition_shape_id = rect_shape_id
    round_rect_shape_id = shape_id.("rect-round", rect_shape_id)
    circle_shape_id = shape_id.("ellipse", "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42")
    virtual_place_shape_id = shape_id.("ellipse-double-in", circle_shape_id)
    triangle_shape_id = shape_id.("triangle-up", rect_shape_id)
    diamond_shape_id = shape_id.("diamond", rect_shape_id)
    pie_shape_id = shape_id.("pie", circle_shape_id)

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
                shape_id: virtual_transition_shape_id,
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
          }
        ]
      },
      %{
        id: "aab1a95c-faa7-4f5f-a6d4-217314e4e4d1",
        name: "Edges",
        primitives: []
      },
      %{
        id: "9817a141-3c60-4b59-beb7-6829d13d7d83",
        name: "Shapes",
        primitives: [
          %{
            name: "Rectangle",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.RectangleFigure",
                shape_id: rect_shape_id,
                width: 40,
                height: 28,
                style: %{
                  background_color: "#f2df60",
                  border_color: "black"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<rect fill="#f2df60" x="2" y="6" width="28" height="20" stroke="#111" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Round Rectangle",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.RoundRectangleFigure",
                shape_id: round_rect_shape_id,
                shape_attributes: %{"rx" => 8, "ry" => 8},
                width: 40,
                height: 28,
                style: %{
                  background_color: "#f2df60",
                  border_color: "black"
                }
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
            name: "Ellipse",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.EllipseFigure",
                shape_id: circle_shape_id,
                width: 32,
                height: 32,
                style: %{
                  background_color: "#f2df60",
                  border_color: "black"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<circle fill="#f2df60" cx="16" cy="16" r="14" stroke="#111" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Pie Segment",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.PieFigure",
                shape_id: pie_shape_id,
                width: 32,
                height: 32,
                style: %{
                  background_color: "#f2df60",
                  border_color: "black"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<path d="M16 16 L16 2 A14 14 0 1 1 2 16 Z" fill="#f2df60" stroke="#111" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Diamond",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.DiamondFigure",
                shape_id: diamond_shape_id,
                width: 32,
                height: 32,
                style: %{
                  background_color: "#f2df60",
                  border_color: "black"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<path d="M16 2 L30 16 L16 30 L2 16 Z" fill="#f2df60" stroke="#111" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Triangle",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.contrib.TriangleFigure",
                shape_id: triangle_shape_id,
                width: 32,
                height: 28,
                style: %{
                  background_color: "#f2df60",
                  border_color: "black"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<path d="M16 4 L30 28 L2 28 Z" fill="#f2df60" stroke="#111" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Line",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.PolyLineFigure",
                points: [%{x: -20, y: 0}, %{x: 20, y: 0}]
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<path d="M4 26 L28 6" fill="none" stroke="#111" stroke-width="2" stroke-linecap="butt" />)
              |> html_to_string
          },
          %{
            name: "Target",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.TargetFigure",
                shape_id: circle_shape_id,
                width: 24,
                height: 24,
                style: %{
                  background_color: "transparent",
                  border_color: "black"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<circle fill="none" cx="16" cy="16" r="13" stroke="#111" stroke-width="2" />
<path d="M16 3 L16 29 M3 16 L29 16" fill="none" stroke="#111" stroke-width="1" />)
              |> html_to_string
          },
          %{
            name: "Image",
            data: %{
              content: %{
                semantic_tag: "CH.ifa.draw.figures.ImageFigure",
                shape_id: rect_shape_id,
                width: 40,
                height: 32,
                style: %{
                  background_color: "#ffffff",
                  border_color: "#999999"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<rect fill="#eee" x="4" y="4" width="24" height="24" stroke="#999" stroke-width="2" />
<path d="M7 24 L14 16 L18 20 L22 13 L27 24 Z" fill="#ccc" stroke="none" />)
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
          },
          %{
            name: "Connected Text",
            data: %{
              content: %{
                body: "Text",
                hyperlink: true,
                renew_type: 0,
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
              ~H(<text text-anchor="middle" font-size="24" x="18" y="27" font-family="serif">T</text>

<rect x="2" y="4" width="8" height="12" fill="none" rx="4" ry="4" stroke="#555" stroke-width="2" />
<rect x="4" y="10" width="4" height="12" fill="#555" rx="2" ry="2" stroke="none" />)
              |> html_to_string
          },
          %{
            name: "Name",
            data: %{
              content: %{
                body: "name",
                hyperlink: true,
                renew_type: 2,
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
              ~H(<text text-anchor="middle" font-size="28" font-weight="bold" x="16" y="26" font-family="serif">
  n
</text>)
              |> html_to_string
          },
          %{
            name: "Declaration",
            data: %{
              content: %{
                body: "declaration",
                hyperlink: true,
                renew_type: 3,
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
              ~H(<text text-anchor="middle" font-size="28" font-weight="bold" x="16" y="27" font-family="serif">
  d
</text>)
              |> html_to_string
          },
          %{
            name: "Comment",
            data: %{
              content: %{
                body: "comment",
                hyperlink: true,
                renew_type: 4,
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
              ~H(<text text-anchor="middle" font-size="28" font-weight="bold" x="16" y="27" font-family="serif">
  i
</text>)
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
