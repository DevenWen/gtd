defmodule Gtd.Repo do
  use Ecto.Repo,
    otp_app: :gtd,
    adapter: Ecto.Adapters.Postgres
end
