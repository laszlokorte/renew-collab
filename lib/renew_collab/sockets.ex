defmodule RenewCollab.Sockets do
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Repo
  import Ecto.Query, warn: false

  def reset do
    Repo.transaction(fn ->
      Repo.delete_all(SocketSchema)

      %SocketSchema{
        id: "0f59a84e-8569-4272-839f-788ab07eca23"
      }
      |> SocketSchema.changeset(%{
        name: "simple",
        sockets: [
          %{
            name: "center-socket",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()

      %SocketSchema{
        id: "4FDF577B-DB81-462E-971E-FA842F0ABA1E"
      }
      |> SocketSchema.changeset(%{
        name: "simple-rect",
        stencil: "rect",
        sockets: [
          %{
            name: "center-socket",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()

      %SocketSchema{
        id: "2C5DE751-2FB8-48DE-99B6-D99648EBDFFC"
      }
      |> SocketSchema.changeset(%{
        name: "simple-ellipse",
        stencil: "ellipse",
        sockets: [
          %{
            name: "center-socket",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()

      %SocketSchema{
        id: "11062480-803E-4944-AE74-DF3EF8978187"
      }
      |> SocketSchema.changeset(%{
        name: "sides",
        sockets: [
          %{
            name: "left",
            x_value: 0,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "right",
            x_value: 1,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "top",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "bottom",
            x_value: 0.5,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()

      %SocketSchema{
        id: "46BEAB25-389D-4E4B-8E13-5C5B34A8C20A"
      }
      |> SocketSchema.changeset(%{
        name: "corners",
        sockets: [
          %{
            name: "topleft",
            x_value: 0,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "topright",
            x_value: 1,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "bottomleft",
            x_value: 0,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          },
          %{
            name: "bottomright",
            x_value: 1,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()

      %SocketSchema{
        id: "A1A1BD97-373D-4B78-B218-D20F1C5BDB35"
      }
      |> SocketSchema.changeset(%{
        name: "corners-and-sides",
        sockets: [
          %{
            name: "topleft",
            x_value: 0,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "topright",
            x_value: 1,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "bottomleft",
            x_value: 0,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          },
          %{
            name: "bottomright",
            x_value: 1,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          },
          %{
            name: "left",
            x_value: 0,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "right",
            x_value: 1,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "top",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "bottom",
            x_value: 0.5,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()

      %SocketSchema{
        id: "5D768A61-6992-4350-864E-DCC4B2219181"
      }
      |> SocketSchema.changeset(%{
        name: "sides-and-center",
        sockets: [
          %{
            name: "center-socket",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "left",
            x_value: 0,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "right",
            x_value: 1,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "top",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "bottom",
            x_value: 0.5,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()

      %SocketSchema{
        id: "737FD22C-A3C2-4962-B869-CBE867F1F748"
      }
      |> SocketSchema.changeset(%{
        name: "corners-and-center",
        sockets: [
          %{
            name: "center-socket",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "topleft",
            x_value: 0,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "topright",
            x_value: 1,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "bottomleft",
            x_value: 0,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          },
          %{
            name: "bottomright",
            x_value: 1,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()

      %SocketSchema{
        id: "4A513B13-F04E-4E4C-9655-EF510DDAAE29"
      }
      |> SocketSchema.changeset(%{
        name: "3x3 sockets",
        sockets: [
          %{
            name: "center-socket",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "topleft",
            x_value: 0,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "topright",
            x_value: 1,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "bottomleft",
            x_value: 0,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          },
          %{
            name: "bottomright",
            x_value: 1,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          },
          %{
            name: "left",
            x_value: 0,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "right",
            x_value: 1,
            x_unit: :width,
            y_value: 0.5,
            y_unit: :height
          },
          %{
            name: "top",
            x_value: 0.5,
            x_unit: :width,
            y_value: 0,
            y_unit: :height
          },
          %{
            name: "bottom",
            x_value: 0.5,
            x_unit: :width,
            y_value: 1,
            y_unit: :height
          }
        ]
      })
      |> Repo.insert()
    end)
  end

  def ids_by_name do
    from(p in SocketSchema, join: s in assoc(p, :sockets), select: {{p.name, s.name}, s.id})
    |> Repo.all()
    |> Map.new()
  end

  def all_socket_schemas do
    from(p in SocketSchema, order_by: [asc: p.name])
    |> Repo.all()
    |> Repo.preload(:sockets)
    |> Enum.map(&{&1.id, &1})
    |> Map.new()
  end
end
