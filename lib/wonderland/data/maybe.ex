defmodule Wonderland.Data.Maybe do
  use Calculus
  use Wonderland.TypeClass

  @typep a :: term
  @type t(a) :: __MODULE__.t(a)

  defmacrop justp(x) do
    quote location: :keep do
      {:justp, unquote(x)}
    end
  end

  defmacrop nothingp, do: :nothingp

  defcalculus state,
    export_return: false,
    generate_opaque: false,
    generate_return: false do
    method when method in [:is_just?, :is_nothing?] ->
      case state do
        justp(_) -> calculus(return: method == :is_just?)
        nothingp() -> calculus(return: method == :is_nothing?)
      end

    {:functor_fmap, f} ->
      case state do
        justp(x) -> calculus(return: just(f.(x)))
        nothingp() -> calculus(return: nothing())
      end

    {:monad_bind, f} ->
      case state do
        justp(x) -> calculus(return: f.(x))
        nothingp() -> calculus(return: nothing())
      end

    {:applicative_ap, mf} ->
      case is_just?(mf) do
        true ->
          case state do
            justp(x) -> calculus(return: just(unlift(mf).(x)))
            nothingp() -> calculus(return: nothing())
          end

        false ->
          calculus(return: nothing())
      end

    :wonder_unlift ->
      case state do
        justp(x) -> calculus(return: x)
        nothingp() -> calculus(return: nil)
      end
  end

  @doc """
  First constructor

  ## Examples

  ```
  iex> x = Maybe.just(1)
  iex> Maybe.is_just?(x)
  true
  ```
  """
  @spec just(a) :: t(a)
  def just(x), do: x |> justp() |> construct()

  @doc """
  Second constructor

  ## Examples

  ```
  iex> x = Maybe.nothing()
  iex> Maybe.is_nothing?(x)
  true
  ```
  """
  @spec nothing :: t(a)
  def nothing, do: nothingp() |> construct()

  @doc """
  If argument is `just(a)` then returns `true`
  If argument is `nothing()` then returns `false`
  Otherwise raise exception

  ## Examples

  ```
  iex> j = Maybe.just(1)
  iex> n = Maybe.nothing()
  iex> Maybe.is_just?(j)
  true
  iex> Maybe.is_just?(n)
  false
  ```
  """
  @spec is_just?(t(a)) :: boolean
  def is_just?(x), do: eval(x, :is_just?)

  @doc """
  If argument is `nothing()` then returns `true`
  If argument is `just(a)` then returns `false`
  Otherwise raise exception

  ## Examples

  ```
  iex> j = Maybe.just(1)
  iex> n = Maybe.nothing()
  iex> Maybe.is_nothing?(n)
  true
  iex> Maybe.is_nothing?(j)
  false
  ```
  """
  @spec is_nothing?(t(a)) :: boolean
  def is_nothing?(x), do: eval(x, :is_nothing?)

  @behaviour Functor
  @impl true
  def functor_fmap(f, x), do: eval(x, {:functor_fmap, f})

  @behaviour Monad
  @impl true
  def monad_bind(x, f), do: eval(x, {:monad_bind, f})

  @behaviour Applicative
  @impl true
  def applicative_ap(mf, x), do: eval(x, {:applicative_ap, mf})

  @behaviour Wonder
  @impl true
  def wonder_lift(x) when x in [nil, :undefined], do: nothing()
  def wonder_lift(x), do: just(x)
  @impl true
  def wonder_unlift(x), do: eval(x, :wonder_unlift)
end
