defmodule WonderlandTest do
  use ExUnit.Case
  use Wonderland
  doctest Wonderland
  doctest Wonderland.Combinator

  defmodule Demo do
    use Wonderland

    @spec parse(term) :: Either.t(String.t(), Date.t())
    def parse(x) when is_binary(x) do
      x
      |> Date.from_iso8601()
      |> lift(Either)
      |> ex_first(&"#{x} is #{&1}")
    end

    def parse(x) do
      Either.left("invalid date #{inspect(x)}")
    end

    @spec between?(
            Date.t(),
            Date.t(),
            Date.t()
          ) :: boolean()
    def between?(x, y, z) do
      Date.range(x, z)
      |> Enum.member?(y)
    end
  end

  test "demo" do
    import Demo

    x = parse("1999-01-23")
    y = parse("2000-01-23")
    z = parse("2020-01-23")

    bad0 = parse("1999-99-99")
    bad1 = parse(:bad)

    left0 = (&between?/3) <~ x <<~ bad0 <<~ z
    left1 = (&between?/3) <~ x <<~ bad1 <<~ z
    right0 = (&between?/3) <~ x <<~ y <<~ z
    right1 = (&between?/3) <~ y <<~ x <<~ z

    assert Either.is_left?(left0)
    assert Either.is_left?(left1)
    assert Either.is_right?(right0)
    assert Either.is_right?(right1)

    assert {:error, "1999-99-99 is invalid_date"} = unlift(left0)
    assert {:error, "invalid date :bad"} = unlift(left1)
    assert {:ok, true} = unlift(right0)
    assert {:ok, false} = unlift(right1)
  end
end
