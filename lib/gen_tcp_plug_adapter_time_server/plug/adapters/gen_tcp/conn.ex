defmodule Plug.Adapters.GenTcp.Conn do
  @behaviour Plug.Conn.Adapter
  import Plug.Adapters.GenTcp.RequestParser
  alias GenTcpPlugAdapter.GenTcpServer.ResponseWriter

  def conn(req) do
    %Plug.Conn{
      adapter: {__MODULE__, req[:client]},
      host: host(req),
      method: meth(req),
      owner: self(),
      path_info: split_path(req),
      #peer: peer,
      #port: port,
      #remote_ip: remote_ip,
      query_string: query_string(req),
      req_headers: headers(req),
      request_path: path(req),
      scheme: :http
    }
  end

  def send_resp(req, status, headers, body) do
    ResponseWriter.status(req, status)
    ResponseWriter.headers(req, [
      {"content-length", Kernel.byte_size("#{body}\r\n")} | headers])
    ResponseWriter.body(req, body)
    {:ok, nil, req}
  end

end
