defmodule Wonderland.TypeClass.Bifunctor do
  import Wonderland.TypeClass
  define_using()

  @typep a :: term
  @typep b :: term
  @typep c :: term
  @typep d :: term
  @type t(x, y) :: __MODULE__.t(x, y)

  @callback bifunctor_bimap((a -> b), (c -> d), t(a, c)) :: t(b, d)

  defmacro bimap(f, g, x) do
    quote location: :keep do
      x = unquote(x)
      {:module, mod} = :erlang.fun_info(x, :module)

      cf =
        unquote(f)
        |> Kare.curry()

      cg =
        unquote(g)
        |> Kare.curry()

      mod.bifunctor_bimap(cf, cg, x)
    end
  end

  defmacro first(f, x) do
    quote location: :keep do
      bimap(unquote(f), &Wonderland.Combinator.id/1, unquote(x))
    end
  end

  defmacro second(g, x) do
    quote location: :keep do
      bimap(&Wonderland.Combinator.id/1, unquote(g), unquote(x))
    end
  end

  #
  # Elixir-friendly flipped versions
  #

  defmacro ex_bimap(x, f, g) do
    quote location: :keep do
      bimap(unquote(f), unquote(g), unquote(x))
    end
  end

  defmacro ex_first(x, f) do
    quote location: :keep do
      first(unquote(f), unquote(x))
    end
  end

  defmacro ex_second(x, g) do
    quote location: :keep do
      second(unquote(g), unquote(x))
    end
  end
end
