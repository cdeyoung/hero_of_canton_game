defmodule Debug do
  @moduledoc """
  Debug functions.
  """

  @doc """
  Accept a value and a label and then print the value in a block of text. Return the original value
  so this can be used in a pipeline.

  ## Examples

      Debug.puts(variable, label_string)

      iex> Debug.puts("test_value", "test value")
      "test_value"
  """
  def puts(value, str) do
    IO.puts("################################################################################")
    IO.inspect(value, label: String.upcase(str))
    IO.puts("################################################################################")
    value
  end
end
