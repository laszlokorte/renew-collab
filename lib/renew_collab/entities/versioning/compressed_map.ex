defmodule RenewCollab.Versioning.CompressedMap do
  use Ecto.Type

  # The type stored in the database is still :binary (compressed data)
  def type, do: :binary

  # Cast the input if it's a map; otherwise, return :error
  def cast(data) when is_map(data), do: {:ok, data}
  def cast(_), do: :error

  def load(nil), do: {:ok, nil}

  # When loading from the database, decompress and deserialize the binary
  def load(data) when is_binary(data) do
    uncompressed = :zlib.uncompress(data)

    {:ok, :erlang.binary_to_term(uncompressed)}
  end

  # When dumping to the database, serialize the map to a binary and compress it
  def dump(data) when is_map(data) do
    try do
      # First serialize the map to binary
      binary_data = :erlang.term_to_binary(data)

      # Then compress the binary
      {:ok, :zlib.compress(binary_data)}
    rescue
      _ -> :error
    end
  end

  def dump(_), do: :error
end
