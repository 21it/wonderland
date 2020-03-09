# Wonderland

<img src="priv/img/logo.png" alt="logo"/>

Tons of boring `case`, `if` or `with` low level expressions and boilerplate pattern matching clauses with guards is not functional programming. Real functional programming is **fun**. It operates with highly reusable polymorphic abstractions and compositions of them. Welcome to the Wonderland, Elixir functional programming foundation!

## Quick Start

```elixir
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
```

And then let's have some fun with Applicatives:

```elixir
iex(2)> use Wonderland
:ok
iex(3)> import Demo
Demo
iex(4)> x = parse("1999-01-23")
#Function<3.132474729/2 in Wonderland.Data.Either.eval/2>
iex(5)> y = parse("2000-01-23")
#Function<3.132474729/2 in Wonderland.Data.Either.eval/2>
iex(6)> z = parse("2020-01-23")
#Function<3.132474729/2 in Wonderland.Data.Either.eval/2>
iex(7)> bad = parse("1999-99-99")
#Function<3.132474729/2 in Wonderland.Data.Either.eval/2>
iex(8)> (&between?/3) <~ x <<~ bad <<~ z |> unlift
{:error, "1999-99-99 is invalid_date"}
iex(9)> (&between?/3) <~ x <<~ y <<~ z |> unlift
{:ok, true}
iex(10)> (&between?/3) <~ x <<~ z <<~ y |> unlift
{:ok, false}
```

## Boundary

Wonders (Wonderland abstractions) are well encapsulated, and they can not leak or be corrupted by boring reality. Interaction with regular Elixir is always explicit: `lift/2` lifts Elixir expression into Wonderland, and `unlift/1` is acting opposite:

```elixir
@spec lift(term, type) :: wonder
@spec unlift(wonder) :: term
```

## Translation Table

| Type Class  | Function  | Haskell |  Elixir  |
|-------------|-----------|---------|----------|
| Functor     | fmap      |   <$>   |   <~     |
| Functor     | flip fmap |   <&>   |   ~>     |
| Monad       | bind      |   >>=   |   >>>    |
| Applicative | ap        |   <*>   |   <<~    |

## Installation

The package can be installed by adding `wonderland` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:wonderland, "~> 0.2"}
  ]
end
```
