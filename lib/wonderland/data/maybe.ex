defmodule Wonderland.Data.Maybe do
  use Calculus
  use Wonderland.TypeClass

  defmacrop justp(x) do
    quote location: :keep do
      {:justp, unquote(x)}
    end
  end

  defmacrop nothingp, do: :nothingp

  defcalculus state, export_return: false, generate_opaque: false do
    method when method in [:is_just?, :is_nothing?] ->
      case state do
        justp(_) -> calculus(state: state, return: method == :is_just?)
        nothingp() -> calculus(state: state, return: method == :is_nothing?)
      end

    {:functor_fmap, f} ->
      case state do
        justp(x) -> calculus(state: justp(f.(x)), return: :ok)
        nothingp() -> calculus(state: state, return: :ok)
      end

    {:monad_bind, f} ->
      case state do
        justp(x) -> calculus(state: state, return: f.(x))
        nothingp() -> calculus(state: state, return: nothing())
      end

    {:applicative_ap, mf} ->
      case is_just?(mf) do
        true ->
          case state do
            justp(x) -> calculus(state: justp(unlift(mf).(x)), return: :ok)
            nothingp() -> calculus(state: state, return: :ok)
          end

        false ->
          calculus(state: nothingp(), return: :ok)
      end

    :wonder_unlift ->
      case state do
        justp(x) -> calculus(state: state, return: x)
        nothingp() -> calculus(state: state, return: nil)
      end
  end

  @typep a :: term
  @opaque t(a) :: t(a)

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
  def is_just?(it), do: it |> eval(:is_just?) |> return()

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
  def is_nothing?(it), do: it |> eval(:is_nothing?) |> return()

  @behaviour Functor
  @impl true
  def functor_fmap(f, it), do: it |> eval({:functor_fmap, f})

  @behaviour Monad
  @impl true
  def monad_bind(it, f), do: it |> eval({:monad_bind, f}) |> return()

  @behaviour Applicative
  @impl true
  def applicative_ap(mf, it), do: it |> eval({:applicative_ap, mf})

  @behaviour Wonder
  @impl true
  def wonder_lift(x) when x in [nil, :undefined], do: nothing()
  def wonder_lift(x), do: just(x)
  @impl true
  def wonder_unlift(x), do: x |> eval(:wonder_unlift) |> return()
end
