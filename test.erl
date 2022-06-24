-module(test).
-export([nano_get_url/0, nano_get_url/1]).

nano_get_url() ->
    nano_get_url("www.baidu.com").   %in elixir use ''

nano_get_url(Host) ->
  % 1. `binary` - receives data as binaries (instead of lists)
  % 2. `{packet, line}` - receives data line by line
  % 3. `active: false` - blocks on `gen_tcp:recv/2` until data is available
  % 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    {ok, Socket} = gen_tcp:connect(Host, 80, [binary, {packet, 0}]),
    ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),
    receive_data(Socket, []).
    %like flush(), it receives data from port

receive_data(Socket, SoFar) ->
    receive
        {tcp, Socket, Bin} ->
            receive_data(Socket, [Bin | SoFar]);
        {tcp_closed, Socket} ->
            list_to_binary(lists:reverse(SoFar))
    end.

