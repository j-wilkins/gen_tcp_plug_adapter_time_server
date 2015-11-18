defmodule Plug.Adapters.GenTcp.RequestParser do
  def host(req) do
    req["Host"]
  end

  def meth(req) do
    req[:meth]
  end

  def split_path(%{path: path}) do
    if String.contains?(path, "?") do
      [path, _qs] = String.split(path, "?")
    end
    String.split(path, "/")
  end

  def query_string(%{path: path}) do
    if String.contains?(path, "?") do
      [_path, qs] = String.split(path, "?")
      qs
    else
      ""
    end
  end

  def headers(req) do
    Map.drop(req, [:client, :http, :meth, :path, :request_line])
  end

  def path(%{path: path}), do: path
end
