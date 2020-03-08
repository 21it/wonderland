defmodule Wonderland.TypeClass.Applicative do
  import Wonderland.TypeClass
  define_using()

  @typep a :: term
  @typep b :: term
  @type t(x) :: __MODULE__.t(x)

  @callback applicative_ap(t((a -> b)), t(a)) :: t(b)

  defmacro ap(mf, it) do
    quote location: :keep do
      it = unquote(it)
      {:module, mod} = :erlang.fun_info(it, :module)

      (&Kare.curry/1)
      |> Wonderland.TypeClass.Functor.fmap(unquote(mf))
      |> mod.applicative_ap(it)
    end
  end

  defmacro f <<~ it do
    quote location: :keep do
      unquote(__MODULE__).ap(unquote(f), unquote(it))
    end
  end
end
