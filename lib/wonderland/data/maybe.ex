defmodule Wonderland.Data.Maybe do
  use Calculus
  use Wonderland.TypeClass

  @moduledoc """
  Classic sum type `Maybe`
  Implements Monad, Functor and Applicative behaviours
  """

  defmacrop justp(x) do
    quote location: :keep do
      {:justp, unquote(x)}
    end
  end

  defmacrop nothingp, do: :nothingp

  @get_error "Can't get! from #{inspect(__MODULE__)}.nothing"

  defcalculus state, export_return: false, generate_opaque: false do
    :get ->
      case state do
        justp(x) -> calculus(state: state, return: x)
        nothingp() -> calculus(state: state, return: nil)
      end

    :get! ->
      case state do
        justp(x) -> calculus(state: state, return: x)
        nothingp() -> raise(@get_error)
      end

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
            justp(x) -> calculus(state: justp(get!(mf).(x)), return: :ok)
            nothingp() -> calculus(state: state, return: :ok)
          end

        false ->
          calculus(state: nothingp(), return: :ok)
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
  If argument is `just(a)` then returns `a`, otherwise returns `nil`

  ## Examples

  ```
  iex> j = Maybe.just(1)
  iex> n = Maybe.nothing()
  iex> Maybe.get(j)
  1
  iex> Maybe.get(n)
  nil
  ```
  """
  @spec get(t(a)) :: a | nil
  def get(it), do: it |> eval(:get) |> return()

  @doc """
  If argument is `just(a)` then returns `a`, otherwise raise exception

  ## Examples

  ```
  iex> j = Maybe.just(1)
  iex> n = Maybe.nothing()
  iex> Maybe.get!(j)
  1
  iex> Maybe.get!(n)
  ** (RuntimeError) Can't get! from Wonderland.Data.Maybe.nothing
  ```
  """
  @spec get!(t(a)) :: a | no_return
  def get!(it), do: it |> eval(:get!) |> return()

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
end
