
defmodule Plug.Adapters.GenTcp.Handler do
  @connection Plug.Adapters.GenTcp.Conn
  @already_sent {:plug_conn, :sent}

  def call(plug, request, opts \\ []) do
    conn = @connection.conn(request)

    try do
      %{adapter: {@connection, req}} =  conn
      |> plug.call(opts)
      |> maybe_send(plug)

      {:ok, req}
    catch
      :error, value ->
        :wat
    after
      receive do
        @already_sent -> :ok
      after
        0 -> :ok
      end
    end
  end

  defp maybe_send(%Plug.Conn{state: :set} = conn, _plug), do: Plug.Conn.send_resp(conn)
end

