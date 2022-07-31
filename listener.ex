defmodule Server do
  require Logger
  def accept(port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: 0, active: false, reuseaddr: true])
    IO.puts(IO.ANSI.red <> "Accepting connections on port #{port}" <> IO.ANSI.reset)
    loop_acceptor(socket, 10)
  end

  defp loop_acceptor(socket, num) do
    IO.puts(IO.ANSI.yellow <> "[POOL] " <> inspect(num) <> IO.ANSI.reset)
    {:ok, client} = :gen_tcp.accept(socket)

    if num > 1 do
      spawn_link(fn -> serve(client) end)
      receive do
        # :EXIT indicates the subprocess exited
        {:EXIT, _, _} = msg ->
          IO.puts(IO.ANSI.green <> "[RECEIVE] " <> inspect(msg) <> IO.ANSI.reset)
          loop_acceptor(socket, num)
      after
        1 ->
          loop_acceptor(socket, num - 1)
      end
    else
      receive do
        {:EXIT, _, _} = msg ->
          IO.puts(IO.ANSI.red <> "[RECEIVE] " <> inspect(msg) <> IO.ANSI.reset)
          loop_acceptor(socket, num + 1)
      after
        0 ->
          loop_acceptor(socket, num)
      end
    end
  end

  defp serve(client) do
    case :gen_tcp.recv(client, 0) |> IO.inspect(limit: :infinity) do
      {:ok, "HELP\r\n"} ->
        :gen_tcp.send(client, "FLAG:{YouMuffinHead}+10points\r\n")
        :gen_tcp.close(client)
      _ -> :gen_tcp.close(client)
    end
  end
end

defmodule Server.Application do
  use Supervisor
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end
  @impl true
  def init([]) do
    port = String.to_integer(System.get_env("PORT") || "3306")
    children = [
      %{id: Server, start: {Server, :accept, [port]}}
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
Server.Application.start_link()
:timer.sleep(:infinity)
