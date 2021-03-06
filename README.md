# SqliteInit

A small showcase to demonstrate a possible way to configure a SQLITE3 connection in combination with Ecto. This is probably horribly wrong, but I could not figure out a better / cleaner way.

### HOW?

It is possible to provide a `configure` callback to the Ecto config, but there you have the configuration list before creating the connection. The `after_connect` callback returns the DBConnection looking like this:

```elixir
%DBConnection{
  conn_mode: nil,
  conn_ref: #Reference<0.79303795.51642374.38123>,
  pool_ref: {:pool_ref, #PID<0.469.0>, #Reference<0.79303795.51642374.38102>,
   nil, #Reference<0.79303795.51773446.38113>, nil}
}
```

I guess it would be possible to access the SQLITE connection by `conn_ref`, but could not figure exactly how.

And the third option is to provide `connection_listeners` option with processes that will be notified on connected events with the pid of the connection.

We start a singleton process that gets messages for each connection in the pool, extacts the process state for each PID, and configures Sqlite extensions.

```elixir
# This should work, since we load the regex extension in the `SqliteInit.ConnectionListener` process.
SqliteInit.Repo.query!("select regexp_like('the year is 2021', ?) as value", ["2021"])
```

Some snippets for inspection:

```elixir
ExLitedb.extensions()
ExLitedb.path_for("cron")
ExLitedb.path_for("re")
Ecto.Adapter.lookup_meta(SqliteInit.Repo)
```

### UPDATED IMPROVEMENT (thanks to @ruslandoga!)

All you need is to setup following `after_connect` callback:

```elixir
config :sqlite_init, SqliteInit.Repo,
  database: Path.expand("../sqlite_init_dev.db", Path.dirname(__ENV__.file)),
  pool_size: 5,
  after_connect: fn _conn ->
    [db_conn] = Process.get(:"$callers")
    db_connection_state = :sys.get_state(db_conn)
    conn = db_connection_state.mod_state.state
    IO.inspect(conn, label: "conn")
    :ok = Exqlite.Basic.enable_load_extension(conn)
    Exqlite.Basic.load_extension(conn, ExLitedb.path_for("re"))
  end,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true
```
