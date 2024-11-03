defmodule RenewCollabWeb.SocketSchemaJSON do
  use RenewCollabWeb, :verified_routes

  def index(%{socket_schemas: socket_schemas}) do
    %{
      socket_schemas: Enum.map(socket_schemas, &socket_data/1)
    }
  end

  defp socket_data({id, socket}) do
    %{id: id, name: socket.name, sockets: Enum.map(socket.sockets, &socket_data/1)}
  end

  defp socket_data(path) do
    %{
      "id" => path.id,
      "name" => path.name,
      "x" => %{
        "value" => path.x_value,
        "unit" => path.x_unit,
        "offset" => %{
          "operation" => path.x_offset_operation,
          "value_static" => path.x_offset_value_static,
          "dynamic_value" => path.x_offset_dynamic_value,
          "dynamic_unit" => path.x_offset_dynamic_unit
        }
      },
      "y" => %{
        "value" => path.y_value,
        "unit" => path.y_unit,
        "offset" => %{
          "operation" => path.y_offset_operation,
          "value_static" => path.y_offset_value_static,
          "dynamic_value" => path.y_offset_dynamic_value,
          "dynamic_unit" => path.y_offset_dynamic_unit
        }
      }
    }
  end
end
