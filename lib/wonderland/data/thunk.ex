defmodule Wonderland.Data.Thunk do
  use Calculus
  use Wonderland.TypeClass

  @moduledoc """
  Enables lazy evaluation

  ## Examples

  iex> use Wonderland
  iex> x = "BANG" |> raise() |> lift(Thunk)
  iex> unlift(x)
  ** (RuntimeError) BANG
  """

  defcalculus state, export_return: false, generate_opaque: false do
    :wonder_unlift -> calculus(return: state.())
  end

  @behaviour Wonder
  @impl true
  def wonder_lift(x), do: construct(x)
  @impl true
  def wonder_unlift(x), do: eval(x, :wonder_unlift)
end
