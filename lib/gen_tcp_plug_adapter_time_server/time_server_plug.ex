defmodule TimeServerPlug do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, "{\"currentTime\":\"#{timestamp}\"}")
  end

  defp timestamp do
    {time, _} = System.cmd("date", [])
    String.rstrip(time, ?\n)
  end
end
