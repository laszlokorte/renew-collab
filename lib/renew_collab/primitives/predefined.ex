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
    fa_start_shape_id = shape_id.("ellipse-arrow-inward-north-west", circle_shape_id)
    fa_end_shape_id = shape_id.("ellipse-double-in", circle_shape_id)

    fa_start_end_shape_id =
      shape_id.("ellipse-double-in-arrow-inward-north-west", fa_end_shape_id)

    triangle_shape_id = shape_id.("triangle-up", rect_shape_id)
    diamond_shape_id = shape_id.("diamond", rect_shape_id)
    pie_shape_id = shape_id.("pie", circle_shape_id)

    [
      %{
        id: "c9ab0adf-f5ed-4179-b8f7-dacb8fe6f8ce",
        name: "Nodes",
        primitives: [
          %{
            name: "Place Tool",
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
              ~H(<circle fill="#f2df60" cx="16" cy="16" r="11" stroke="#111" stroke-width="1.5" />
<text
  x="16"
  y="20"
  text-anchor="middle"
  font-family="serif"
  font-size="11"
  font-weight="bold"
  fill="#111"
>
  P
</text>)
              |> html_to_string
          },
          %{
            name: "Transition Tool",
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
              ~H(<rect fill="#f2df60" x="6" y="9" width="20" height="14" stroke="#111" stroke-width="1.5" />
<text
  x="16"
  y="20"
  text-anchor="middle"
  font-family="serif"
  font-size="11"
  font-weight="bold"
  fill="#111"
>
  T
</text>)
              |> html_to_string
          },
          %{
            name: "Virtual Place Tool",
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
              ~H(<circle fill="#f2df60" cx="16" cy="16" r="11" stroke="#111" stroke-width="1.5" />
<circle fill="none" cx="16" cy="16" r="8" stroke="#111" stroke-width="1" />
<path d="M8 13 H24 M8 16 H24 M8 19 H24" stroke="#b89d22" stroke-width="0.8" />)
              |> html_to_string
          },
          %{
            name: "Virtual Transition Tool",
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
              ~H(<rect fill="#f2df60" x="6" y="9" width="20" height="14" stroke="#111" stroke-width="1.5" />
<rect fill="none" x="9" y="12" width="14" height="8" stroke="#111" stroke-width="1" />
<path d="M8 12 H24 M8 16 H24 M8 20 H24" stroke="#b89d22" stroke-width="0.8" />)
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
            name: "Rectangle Tool",
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
            name: "Round Rectangle Tool",
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
            name: "Ellipse Tool",
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
            name: "Elliptical Arc/Pie Tool",
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
            name: "Diamond Tool",
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
            name: "Triangle Tool",
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
            name: "Line Tool",
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
            name: "Target Tool",
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
              ~H(<circle cx="16" cy="16" r="10" fill="none" stroke="#111" stroke-width="1.8" />
<path
  d="M16 5 V27 M5 16 H27"
  fill="none"
  stroke="#111"
  stroke-width="1.2"
  stroke-linecap="butt"
/>)
              |> html_to_string
          },
          %{
            name: "Image Tool",
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
            name: "Text Tool",
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
              ~H(<text
  text-anchor="middle"
  font-size="26"
  font-weight="bold"
  x="16"
  y="26"
  font-family="serif"
  fill="#111"
>
  A
</text>)
              |> html_to_string
          },
          %{
            name: "Inscription Tool",
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
              ~H(<text
  text-anchor="middle"
  font-size="24"
  font-weight="bold"
  x="16"
  y="25"
  font-family="serif"
  fill="#111"
>
  i
</text>)
              |> html_to_string
          },
          %{
            name: "Connected Text Tool",
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
              ~H(<text x="5" y="11" font-size="12" font-family="serif" fill="#111">*</text>
<text
  text-anchor="middle"
  font-size="25"
  font-weight="bold"
  x="18"
  y="27"
  font-family="serif"
  fill="#111"
>
  A
</text>)
              |> html_to_string
          },
          %{
            name: "Name Tool",
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
              ~H(<text
  text-anchor="middle"
  font-size="24"
  font-weight="bold"
  x="16"
  y="25"
  font-family="serif"
  fill="#111"
>
  n
</text>)
              |> html_to_string
          },
          %{
            name: "Declaration Tool",
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
              ~H(<text
  text-anchor="middle"
  font-size="24"
  font-weight="bold"
  x="16"
  y="25"
  font-family="serif"
  fill="#111"
>
  d
</text>)
              |> html_to_string
          },
          %{
            name: "Comment Tool",
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
              ~H(<text
  text-anchor="middle"
  font-size="22"
  font-weight="bold"
  x="16"
  y="24"
  font-family="serif"
  fill="#111"
>
  @
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
            name: "FA Start State Tool",
            data: %{
              content: %{
                semantic_tag: "de.renew.fa.figures.FAStateFigure",
                shape_id: fa_start_shape_id,
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
              ~H(<circle fill="#fff" cx="16" cy="16" r="14" stroke="#111" stroke-width="2" />
<path
  d="M3 3 L9 9"
  fill="none"
  stroke="#111"
  stroke-width="1.5"
  stroke-linecap="round"
/>
<path
  d="M9 9 L4.5 8.2 M9 9 L8.2 4.5"
  fill="none"
  stroke="#111"
  stroke-width="1.5"
  stroke-linecap="round"
/>)
              |> html_to_string
          },
          %{
            name: "FA State Tool",
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
              ~H(<circle fill="#fff" cx="16" cy="16" r="14" stroke="#111" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "FA End State Tool",
            data: %{
              content: %{
                semantic_tag: "de.renew.fa.figures.FAStateFigure",
                shape_id: fa_end_shape_id,
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
              ~H(<circle fill="#fff" cx="16" cy="16" r="14" stroke="#111" stroke-width="2" />
<circle fill="none" cx="16" cy="16" r="10.5" stroke="#111" stroke-width="1.4" />)
              |> html_to_string
          },
          %{
            name: "FA Start End State Tool",
            data: %{
              content: %{
                semantic_tag: "de.renew.fa.figures.FAStateFigure",
                shape_id: fa_start_end_shape_id,
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
              ~H(<circle fill="#fff" cx="16" cy="16" r="14" stroke="#111" stroke-width="2" />
<circle fill="none" cx="16" cy="16" r="10.5" stroke="#111" stroke-width="1.4" />
<path
  d="M3 3 L9 9"
  fill="none"
  stroke="#111"
  stroke-width="1.5"
  stroke-linecap="round"
/>
<path
  d="M9 9 L4.5 8.2 M9 9 L8.2 4.5"
  fill="none"
  stroke="#111"
  stroke-width="1.5"
  stroke-linecap="round"
/>)
              |> html_to_string
          },
          %{
            name: "FA Name Tool",
            data: %{
              content: %{
                body: "",
                hyperlink: true,
                renew_type: 2,
                semantic_tag: "de.renew.fa.figures.FATextFigure",
                style: %{
                  :alignment => "center",
                  :font_size => 12
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<text
  text-anchor="middle"
  font-size="24"
  font-weight="bold"
  x="16"
  y="25"
  font-family="serif"
  fill="#111"
>
  n
</text>)
              |> html_to_string
          },
          %{
            name: "FA Inscription Tool",
            data: %{
              content: %{
                body: "a",
                hyperlink: true,
                renew_type: 1,
                semantic_tag: "de.renew.fa.figures.FATextFigure",
                style: %{
                  :alignment => "center",
                  :font_size => 12
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<text
  text-anchor="middle"
  font-size="24"
  font-weight="bold"
  x="16"
  y="25"
  font-family="serif"
  fill="#111"
>
  i
</text>)
              |> html_to_string
          },
          %{
            name: "FA Word Placement Tool",
            data: %{
              content: %{
                body: "a*+b^+",
                hyperlink: true,
                semantic_tag: "de.renew.fa.figures.FAWordTextFigure",
                style: %{
                  :alignment => "center",
                  :bold => true,
                  :italic => true,
                  :font_size => 12,
                  :text_color => "#025bff"
                }
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<text
  text-anchor="middle"
  font-size="20"
  font-weight="bold"
  font-style="italic"
  x="16"
  y="23"
  font-family="serif"
  fill="#025bff"
>
  w
</text>)
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
