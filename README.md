# Wonderland

Tons of boring `case`, `if` or `with` low level expressions and boilerplate pattern matching clauses with guards is not functional programming. Real functional programming is **fun** and operates with highly reusable polymorphic abstractions and compositions of them. Welcome to the Wonderland, Elixir functional programming foundation!

<img src="priv/img/logo.png" alt="logo"/>

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
