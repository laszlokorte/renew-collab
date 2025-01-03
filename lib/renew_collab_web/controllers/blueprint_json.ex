defmodule RenewCollabWeb.BlueprintJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{documents: documents}) do
    %{
      blueprints:
        documents
        |> Enum.map(fn doc ->
          %{name: doc.name, id: doc.id}
        end)
    }
  end

  def primitives(%{}) do
    import Phoenix.Component, only: [sigil_H: 2]

    assigns = %{}

    %{
      groups: [
        %{
          name: "Nodes",
          items: [
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
          name: "Text",
          items: [
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
        }
      ]
    }
  end

  def html_to_string(html) do
    html
    |> Phoenix.HTML.Safe.to_iodata()
    |> List.to_string()
  end
end
