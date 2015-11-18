# GenTcpPlugAdapterTimeServer

An implementation of parts of the Plug spec, just enough to implement the Time
Server for chapter 52 of Exercises for Programmers.

To run the time server:

```
iex -S mix
iex(1)> Plug.Adapters.GenTcp.http TimeServerPlug, []
```

And your server will be listening on port 4000 (you can change the port by passing [port: 4040])

