defmodule Wonderland.Data do
  defmacro __using__(_) do
    quote location: :keep do
      require Wonderland.Data.Maybe, as: Maybe
      require Wonderland.Data.Either, as: Either
      require Wonderland.Data.Thunk, as: Thunk
      :ok
    end
  end
end
