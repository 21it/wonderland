defmodule Wonderland.TypeClass.Wonder do
  import Wonderland.TypeClass
  define_using()

  @typep a :: term
  @type t() :: __MODULE__.t()

  @callback wonder_lift(a) :: t() | no_return()
  @callback wonder_unlift(t()) :: a

  defmacro lift(x, mod) do
    quote location: :keep do
      unquote(mod).wonder_lift(unquote(x))
    end
  end

  def unlift(x) when is_function(x) do
    {:module, mod} = :erlang.fun_info(x, :module)

    try do
      x
      |> mod.wonder_unlift()
      |> unlift()
    rescue
      e in UndefinedFunctionError ->
        case e do
          %UndefinedFunctionError{function: :wonder_unlift, arity: 1} -> x
          _ -> reraise(e, __STACKTRACE__)
        end
    end
  end

  def unlift(x), do: x
end
