defmodule WonderlandPropTest do
  use ExUnit.Case
  use Wonderland
  use PropCheck

  @numtests 100

  @monads [Maybe, Either]
  @functors [Maybe, Either]
  @applicatives [Maybe]

  #
  # utils
  #

  defmacro lhs <~> rhs do
    quote location: :keep do
      unlift(unquote(lhs)) == unlift(unquote(rhs))
    end
  end

  defp type_of(x) do
    {:module, mod} = :erlang.fun_info(x, :module)
    mod
  end

  defp dynamic_lift(x, m) do
    case m do
      Maybe -> lift(x, Maybe)
      Either -> lift(x, Either)
      Thunk -> lift(x, Thunk)
    end
  end

  defmacro mk_pure(t) do
    quote location: :keep do
      pure = fn x -> dynamic_lift(x, unquote(t)) end
    end
  end

  #
  # generators
  #

  defp everything do
    weighted_union([
      {10, any()},
      {1, exactly(nil)}
    ])
  end

  defp functor do
    let [x <- everything(), t <- oneof(@functors)] do
      dynamic_lift(x, t)
    end
  end

  defp monad, do: monad(Maybe.nothing())

  defp monad(t) do
    let [x <- everything(), m <- oneof(@monads)] do
      case Maybe.is_just?(t) do
        true -> dynamic_lift(x, unlift(t))
        false -> dynamic_lift(x, m)
      end
    end
  end

  defp applicative, do: applicative(Maybe.nothing())

  defp applicative(mt) do
    let [x <- everything(), t <- oneof(@applicatives)] do
      case Maybe.is_just?(mt) do
        true -> dynamic_lift(x, unlift(mt))
        false -> dynamic_lift(x, t)
      end
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
        forall [
          x <- any(),
          f <- function([any()], monad())
        ] do
          rhs = f.(x)
          lhs = dynamic_lift(x, type_of(rhs)) >>> f
          lhs <~> rhs
        end,
        numtests: @numtests
      )
    end

    property "right identity" do
      quickcheck(
        forall [
          m <- monad()
        ] do
          lhs = m >>> (&dynamic_lift(&1, type_of(m)))
          rhs = m
          lhs <~> rhs
        end,
        numtests: @numtests
      )
    end

    property "associativity" do
      quickcheck(
        forall [
          x <- monad()
        ] do
          t = type_of(x) |> Maybe.just()

          forall [
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
        forall [
          x <- applicative()
        ] do
          pure = type_of(x) |> mk_pure()
          lhs = pure.(&id/1) <<~ x
          rhs = x
          lhs <~> rhs
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
