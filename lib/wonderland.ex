defmodule Wonderland do
  @moduledoc """
  Elixir functional programming foundation
  """

  defmacro __using__(opts) do
    quote location: :keep do
      use Wonderland.Combinator
      use Wonderland.Data
      use Wonderland.TypeClass, unquote(opts)
      :ok
    end
  end
end
