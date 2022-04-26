#!/usr/bin/env escript
-module(fool).
-mode(compile).

-define(CONSOLE_COLOR_RED,      "\e[0;31m").
-define(CONSOLE_COLOR_YELLOW,   "\e[0;33m").
-define(CONSOLE_COLOR_BLUE,     "\e[0;34m").
-define(CONSOLE_COLOR_GREEN,    "\e[0;36m").
-define(CONSOLE_COLOR_NORMAL,   "\e[0;38m").

main(Args) ->
	{Int, _} = string:to_integer(Args),
	io:fwrite("starting...~n"),
	start(Int).

start(Port) ->
	{ok, Socket} =
		gen_tcp:listen(Port, [binary, {packet, 0}, {active, false}, {reuseaddr, true}]),
	loop_acceptor(Socket).

loop_acceptor(Socket) ->
	{ok, Client} = gen_tcp:accept(Socket),
	spawn(fun() -> serve(Client) end),
	loop_acceptor(Socket).

serve(Client) ->
	Recv = gen_tcp:recv(Client, 0),
	io:fwrite("~s~w~w~s", [?CONSOLE_COLOR_YELLOW, Client, inet:peername(Client), ?CONSOLE_COLOR_NORMAL]),
	io:fwrite("~w~s~w~s~n", [Recv, ?CONSOLE_COLOR_GREEN, calendar:local_time(), ?CONSOLE_COLOR_NORMAL]),

	case Recv of
		{ok, <<"HELP\r\n">>} ->
			gen_tcp:send(Client, "FLAG:{YouMuffinHead}+10points"),
			gen_tcp:close(Client);
		_ -> gen_tcp:close(Client)
	end.


