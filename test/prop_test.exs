defmodule WonderlandPropTest do
  use ExUnit.Case
  use Wonderland
  use PropCheck

  defmacro lhs <~> rhs do
    quote location: :keep do
      unlift(unquote(lhs)) == unlift(unquote(rhs))
    end
  end

  defp everything do
    weighted_union([
      {5, any()},
      {1, exactly(nil)}
    ])
  end

  defp functor do
    let [x <- everything(), m <- oneof([Maybe, Either])] do
      case m do
        Maybe -> lift(x, Maybe)
        Either -> lift(x, Either)
      end
    end
  end

  describe "Functor" do
    property "first law" do
      quickcheck(
        forall x <- functor() do
          x <~> fmap(&id/1, x)
        end
      )
    end

    property "second law" do
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
        numtests: 1000
      )
    end
  end
end
