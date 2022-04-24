defmodule Server do
  require Logger

  def accept(port) do
    # The options below mean:
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blocks on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: 0, active: false, reuseaddr: true])
    Logger.info("Accepting connections on port #{port}")
    loop_acceptor(socket)
  end


  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.debug("accept: " <> inspect(client))
    case :gen_tcp.recv(client, 0) |> IO.inspect(limit: :infinity) do
      {:ok, "HELP\r\n"} -> :gen_tcp.send(client, "FLAG:{YouMuffinHead}+10points")
      #{:ok, "\r\n\r\n"} -> :gen_tcp.send(client, "FLAG:{YouMuffinHead}~10points")
      _ -> nil
    end
    loop_acceptor(socket)
  end
end
Server.accept(3306)

