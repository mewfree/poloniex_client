defmodule PoloniexClientTest do
  use ExUnit.Case
  doctest PoloniexClient

  test "greets the world" do
    assert PoloniexClient.hello() == :world
  end
end
