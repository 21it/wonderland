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

  defmacro unlift(x) do
    quote location: :keep do
      x = unquote(x)
      {:module, mod} = :erlang.fun_info(x, :module)
      mod.wonder_unlift(x)
    end
  end
end
