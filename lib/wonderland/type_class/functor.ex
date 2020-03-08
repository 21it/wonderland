defmodule Wonderland.TypeClass.Functor do
  import Wonderland.TypeClass
  define_using()

  @typep a :: term
  @typep b :: term
  @type t(x) :: __MODULE__.t(x)

  @callback functor_fmap((a -> b), t(a)) :: t(b)

  defmacro fmap(f, it) do
    quote location: :keep do
      it = unquote(it)
      {:module, mod} = :erlang.fun_info(it, :module)

      unquote(f)
      |> Kare.curry()
      |> mod.functor_fmap(it)
    end
  end

  defmacro f <~ it do
    quote location: :keep do
      unquote(__MODULE__).fmap(unquote(f), unquote(it))
    end
  end

  defmacro it ~> f do
    quote location: :keep do
      unquote(__MODULE__).fmap(unquote(f), unquote(it))
    end
  end
end
