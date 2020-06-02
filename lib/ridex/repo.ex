defmodule Ridex.Repo do
  use Ecto.Repo,
    otp_app: :ridex,
    adapter: Ecto.Adapters.Postgres
end
