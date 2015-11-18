defmodule GenTcpPlugAdapterTimeServer.GenTcpServer do
  use GenServer

  @name __MODULE__
  @socket_sup_name GenTcpServer.SocketTaskSupervisor
  @receiver_sup_name GenTcpServer.ReceiverTaskSupervisor

  def start_link do
    GenServer.start_link(@name, [], [name: @name])
  end

  def init([]) do
    {:ok, %{sockets: []}}
  end

  def listen(port, handler) do
    GenServer.call(@name, {:listen, port, handler})
  end

  def shutdown(pid) do
    GenServer.call(@name, {:shutdown, pid})
  end

  def handle_call({:listen, port, handler}, _from, state) do
    {:ok, socket} = get_socket_on_port(port)

    {:ok, pid} = Task.Supervisor.start_child(@socket_sup_name, @name, :socket_receiver, [socket, handler])
    :ok = :gen_tcp.controlling_process(socket, pid)

    state = %{state | sockets: state.sockets ++ [{socket, pid}]}
    {:reply, {:ok, pid}, state}
  end

  def socket_receiver(socket, handler) do

    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(@receiver_sup_name, @name,
                                             :client_receiver, [client, handler])
    :ok = :gen_tcp.controlling_process(client, pid)

    socket_receiver(socket, handler)
  end

  def client_receiver(client, handler) do
    request = read_request(client)

    dispatch_handler(handler, request)
    
    :gen_tcp.close(client)
  end

  defp read_request(client) do
    client
    |> receive_http_line
    |> receive_all_headers
    |> Enum.reduce(&parse_header(&1, &2))
  end

  defp receive_http_line(client) do
    {:ok, line} = :gen_tcp.recv(client, 0)
    line = String.replace(line, "\r\n", "")
    [meth, path, http] = String.split(line)
    {client, %{request_line: line, client: client, meth: meth, path: path, http: http}}
  end

  defp receive_all_headers({client, %{} = map}) do
    {:ok, header} = :gen_tcp.recv(client, 0)
    receive_all_headers(header, client, [], map)
  end
  defp receive_all_headers("\r\n", client, acc, map), do: [map | acc |> Enum.reverse]
  defp receive_all_headers(header, client, acc, map) do
    {:ok, next_header} = :gen_tcp.recv(client, 0)
    receive_all_headers(next_header, client, [header | acc], map)
  end

  defp parse_header(%{} = map, 0), do: map
  defp parse_header(line, into) do
    line = String.replace(line, "\r\n", "")
    [name, value] = String.split(line, ":", parts: 2)
    Map.put(into, name, value |> String.strip)
  end

  defp dispatch_handler(handler, request) when is_function(handler) do
    handler.(request)
  end
  defp dispatch_handler(handler, request) do
    handler.call(request)
  end

  defp get_socket_on_port(port) do
    :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
  end
end
