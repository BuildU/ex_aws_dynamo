# Originally authored by Nick Marino, @nickelization
# Download a copy of DDB local (if necessary) and start it, for use by ExAws.DynamoIntegrationTest
support_dir = "test/support"
ddb_url = "https://s3-us-west-2.amazonaws.com/dynamodb-local/dynamodb_local_latest.tar.gz"
ddb_dir = Path.join(support_dir, "dynamodb_local_latest")
ddb_jar = Path.join(ddb_dir, "DynamoDBLocal.jar")
ddb_tgz = Path.join(support_dir, "dynamodb_local_latest.tar.gz")
ddb_port = Application.get_env(:ex_aws, :dynamodb, [])[:port]

defmodule Util do
  def dir_is_empty(dir) do
    File.ls!(dir) == []
  end

  def wait_for_ddb_start(port, retries_left \\ 50) do
    case DDBLocal.try_connect() do
      :ok ->
        IO.puts "Connected to DynamoDB! DynamoDB confirmed running."
      {:error, error} when retries_left == 0 ->
        IO.puts "Timed out waiting for DynamoDB to start! Giving up!"
        IO.puts "Last error was #{inspect error}"
        exit({:shutdown, 1})
      {:error, _} ->
        :timer.sleep(200)
        wait_for_ddb_start(port, retries_left - 1)
    end
  end
end

IO.puts "Checking for an existing test copy of DynamoDB..."

if !File.dir?(ddb_dir) or Util.dir_is_empty(ddb_dir) do
  IO.puts "No copy of DynamoDB found! Downloading a test copy to #{support_dir}..."

  # If we haven't downloaded/expanded DynamoDB local yet, grab a copy,
  # but delete any existing files first in case we have
  # an incomplete/outdated copy:
  if File.exists?(ddb_tgz) do
    IO.puts "Found existing DynamoDB archive file, deleting..."
    File.rm!(ddb_tgz)
  end

  IO.puts "Downloading DynamoDB from #{ddb_url}"

  System.cmd("curl", ["-o", ddb_tgz, ddb_url])

  IO.puts "Decompressing DynamoDB archive..."
  File.mkdir_p!(ddb_dir)
  System.cmd("tar", ["-zxf", ddb_tgz, "-C", ddb_dir])
else
  IO.puts "Found existing copy of DynamoDB. Continuing..."
end

# Now that DynamoDB is definitely downloaded and decompressed, we
# can go ahead and start it up (but start it in a separate process
# so that the script can continue and exit without blocking on the
# System.cmd call).
if DDBLocal.try_connect() != :ok do
  spawn(fn -> DDBLocal.start_ddb(ddb_dir, ddb_jar) end)
  # Wait until we can connect to DynamoDB to make sure we don't exit
  # the script and kill the start_ddb process before it gets a chance
  # to call System.cmd at all:
  IO.puts "Waiting to confirm DynamoDB has started..."
  Util.wait_for_ddb_start(ddb_port)
else
  IO.puts "DynamoDB test port is bound, assuming it's already started."
end

IO.puts "\n --- DynamoDB test harness setup complete! --- \n"
