defmodule Wonderland.TypeClass.Wonder do
  import Wonderland.TypeClass
  define_using()

  @typep a :: term
  @type t() :: __MODULE__.t()

  @callback wonder_lift(a) :: t()
  @callback wonder_unlift(t()) :: a

  defmacro lift(x, mod) do
    {m, []} = Code.eval_quoted(mod, [], __CALLER__)

    try do
      m.__info__(:functions)
    rescue
      _ -> :ok
    end

    _ = Code.ensure_loaded(m)
    true = :erlang.function_exported(m, :wonder_lift, 1)

    arg =
      case m do
        Wonderland.Data.Thunk ->
          quote location: :keep do
            fn -> unquote(x) end
          end

        _ ->
          x
      end

    quote location: :keep do
      unquote(mod).wonder_lift(unquote(arg))
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
