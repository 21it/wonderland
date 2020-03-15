defmodule Wonderland.Data.Either do
  use Calculus
  use Wonderland.TypeClass
  use Wonderland.Combinator

  @moduledoc """
  Classic sum type which represents 2 alternatives

  - Bifunctor
  - Functor (as right)
  - Monad (as right)
  - Applicative (as right)
  """

  @typep a :: term
  @typep b :: term
  @type t(a, b) :: __MODULE__.t(a, b)

  defmacrop leftp(x) do
    quote location: :keep do
      {:leftp, unquote(x)}
    end
  end

  defmacrop rightp(x) do
    quote location: :keep do
      {:rightp, unquote(x)}
    end
  end

  defcalculus state,
    export_return: false,
    generate_opaque: false,
    generate_return: false do
    method when method in [:is_left?, :is_right?] ->
      case state do
        leftp(_) -> calculus(return: method == :is_left?)
        rightp(_) -> calculus(return: method == :is_right?)
      end

    {:functor_fmap, f} ->
      case state do
        leftp(_) -> calculus(return: state |> construct)
        rightp(x) -> calculus(return: f.(x) |> rightp |> construct)
      end

    {:monad_bind, f} ->
      case state do
        leftp(_) -> calculus(return: state |> construct)
        rightp(x) -> calculus(return: f.(x))
      end

    {:applicative_ap, mf} ->
      case unlift(mf) do
        {:ok, f} ->
          case state do
            leftp(_) -> calculus(return: state |> construct)
            rightp(x) -> calculus(return: f.(x) |> rightp |> construct)
          end

        {:error, _} ->
          calculus(return: mf)
      end

    :wonder_unlift ->
      case state do
        leftp(x) -> calculus(return: {:error, x})
        rightp(x) -> calculus(return: {:ok, x})
      end

    {:bifunctor_bimap, f, g} ->
      case state do
        leftp(x) -> calculus(return: f.(x) |> leftp |> construct)
        rightp(x) -> calculus(return: g.(x) |> rightp |> construct)
      end
  end

  @doc """
  First constructor

  ## Examples

  ```
  iex> x = Either.left(1)
  iex> Either.is_left?(x)
  true
  ```
  """
  @spec left(a) :: t(a, b)
  def left(x), do: x |> leftp |> construct

  @doc """
  Second constructor

  ## Examples

  ```
  iex> x = Either.right(1)
  iex> Either.is_right?(x)
  true
  ```
  """
  @spec right(b) :: t(a, b)
  def right(x), do: x |> rightp |> construct

  @doc """
  If argument is `left(x)` then returns `true`
  If argument is `right(x)` then returns `false`
  Otherwise raise exception

  ## Examples

  ```
  iex> x = Either.left(1)
  iex> y = Either.right(1)
  iex> Either.is_left?(x)
  true
  iex> Either.is_left?(y)
  false
  ```
  """
  @spec is_left?(t(a, b)) :: boolean
  def is_left?(x), do: eval(x, :is_left?)

  @doc """
  If argument is `right(x)` then returns `true`
  If argument is `left(x)` then returns `false`
  Otherwise raise exception

  ## Examples

  ```
  iex> x = Either.left(1)
  iex> y = Either.right(1)
  iex> Either.is_right?(x)
  false
  iex> Either.is_right?(y)
  true
  ```
  """
  @spec is_right?(t(a, b)) :: boolean
  def is_right?(x), do: eval(x, :is_right?)

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
  def wonder_lift(x) when x in [nil, :undefined, :error, false], do: left(void())
  def wonder_lift(x) when x in [:ok, true], do: right(x)
  def wonder_lift({:error, x}), do: left(x)
  def wonder_lift({:ok, x}), do: right(x)
  def wonder_lift(x), do: right(x)
  @impl true
  def wonder_unlift(x), do: eval(x, :wonder_unlift)

  @behaviour Bifunctor
  @impl true
  def bifunctor_bimap(f, g, x), do: eval(x, {:bifunctor_bimap, f, g})
end
