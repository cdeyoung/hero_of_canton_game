defmodule DebugTest do
  use ExUnit.Case
  doctest Debug

  describe "test the happy-path of the Debug module" do
    test "puts/2" do
      output = "test_value"
      assert Debug.puts("test_value", "test value") == output
    end
  end
end
