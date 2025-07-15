defmodule RenewCollabWeb.Plug.CORS do
  use Corsica.Router,
    origins: [{__MODULE__, :valid_origin?, []}],
    allow_credentials: true,
    allow_headers: :all,
    allow_methods: :all,
    max_age: 600

  resource("/api/*")

  def valid_origin?(conn, origin) do
    String.match?(origin, ~r{^https?://.+$})
  end
end
