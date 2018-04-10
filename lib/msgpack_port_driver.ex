defmodule MsgpackPortDriver.Port do
  require Logger

  @name __MODULE__

  ## Public API
  def start(external_program) do
    spawn(__MODULE__, :init, [external_program])
  end

  def stop do
    send(__MODULE__, :stop)
  end

  def call_port(func_name, args) do
    send_port({func_name |> to_string, args})
  end

  def call_port(func_name) do
    send_port({func_name |> to_string, []})
  end

  def send_port(message) do
    send(@name, {:call, self, message})
    receive do
      {@name, result} -> result
    end
  end

  ## Server API
  def init(external_program) do
    Process.register(self, @name)
    Process.flag(:trap_exit, true)
    port = Port.open({:spawn, external_program}, [packet: 2])
    Logger.info "Started MsgPack Driver "
    loop(port)
  end

  ## Private bits
  def loop(port) do
    receive do
      {:call, caller, message} ->
        send(port, {self, {:command, encode(message)}})
        receive do
          {^port, {:data, data}} ->
            send(caller, {@name, decode(data)})
        end
        loop(port)
      :stop ->
        send(port, {self, :close})
        receive do
          {^port, :closed} ->
            exit(:normal)
        end
      {'EXIT', ^port, _reason} ->
        exit(:port_terminated)
    end
  end

  def encode({cmd, args}) do
    msg_id = gen_msg_id()
    [request(), msg_id, to_string(cmd), args] |> Msgpax.pack!
  end

  def gen_msg_id(), do: :rand.uniform(100_000_000)
  def request(), do: 0

  def decode(resp) when is_list(resp) do
    [1, msg_id, errors, results] = Msgpax.unpack!(resp)

    if errors != nil do
      {:error, errors}
    else
      {:ok, results}
    end
  end
end
