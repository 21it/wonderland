defmodule WonderlandTest do
  use ExUnit.Case
  doctest Wonderland

  test "greets the world" do
    assert Wonderland.hello() == :world
  end
end
