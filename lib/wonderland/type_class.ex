defmodule Wonderland.TypeClass do
  defmacro __using__(opts) do
    quote location: :keep do
      use Wonderland.TypeClass.Wonder, unquote(opts)
      use Wonderland.TypeClass.Functor, unquote(opts)
      use Wonderland.TypeClass.Monad, unquote(opts)
      use Wonderland.TypeClass.Applicative, unquote(opts)
      use Wonderland.TypeClass.Bifunctor, unquote(opts)
      :ok
    end
  end

  defmacro define_using do
    quote location: :keep do
      defmacro __using__(opts) do
        as =
          case opts do
            [] -> :import
            [as: x] -> x
          end

        module_alias =
          [
            __MODULE__
            |> Module.split()
            |> List.last()
          ]
          |> Module.concat()

        case as do
          :import ->
            quote location: :keep do
              require unquote(__MODULE__), as: unquote(module_alias)
              import unquote(__MODULE__)
            end

          :require ->
            quote location: :keep do
              require unquote(__MODULE__), as: unquote(module_alias)
            end
        end
      end
    end
  end
end
