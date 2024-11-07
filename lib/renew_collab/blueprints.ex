defmodule RenewCollab.Blueprints do
  alias RenewCollab.Document.TransientDocument

  @all [
    %TransientDocument{
      content: %{
        name: "Example",
        kind: "CH.ifa.draw.standard.StandardDrawing",
        layers: [
          %{
            hidden: false,
            id: "0c3e5b28-16f9-444d-b6bf-9864d08f6d9e",
            interface: nil,
            text: nil,
            edge: nil,
            style: nil,
            box: nil,
            z_index: 0,
            semantic_tag: "CH.ifa.draw.figures.GroupFigure"
          },
          %{
            hidden: false,
            id: "ae4133ee-63b9-4b5d-a0cb-ab8335a0fd96",
            interface: nil,
            text: %{
              body: "Hello World",
              style: %{
                rich: false,
                italic: false,
                underline: false,
                alignment: :center,
                text_color: "#e22937",
                font_size: 20.0,
                font_family: "sans-serif",
                bold: true,
                blank_lines: false
              },
              position_x: -116.99230003356934,
              position_y: 46.806809425354004
            },
            edge: nil,
            style: nil,
            box: nil,
            z_index: 1,
            semantic_tag: "CH.ifa.draw.figures.TextFigure"
          },
          %{
            hidden: false,
            id: "9b475ab9-8dbc-4a2c-ac62-46081fcdcd5d",
            interface: nil,
            text: %{
              body: "Hello World",
              style: %{
                rich: false,
                italic: false,
                underline: false,
                alignment: :center,
                text_color: "#3acd10",
                font_size: 20.0,
                font_family: "sans-serif",
                bold: true,
                blank_lines: false
              },
              position_x: 320.5367736816406,
              position_y: 41.868271827697754
            },
            edge: nil,
            style: nil,
            box: nil,
            z_index: 2,
            semantic_tag: "CH.ifa.draw.figures.TextFigure"
          },
          %{
            hidden: false,
            id: "47258301-e3ea-472f-ba0b-0fc8cc0c4a1d",
            interface: %{socket_schema_id: "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC"},
            text: nil,
            edge: nil,
            style: %{
              opacity: nil,
              border_width: nil,
              border_dash_array: nil,
              border_color: nil,
              background_color: "#5be1b6"
            },
            box: %{
              width: 200.0,
              position_x: -154.6403466463089,
              position_y: -85.59513854980469,
              symbol_shape_attributes: nil,
              symbol_shape_id: "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
              height: 100.0
            },
            z_index: 3,
            semantic_tag: "CH.ifa.draw.figures.RectangleFigure"
          },
          %{
            hidden: false,
            id: "59a2bccd-36c0-4449-999a-b05f5e0cd867",
            interface: %{socket_schema_id: "4FDF577B-DB81-462E-971E-FA842F0ABA1E"},
            text: nil,
            edge: nil,
            style: %{
              opacity: nil,
              border_width: nil,
              border_dash_array: nil,
              border_color: nil,
              background_color: "#db6533"
            },
            box: %{
              width: 200.0,
              position_x: 265.3379364013672,
              position_y: -86.39403533935547,
              symbol_shape_attributes: nil,
              symbol_shape_id: nil,
              height: 100.0
            },
            z_index: 4,
            semantic_tag: "CH.ifa.draw.figures.RectangleFigure"
          },
          %{
            hidden: false,
            id: "dd3df027-1e28-4e32-98bd-37969ef8b46f",
            interface: nil,
            text: nil,
            edge: %{
              cyclic: false,
              style: %{
                target_tip_symbol_shape_id: "38DA1001-0640-48DF-98F1-B2BB199028F4",
                stroke_width: "3",
                stroke_join: nil,
                stroke_dash_array: nil,
                stroke_color: "black",
                stroke_cap: nil,
                source_tip_symbol_shape_id: "1BB93575-6759-4C59-8ED3-626949D1326A",
                smoothness: :autobezier
              },
              target_y: 13.538483567217234,
              target_x: 274.95270681931487,
              source_y: 4.37911853899368,
              source_x: 5.428190253076828,
              waypoints: [
                %{
                  sort: 0,
                  position_x: 55.57521438598633,
                  position_y: 37.75083255767822
                },
                %{
                  sort: 1,
                  position_x: 93.1471176147461,
                  position_y: -132.63336181640625
                },
                %{
                  sort: 2,
                  position_x: 141.20419311523438,
                  position_y: -74.9648666381836
                },
                %{
                  sort: 3,
                  position_x: 190.13504028320312,
                  position_y: -134.38088989257812
                },
                %{
                  sort: 4,
                  position_x: 213.72669982910156,
                  position_y: 47.36224842071533
                }
              ]
            },
            style: nil,
            box: nil,
            z_index: 5,
            semantic_tag: "CH.ifa.draw.figures.PolyLineFigure"
          }
        ]
      },
      parenthoods: [
        {"59a2bccd-36c0-4449-999a-b05f5e0cd867", "59a2bccd-36c0-4449-999a-b05f5e0cd867", 0},
        {"47258301-e3ea-472f-ba0b-0fc8cc0c4a1d", "47258301-e3ea-472f-ba0b-0fc8cc0c4a1d", 0},
        {"9b475ab9-8dbc-4a2c-ac62-46081fcdcd5d", "9b475ab9-8dbc-4a2c-ac62-46081fcdcd5d", 0},
        {"ae4133ee-63b9-4b5d-a0cb-ab8335a0fd96", "ae4133ee-63b9-4b5d-a0cb-ab8335a0fd96", 0},
        {"dd3df027-1e28-4e32-98bd-37969ef8b46f", "dd3df027-1e28-4e32-98bd-37969ef8b46f", 0},
        {"0c3e5b28-16f9-444d-b6bf-9864d08f6d9e", "0c3e5b28-16f9-444d-b6bf-9864d08f6d9e", 0},
        {"0c3e5b28-16f9-444d-b6bf-9864d08f6d9e", "ae4133ee-63b9-4b5d-a0cb-ab8335a0fd96", 1},
        {"0c3e5b28-16f9-444d-b6bf-9864d08f6d9e", "9b475ab9-8dbc-4a2c-ac62-46081fcdcd5d", 1},
        {"0c3e5b28-16f9-444d-b6bf-9864d08f6d9e", "47258301-e3ea-472f-ba0b-0fc8cc0c4a1d", 1},
        {"0c3e5b28-16f9-444d-b6bf-9864d08f6d9e", "59a2bccd-36c0-4449-999a-b05f5e0cd867", 1},
        {"0c3e5b28-16f9-444d-b6bf-9864d08f6d9e", "dd3df027-1e28-4e32-98bd-37969ef8b46f", 1}
      ],
      hyperlinks: [
        %{
          source_layer_id: "9b475ab9-8dbc-4a2c-ac62-46081fcdcd5d",
          target_layer_id: "59a2bccd-36c0-4449-999a-b05f5e0cd867"
        },
        %{
          source_layer_id: "ae4133ee-63b9-4b5d-a0cb-ab8335a0fd96",
          target_layer_id: "47258301-e3ea-472f-ba0b-0fc8cc0c4a1d"
        }
      ],
      bonds: [
        %{
          kind: :source,
          layer_id: "47258301-e3ea-472f-ba0b-0fc8cc0c4a1d",
          socket_id: "9BE09A98-DECF-4D38-8A06-5381B51D7538",
          edge_layer_id: "dd3df027-1e28-4e32-98bd-37969ef8b46f"
        },
        %{
          kind: :target,
          layer_id: "59a2bccd-36c0-4449-999a-b05f5e0cd867",
          socket_id: "88E32BDC-3DA6-4FBB-9CC8-334B6D6048FD",
          edge_layer_id: "dd3df027-1e28-4e32-98bd-37969ef8b46f"
        }
      ]
    },
    %TransientDocument{
      content: %{
        name: "Transition",
        kind: "CH.ifa.draw.standard.StandardDrawing",
        layers: [
          %{
            hidden: false,
            id: "e776966a-5dd7-40d1-b1a6-ea4f727a2e6b",
            interface: %{socket_schema_id: "4FDF577B-DB81-462E-971E-FA842F0ABA1E"},
            text: nil,
            edge: nil,
            style: nil,
            box: %{
              width: 176.72887420654297,
              position_x: -80.79034042358398,
              position_y: -50.93304252624512,
              symbol_shape_attributes: nil,
              symbol_shape_id: nil,
              height: 95.60922241210938
            },
            z_index: 0,
            semantic_tag: "de.renew.gui.TransitionFigure"
          }
        ]
      },
      parenthoods: [
        {"e776966a-5dd7-40d1-b1a6-ea4f727a2e6b", "e776966a-5dd7-40d1-b1a6-ea4f727a2e6b", 0}
      ],
      hyperlinks: [],
      bonds: []
    },
    %TransientDocument{
      content: %{
        name: "Place",
        kind: "CH.ifa.draw.standard.StandardDrawing",
        layers: [
          %{
            hidden: false,
            id: "cad0fc43-8eba-4d23-b18c-4cc3e0553175",
            interface: %{socket_schema_id: "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC"},
            text: nil,
            edge: nil,
            style: nil,
            box: %{
              width: 200.0,
              position_x: -37.321624755859375,
              position_y: -27.222834587097168,
              symbol_shape_attributes: nil,
              symbol_shape_id: "3B66E69A-057A-40B9-A1A0-9DB44EF5CE42",
              height: 100.0
            },
            z_index: 0,
            semantic_tag: "de.renew.gui.PlaceFigure"
          }
        ]
      },
      parenthoods: [
        {"cad0fc43-8eba-4d23-b18c-4cc3e0553175", "cad0fc43-8eba-4d23-b18c-4cc3e0553175", 0}
      ],
      hyperlinks: [],
      bonds: []
    }
  ]

  def all() do
    @all
  end
end
