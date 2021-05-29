defmodule MyTsgGlobal.ClientsTest do
  use MyTsgGlobal.DataCase

  alias MyTsgGlobal.Clients

  describe "clients" do
    test "list_posts/0 returns all posts" do
      client = TestHelper.create_client()
      assert Clients.list_clients() == [client]
    end
  end
end
