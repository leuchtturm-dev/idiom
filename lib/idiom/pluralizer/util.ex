defmodule Idiom.Pluralizer.Util do
  def in?(number, range) when is_integer(number) do
    number in range
  end

  def in?(number, first..last) when is_float(number) do
    number == trunc(number) && number >= first && number <= last
  end

  def mod(number, modulus) when is_float(number) and is_number(modulus) do
    number - Float.floor(number / modulus) * modulus
  end

  def mod(number, modulus) when is_integer(number) and is_integer(modulus) do
    modulo =
      number
      |> Integer.floor_div(modulus)
      |> Kernel.*(modulus)

    number - modulo
  end

  def mod(number, modulus) when is_integer(number) and is_number(modulus) do
    modulo =
      number
      |> Kernel./(modulus)
      |> Float.floor()
      |> Kernel.*(modulus)

    number - modulo
  end
end
