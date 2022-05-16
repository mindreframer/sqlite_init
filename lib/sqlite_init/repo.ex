defmodule SqliteInit.Repo do
  use Ecto.Repo,
    otp_app: :sqlite_init,
    adapter: Ecto.Adapters.SQLite3
end
