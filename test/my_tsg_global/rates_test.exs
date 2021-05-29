defmodule MyTsgGlobal.RatesTest do
  use MyTsgGlobal.DataCase

  alias MyTsgGlobal.Rates

  describe "buy_rates" do
    test "list_buy_rates/0 returns all buy_rates" do
      buy_rate = TestHelper.create_buy_rate()
      assert Rates.list_buy_rates() == [buy_rate]
    end
  end

  describe "sell_rates" do
    test "list_sell_rates/0 returns all sell_rates" do
      sell_rate = TestHelper.create_sell_rate()
      assert Rates.list_sell_rates() == [sell_rate]
    end
  end
end
