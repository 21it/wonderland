defmodule Wonderland.Data.Thunk do
  use Calculus
  use Wonderland.TypeClass

  @type t(a) :: __MODULE__.t(a)

  @moduledoc """
  Enables lazy evaluation

  ## Examples

  ```
  iex> x = "BANG" |> raise() |> lift(Thunk)
  iex> unlift(x)
  ** (RuntimeError) BANG
  ```
  """

  defcalculus state,
    export_return: false,
    generate_opaque: false,
    generate_return: false do
    :wonder_unlift -> calculus(return: state.())
  end

  @behaviour Wonder
  @impl true
  def wonder_lift(x), do: construct(x)
  @impl true
  def wonder_unlift(x), do: eval(x, :wonder_unlift)
end
