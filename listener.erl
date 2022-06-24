#!/usr/bin/env escript
-module(listener).
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
    loop_acceptor(Socket, 10).

loop_acceptor(Socket, Num) ->
    io:fwrite("~s[POOL] ~w~s~n", [?CONSOLE_COLOR_YELLOW, Num, ?CONSOLE_COLOR_NORMAL]),
    {ok, Client} = gen_tcp:accept(Socket),
    if
        Num > 1 ->
            process_flag(trap_exit, true),
            spawn_link(fun() -> serve(Client) end),
            receive
                {'EXIT', _, _} ->
                    loop_acceptor(Socket, Num)
            after 1 ->
                    loop_acceptor(Socket, Num - 1)
            end;

        true ->
            receive
                _ ->
                    loop_acceptor(Socket, Num + 1)
            after 0 ->
                    loop_acceptor(Socket, Num)
            end
    end.

serve(Client) ->
    Recv = gen_tcp:recv(Client, 0),
    io:fwrite("~s~w~s", [?CONSOLE_COLOR_BLUE,  inet:peername(Client), ?CONSOLE_COLOR_NORMAL]),
    io:fwrite("~p~s~w~s~n", [Recv, ?CONSOLE_COLOR_GREEN, calendar:local_time(), ?CONSOLE_COLOR_NORMAL]),

    case Recv of
        {ok, <<"HELP\r\n">>} ->
            gen_tcp:send(Client, "FLAG:{YouMuffinHead}+10points\r\n"),
            gen_tcp:close(Client);
        _ -> gen_tcp:close(Client)
    end.


