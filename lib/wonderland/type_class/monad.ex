defmodule Wonderland.TypeClass.Monad do
  import Wonderland.TypeClass
  define_using()

  @typep a :: term
  @typep b :: term
  @type t(x) :: __MODULE__.t(x)

  @callback monad_bind(t(a), (a -> t(b))) :: t(b)

  defmacro bind(it, f) do
    quote location: :keep do
      it = unquote(it)
      {:module, mod} = :erlang.fun_info(it, :module)
      new_it = mod.monad_bind(it, unquote(f))

      new_it
      |> mod.is?()
      |> case do
        true ->
          new_it

        false ->
          raise(
            "Expected value of #{inspect(mod)} from function passed to Monad.bind, but got #{
              inspect(new_it)
            }"
          )
      end
    end
  end

  defmacro it >>> f do
    quote location: :keep do
      unquote(__MODULE__).bind(unquote(it), unquote(f))
    end
  end
end
