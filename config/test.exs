use Mix.Config

# When testing, we'll download and run a local version of DDB on port 8001
# so as to avoid accidentally corrupting a user's data (presumably running on port 8000, as per dev.exs)
config :ex_aws, :dynamodb,
  port: 8001
