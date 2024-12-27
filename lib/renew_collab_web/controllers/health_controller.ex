defmodule RenewCollabWeb.HealthController do
  use RenewCollabWeb, :controller

  action_fallback RenewCollabWeb.FallbackController

  def index(conn, _params) do
    render(conn, :index,
      installed_socke_schema: RenewCollab.Sockets.all_socket_schemas(),
      installed_symbols: RenewCollab.Symbols.ids_by_name(),
      number_of_accounts: RenewCollabAuth.Auth.count_accounts(),
      number_of_sessions: RenewCollabAuth.Auth.count_sessions(),
      number_of_media: RenewCollab.Media.count(),
      number_of_documents: RenewCollab.Renew.count_documents(),
      hierarchy_missing_count: RenewCollab.Hierarchy.count_missing_global(),
      hierarchy_invalid_count: RenewCollab.Hierarchy.count_invalids_global(),
      cache_size: RenewCollab.SimpleCache.size(),
      simulation_count: RenewCollabSim.Server.SimulationServer.count()
    )
  end
end
