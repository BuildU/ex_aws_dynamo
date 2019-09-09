if Mix.shell().yes?("Run local DynamoDB on port #{DDBLocal.get_ddb_port()} and execute integration test module? If a local copy of DynamoDB is not available, it will be installed to test/support/dynamodb_local_latest (gitignored).") do
  Mix.Task.run "run", ["test/support/fetch_and_start_ddb.exs"]
end

ExUnit.start()
