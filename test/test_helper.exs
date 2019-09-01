defmodule TestHelper do
  alias ExAws.Dynamo

  def delete_test_tables() do
    Dynamo.delete_table("Users") |> ExAws.request()
    Dynamo.delete_table("UsersWithRange") |> ExAws.request()
    Dynamo.delete_table(Test.User) |> ExAws.request()
    Dynamo.delete_table("SeveralUsers") |> ExAws.request()
    Dynamo.delete_table(Foo) |> ExAws.request()
    Dynamo.delete_table("books") |> ExAws.request()
    :ok
  end

end

ExUnit.start()
