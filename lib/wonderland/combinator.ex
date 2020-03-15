defmodule Wonderland.Combinator do
  defmacro __using__(_) do
    quote location: :keep do
      import unquote(__MODULE__)
    end
  end

  require Wonderland.Data.Thunk, as: Thunk
  require Wonderland.TypeClass.Wonder, as: Wonder

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

  @doc """
  Creates Thunk from expression

  iex> x = "BOOM" |> raise |> lazy
  iex> Thunk.is?(x)
  true
  """
  defmacro lazy(x) do
    quote location: :keep do
      unquote(Wonder).lift(unquote(x), unquote(Thunk))
    end
  end

  @doc """
  Recursively evaluates Thunk

  iex> x = 2 * 2 |> lazy
  iex> y = "BOOM" |> raise |> lazy
  iex> strict(x)
  4
  iex> strict(y)
  ** (RuntimeError) BOOM
  """
  def strict(x) do
    case Thunk.is?(x) do
      true -> x |> Thunk.wonder_unlift() |> strict()
      false -> x
    end
  end

  def compose(g, f) do
    &g.(f.(&1))
  end

  defmacro void do
    quote location: :keep do
      fn -> raise "void has been applied" end
    end
  end
end
