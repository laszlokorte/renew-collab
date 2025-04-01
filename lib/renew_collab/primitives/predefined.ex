defmodule RenewCollab.Primitives.Predefined do
  def all() do
    import Phoenix.Component, only: [sigil_H: 2]

    assigns = %{}

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
                shape_id: "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
                socket_schema_id: "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC"
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<circle fill="#24d188" cx="16" cy="16" r="16" stroke="#047138" stroke-width="2" />)
              |> html_to_string
          },
          %{
            name: "Transition",
            data: %{
              content: %{
                semantic_tag: "de.renew.gui.TransitionFigure",
                shape_id: "2DD432FE-CC8A-4259-8A84-63F75AF0ECE0",
                socket_schema_id: "4FDF577B-DB81-462E-971E-FA842F0ABA1E"
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<rect fill="#24d188" x="1" y="1" width="30" height="30" stroke="#047138" stroke-width="2" />)
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
                semantic_tag: "CH.ifa.draw.figures.TextFigure"
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<text text-anchor="middle" font-size="40" x="16" y="30" font-family="serif">T</text>)
              |> html_to_string
          },
          %{
            name: "Inscription",
            data: %{
              content: %{
                body: "[]",
                hyperlink: true,
                semantic_tag: "de.renew.gui.CPNTextFigure"
              },
              mimeType: "application/json+renewex-layer",
              alignX: 0.5,
              alignY: 0.5
            },
            icon:
              ~H(<text text-anchor="middle" font-size="30" x="16" y="30" font-family="serif">A</text>

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
                shape_id: "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
                socket_schema_id: "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC",
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
              ~H(<circle fill="#fff" cx="16" cy="16" r="16" stroke="#111" stroke-width="2" />)
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
