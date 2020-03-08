defmodule Wonderland.Combinator do
  defmacro __using__(_) do
    quote location: :keep do
      import unquote(__MODULE__)
    end
  end

  @doc """
  ## Examples

  ```
  iex> id(1)
  1
  """
  def id(x), do: x

  @doc """
  ## Examples

  ```
  iex> const(:foo, :bar)
  :foo
  iex> const(:foo).(:bar)
  :foo
  """
  def const(x, _), do: x
  def const(x), do: &const(x, &1)
end
