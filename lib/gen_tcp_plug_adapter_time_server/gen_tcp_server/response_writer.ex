defmodule GenTcpPlugAdapter.GenTcpServer.ResponseWriter do
  def status(req, 200) do
    :gen_tcp.send(req, "HTTP/1.1 200 OK\r\n")
  end
  
  def headers(req, []) do
    :gen_tcp.send(req, "\r\n")
    :ok
  end
  def headers(req, [{name, value} | others]) do
    case name do
      "cache-control" ->
        :gen_tcp.send(req, "Cache-Control: #{value}\r\n")
      "content-type" ->
        :gen_tcp.send(req, "Content-Type: #{value}\r\n")
      "content-length" ->
        :gen_tcp.send(req, "Content-Length: #{value}\r\n")
      _ ->
        :ok
    end
    headers(req, others)
  end

  def body(req, string) do
    :gen_tcp.send(req, "#{string}\r\n")
  end
end
