defmodule RenewCollab.Commands.CreateLayerWithEdge do
  import Ecto.Query, warn: false
  alias RenewCollab.Commands.CreateLayer

  defstruct [:document_id, :attrs, :base_layer_id, :edge]

  def new(%{
        document_id: document_id,
        attrs: attrs,
        edge: edge,
        base_layer_id: base_layer_id
      }) do
    %__MODULE__{
      document_id: document_id,
      attrs: attrs,
      edge: edge,
      base_layer_id: base_layer_id
    }
  end

  def new(%{
        document_id: document_id,
        attrs: attrs,
        edge: edge
      }) do
    %__MODULE__{
      document_id: document_id,
      attrs: attrs,
      edge: edge,
      base_layer_id: nil
    }
  end

  def tags(%__MODULE__{document_id: document_id}), do: [{:document_content, document_id}]
  def auto_snapshot(%__MODULE__{}), do: true

  def multi(%__MODULE__{
        document_id: document_id,
        attrs: attrs,
        edge:
          edge = %{
            "source" => %{"socket_id" => source_socket_id, "layer_id" => source_layer_id},
            "target" => %{"socket_id" => target_socket_id}
          },
        base_layer_id: base_layer_id
      }) do
    Ecto.Multi.new()
    |> Ecto.Multi.put(:document_id, document_id)
    |> Ecto.Multi.run(:layer, fn repo, _ ->
      create_layer =
        CreateLayer.new(%{
          document_id: document_id,
          attrs: attrs,
          base_layer_id: base_layer_id
        })
        |> CreateLayer.multi()

      with {:ok, %{layer: %{id: target_layer_id}}} <- repo.transaction(create_layer) do
        reverse = Map.get(edge, "reverse", false)

        source_bond =
          %{
            "layer_id" => source_layer_id,
            "socket_id" => source_socket_id
          }

        target_bond = %{
          "layer_id" => target_layer_id,
          "socket_id" => target_socket_id
        }

        {source_bond, target_bond} =
          if(reverse, do: {target_bond, source_bond}, else: {source_bond, target_bond})

        create_edge =
          CreateLayer.new(%{
            document_id: document_id,
            attrs: %{
              "semantic_tag" => Map.get(edge, "semantic_tag", "de.renew.gui.ArcConnection"),
              "edge" => %{
                "source_x" => 0,
                "source_y" => 0,
                "target_x" => 0,
                "target_y" => 0,
                "source_bond" => source_bond,
                "target_bond" => target_bond,
                "style" => %{
                  "target_tip_symbol_shape_id" =>
                    Map.get(edge, "target_tip_symbol_shape_id", nil),
                  "source_tip_symbol_shape_id" => Map.get(edge, "source_tip_symbol_shape_id", nil)
                }
              }
            },
            base_layer_id: target_layer_id
          })
          |> CreateLayer.multi()

        with {:ok, %{layer: final_layer}} <- repo.transaction(create_edge) do
          {:ok, final_layer}
        end
      else
        error -> error
      end
    end)
  end
end
