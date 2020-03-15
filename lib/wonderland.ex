defmodule Wonderland do
  @moduledoc """
  Elixir functional programming foundation
  """

  defmacro __using__(opts) do
    quote location: :keep do
      use Wonderland.Combinator
      use Wonderland.Data
      use Wonderland.TypeClass, unquote(opts)
      import Kare, only: [curry: 1]
      :ok
    end
  end
end
