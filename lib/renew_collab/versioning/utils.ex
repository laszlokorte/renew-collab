defmodule RenewCollab.Versioning.Utils do
  def restore_json({:inserted_at, data}) do
    {:ok, datetime, _} = DateTime.from_iso8601(data)

    {:inserted_at, datetime}
  end

  def restore_json({:updated_at, data}) do
    {:ok, datetime, _} = DateTime.from_iso8601(data)

    {:updated_at, datetime}
  end

  def restore_json({:kind, "source"}) do
    {:kind, :source}
  end

  def restore_json({:kind, "target"}) do
    {:kind, :target}
  end

  def restore_json({:smoothness, "autobezier"}) do
    {:smoothness, :autobezier}
  end

  def restore_json({:smoothness, "linear"}) do
    {:smoothness, :linear}
  end

  def restore_json({:alignment, "left"}) do
    {:alignment, :left}
  end

  def restore_json({:alignment, "center"}) do
    {:alignment, :center}
  end

  def restore_json({:alignment, "right"}) do
    {:alignment, :right}
  end

  def restore_json(other), do: other
end
