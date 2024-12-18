defmodule RenewCollab.Commands.UpdateLayerTextSizeHintAuto do
  import Ecto.Query, warn: false

  alias RenewCollab.Hierarchy.Layer
  alias RenewCollab.Style.TextSizeHint
  alias RenewCollab.Element.Text

  defstruct [:document_id, :layer_id]

  def new(%{document_id: document_id, layer_id: layer_id}) do
    %__MODULE__{document_id: document_id, layer_id: layer_id}
  end

  def tags(%__MODULE__{document_id: document_id}),
    do: [{:document_content, document_id}, :document_collection]

  def auto_snapshot(%__MODULE__{}), do: false

  def multi(%__MODULE__{document_id: document_id, layer_id: layer_id} = cmd) do
    Ecto.Multi.new()
    |> Ecto.Multi.one(
      {cmd, :text},
      from(t in Text,
        join: l in assoc(t, :layer),
        left_join: s in assoc(t, :style),
        where: l.id == ^layer_id,
        preload: [style: s]
      )
    )
    |> Ecto.Multi.run(
      {cmd, :new_hint},
      fn _, %{{^cmd, :text} => text} ->
        {:ok,
         RenewCollab.TextMeasure.MeasureServer.measure(
           {text.style.font_family, 0, text.style.font_size,
            text.body
            |> String.split("\n")
            |> Enum.filter(&(text.style.blank_lines or not blank?(&1)))}
         )}
      end
    )
    |> Ecto.Multi.merge(fn %{{^cmd, :new_hint} => {width, height}, {^cmd, :text} => text} ->
      RenewCollab.Commands.UpdateLayerTextSizeHint.new(%{
        document_id: document_id,
        layer_id: layer_id,
        box: %{
          position_x: text.position_x,
          position_y: text.position_y,
          width: width * 1.0,
          height: height * 1.0
        }
      })
      |> RenewCollab.Commands.UpdateLayerTextSizeHint.multi()
    end)
  end

  defp blank?(str_or_nil),
    do: "" == str_or_nil |> to_string() |> String.trim()
end
