defmodule RenewCollab.Sockets do
  alias RenewCollab.Connection.SocketSchema
  alias RenewCollab.Repo
  import Ecto.Query, warn: false

  def reset do
    Repo.transaction(fn ->
      Repo.delete_all(SocketSchema)

      %SocketSchema{}
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

      %SocketSchema{}
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

      %SocketSchema{}
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

      %SocketSchema{}
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

      %SocketSchema{}
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

      %SocketSchema{}
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

      %SocketSchema{}
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

      %SocketSchema{}
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

      %SocketSchema{}
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
