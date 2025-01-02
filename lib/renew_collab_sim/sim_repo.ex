defmodule RenewCollabSim.Repo do
  @db_adapter Application.compile_env(:renew_collab, :db_sim_adapter)

  use Ecto.Repo,
    otp_app: :renew_collab,
    adapter: @db_adapter

  case @db_adapter do
    Ecto.Adapters.Postgres ->
      def dump_uuid(uuid) do
        uuid
      end

    Ecto.Adapters.MyXQL ->
      def dump_uuid(uuid) do
        Ecto.UUID.dump!(uuid)
      end

    Ecto.Adapters.SQLite3 ->
      def dump_uuid(uuid) do
        uuid
      end

    _ ->
      raise "Unsupported adapter"
  end
end
