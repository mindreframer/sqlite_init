defmodule SqliteInit.ConnectionListener do
  use GenServer

  def start_link(name) do
    GenServer.start_link(SqliteInit.ConnectionListener, [], name: name)
  end

  @impl true
  def init(_) do
    IO.puts("starting SqliteInit.ConnectionListener")
    {:ok, []}
  end

  @impl true
  def handle_info({:connected, pid}, state) do
    IO.puts("Connected to #{inspect(pid)}")
    db_connection_state = :sys.get_state(pid)
    conn = db_connection_state.mod_state.state
    # IO.inspect(conn, label: :conn)
    :ok = Exqlite.Basic.enable_load_extension(conn)
    Exqlite.Basic.load_extension(conn, ExLitedb.path_for("re"))
    {:noreply, state}
  end
end
