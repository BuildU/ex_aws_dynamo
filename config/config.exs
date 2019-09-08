use Mix.Config

config :ex_aws,
  debug_requests: true,
  access_key_id: "abcd",
  secret_access_key: "1234",
  region: "us-east-1"

config :ex_aws, :dynamodb,
  scheme: "http://",
  host: "localhost",
  region: "us-east-1"

import_config "#{Mix.env}.exs"
