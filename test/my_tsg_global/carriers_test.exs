defmodule MyTsgGlobal.CarriersTest do
  use MyTsgGlobal.DataCase

  alias MyTsgGlobal.Carriers

  describe "carriers" do
    test "list_posts/0 returns all posts" do
      carrier = TestHelper.create_carrier()
      assert Carriers.list_carriers() == [carrier]
    end
  end
end
