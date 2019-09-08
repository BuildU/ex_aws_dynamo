defmodule DDBLocal do
  @moduledoc """
  Helper methods for working with local DDB during testing.
  """

  def start_ddb(dir, jar) do
    port = get_ddb_port()
    IO.puts "Starting test DynamoDB on port #{port}..."
    System.cmd("java", ["-Djava.library.path=#{dir}", "-jar", jar,
                        "-inMemory", "-sharedDb", "-port", inspect(port)])
  end

  def stop_ddb() do
    port = get_ddb_port()
    IO.puts "Stopping test DynamoDB on port #{port}..."
    :os.cmd(:"kill `lsof -i :#{port} | grep -v COMMAND | awk '{print $2}'`")
  end

  # The fetch_and_start_ddb.exs script and integration test module will check for a local running instance of DynamoDB.
  def try_connect() do
    case :gen_tcp.connect('localhost', get_ddb_port(), []) do
      {:ok, _}        -> :ok
      {:error, error} -> {:error, error}
    end
  end

  defp get_ddb_port(), do: Application.get_env(:ex_aws, :dynamodb, [])[:port]
end
