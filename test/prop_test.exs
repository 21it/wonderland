defmodule WonderlandPropTest do
  use ExUnit.Case
  use Wonderland
  use PropCheck

  @numtests 100

  @monads [Maybe, Either]
  @functors [Maybe, Either]
  @applicatives [Maybe, Either]

  #
  # utils
  #

  defmacro lhs <~> rhs do
    quote location: :keep do
      unlift(unquote(lhs)) == unlift(unquote(rhs))
    end
  end

  defmacro mk_pure(t) do
    quote location: :keep do
      fn x ->
        case unquote(t) do
          Maybe -> lift(x, Maybe)
          Either -> lift(x, Either)
          Thunk -> lift(x, Thunk)
        end
      end
    end
  end

  #
  # generators
  #

  defp special_tuple do
    let [t <- oneof([:ok, :error]), x <- any()] do
      {t, x}
    end
  end

  defp everything do
    weighted_union([
      {8, any()},
      {1, oneof([nil, :undefined, true, false, :ok, :error])},
      {1, special_tuple()}
    ])
  end

  defp functor do
    let [x <- everything(), t <- oneof(@functors)] do
      mk_pure(t).(x)
    end
  end

  defp monad(t) do
    let x <- everything() do
      mk_pure(t).(x)
    end
  end

  defp applicative(t) do
    let x <- everything() do
      mk_pure(t).(x)
    end
  end

  #
  # properties
  #

  describe "Functor laws" do
    property "identity" do
      quickcheck(
        forall x <- functor() do
          x <~> fmap(&id/1, x)
        end,
        numtests: @numtests
      )
    end

    property "composition" do
      fmap0 = curry(fn f, x -> fmap(f, x) end)

      quickcheck(
        forall [
          x <- functor(),
          f <- function([any()], any()),
          g <- function([any()], any())
        ] do
          lhs = fmap0.(compose(g, f)).(x)
          rhs = compose(fmap0.(g), fmap0.(f)).(x)
          lhs <~> rhs
        end,
        numtests: @numtests
      )
    end
  end

  describe "Monad laws" do
    property "left identity" do
      quickcheck(
        forall t <- oneof(@monads) do
          pure = mk_pure(t)

          forall [
            x <- any(),
            f <- function([any()], monad(t))
          ] do
            lhs = pure.(x) >>> f
            rhs = f.(x)
            lhs <~> rhs
          end
        end,
        numtests: @numtests
      )
    end

    property "right identity" do
      quickcheck(
        forall t <- oneof(@monads) do
          pure = mk_pure(t)

          forall x <- monad(t) do
            lhs = x >>> pure
            rhs = x
            lhs <~> rhs
          end
        end,
        numtests: @numtests
      )
    end

    property "associativity" do
      quickcheck(
        forall t <- oneof(@monads) do
          forall [
            x <- monad(t),
            f <- function([any()], monad(t)),
            g <- function([any()], monad(t))
          ] do
            lhs = x >>> f >>> g
            rhs = x >>> (&(f.(&1) >>> g))
            lhs <~> rhs
          end
        end,
        numtests: @numtests
      )
    end
  end

  describe "Applicative laws" do
    property "identity" do
      quickcheck(
        forall t <- oneof(@applicatives) do
          pure = mk_pure(t)

          forall x <- applicative(t) do
            lhs = pure.(&id/1) <<~ x
            rhs = x
            lhs <~> rhs
          end
        end,
        numtests: @numtests
      )
    end

    property "homomorphism" do
      quickcheck(
        forall [
          t <- oneof(@applicatives),
          x <- any(),
          f <- function([any()], any())
        ] do
          pure = mk_pure(t)
          lhs = pure.(f) <<~ pure.(x)
          rhs = pure.(f.(x))
          lhs <~> rhs
        end,
        numtests: @numtests
      )
    end

    property "interchange" do
      quickcheck(
        forall [
          t <- oneof(@applicatives),
          x <- any(),
          f0 <- function([any()], any())
        ] do
          pure = mk_pure(t)
          f = pure.(f0)
          lhs = f <<~ pure.(x)
          rhs = pure.(& &1.(x)) <<~ f
          lhs <~> rhs
        end,
        numtests: @numtests
      )
    end

    property "composition" do
      quickcheck(
        forall [
          t <- oneof(@applicatives),
          x0 <- any(),
          f0 <- function([any()], any()),
          g0 <- function([any()], any())
        ] do
          pure = mk_pure(t)
          x = pure.(x0)
          f = pure.(f0)
          g = pure.(g0)
          lhs = pure.(&compose/2) <<~ f <<~ g <<~ x
          rhs = f <<~ (g <<~ x)
          lhs <~> rhs
        end,
        numtests: @numtests
      )
    end
  end
end
