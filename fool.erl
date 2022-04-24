#!/usr/bin/env escript
-module(fool).
-mode(compile).

main(Args) ->
	{Int, _} = string:to_integer(Args),
	start(Int).

start(Port) ->
	{ok, Socket} = gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
	loop_acceptor(Socket).

loop_acceptor(Socket) ->
	{ok, Client} = gen_tcp:accept(Socket),
	io:fwrite("~w", [Client]),
	Recv = gen_tcp:recv(Client, 0),
	io:fwrite("~w~n", [Recv]),
	case Recv of
		{ok, <<"HELP\r\n">>} -> gen_tcp:send(Client, "FLAG:{YouMuffinHead}+10points");
		_ -> nil
	end,
	loop_acceptor(Socket).

