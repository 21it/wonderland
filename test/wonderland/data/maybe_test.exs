defmodule Wonderland.Data.MaybeTest do
  use ExUnit.Case
  use Wonderland
  doctest Maybe

  setup do
    {:ok, %{just: Maybe.just(1), nothing: Maybe.nothing()}}
  end

  test "constructors", %{just: j, nothing: n} do
    assert Maybe.is?(j)
    assert Maybe.is?(n)
  end

  test "checkers", %{just: j, nothing: n} do
    assert Maybe.is_just?(j)
    assert Maybe.is_nothing?(n)

    refute Maybe.is_just?(n)
    refute Maybe.is_nothing?(j)
  end

  test "get", %{just: j, nothing: n} do
    assert 1 == Maybe.get(j)
    assert nil == Maybe.get(n)
  end

  test "get!", %{just: j, nothing: n} do
    assert 1 == Maybe.get!(j)

    assert_raise RuntimeError,
                 "Can't get! from Wonderland.Data.Maybe.nothing",
                 fn ->
                   Maybe.get!(n)
                 end
  end

  test "fmap just", %{just: j} do
    x = (&(&1 * 3)) <~ j
    assert 3 == Maybe.get!(x)
  end

  test "fmap nothing", %{nothing: n} do
    x0 = (&(&1 * 3)) <~ n
    assert Maybe.is_nothing?(x0)

    x1 = fn _ -> raise("BANG!!!") end <~ n
    assert Maybe.is_nothing?(x1)
  end

  test "flip fmap just", %{just: j} do
    x = j ~> (&(&1 * 3))
    assert 3 == Maybe.get!(x)
  end

  test "flip fmap nothing", %{nothing: n} do
    x0 = n ~> (&(&1 * 3))
    assert Maybe.is_nothing?(x0)

    x1 = n ~> fn _ -> raise("BANG!!!") end
    assert Maybe.is_nothing?(x1)
  end

  test "bind just", %{just: j} do
    x0 = j >>> (&Maybe.just(&1 * 3))
    assert 3 == Maybe.get!(x0)

    x1 = j >>> fn _ -> Maybe.nothing() end
    assert Maybe.is_nothing?(x1)
  end

  test "bind nothing", %{nothing: n} do
    x0 = n >>> (&Maybe.just(&1 * 3))
    assert Maybe.is_nothing?(x0)

    x1 = n >>> fn _ -> raise("BANG!!!") end
    assert Maybe.is_nothing?(x1)
  end

  test "failed bind", %{just: j} do
    assert_raise RuntimeError,
                 "Expected value of Wonderland.Data.Maybe from function passed to Monad.bind, but got 1",
                 fn ->
                   j >>> (& &1)
                 end
  end

  test "ap just", %{just: j} do
    x = (&Kernel.+/2) <~ j <<~ j
    assert 2 == Maybe.get!(x)
  end

  test "ap just + nothing", %{just: j, nothing: n} do
    x0 = (&Kernel.+/2) <~ n <<~ j
    assert Maybe.is_nothing?(x0)

    x1 = (&Kernel.+/2) <~ j <<~ n
    assert Maybe.is_nothing?(x1)

    x2 = (&Kernel.+/2) <~ n <<~ n
    assert Maybe.is_nothing?(x2)
  end
end
