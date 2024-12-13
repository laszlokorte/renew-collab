defmodule RenewCollabWeb.Plug.CORS do
  use Corsica.Router,
    origins: [~r{^https?://.+$}],
    allow_credentials: true,
    allow_headers: :all,
    allow_methods: :all,
    max_age: 600

  resource("/api/*")
end
