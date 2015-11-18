defmodule Plug.Adapters.GenTcp do
  alias GenTcpPlugAdapterTimeServer.GenTcpServer

  def http(plug, opts, gen_tcp_opts \\[]) do
    run(:http, plug, opts, gen_tcp_opts)
  end

  def run(_protocol, plug, opts, _gen_tcp_opts) do
    port = opts[:port] || 4000
    
    GenTcpServer.listen(port, &Plug.Adapters.GenTcp.Handler.call(plug, &1))
  end

  def shutdown(pid) do
    GenTcpServer.shutdown(pid)
  end
end
