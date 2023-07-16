defmodule Idiom.Pluralizer.Util do
  def in?(%Decimal{} = number, range) do
    Decimal.to_float(number) |> in?(range)
  end

  def in?(number, range) when is_integer(number) do
    number in range
  end

  def in?(number, range) when is_float(number) do
    trunc(number) in range
  end

  def mod(dividend, divisor) when is_float(dividend) and is_number(divisor) do
    dividend - Float.floor(dividend / divisor) * divisor
  end

  def mod(dividend, divisor) when is_integer(dividend) and is_integer(divisor) do
    modulo =
      dividend
      |> Integer.floor_div(divisor)
      |> Kernel.*(divisor)

    dividend - modulo
  end

  def mod(dividend, divisor) when is_integer(dividend) and is_number(divisor) do
    modulo =
      dividend
      |> Kernel./(divisor)
      |> Float.floor()
      |> Kernel.*(divisor)

    dividend - modulo
  end

  def mod(%Decimal{} = dividend, %Decimal{} = divisor) do
    modulo =
      dividend
      |> Decimal.div(divisor)
      |> Decimal.round(0, :floor)
      |> Decimal.mult(divisor)

    Decimal.sub(dividend, modulo)
  end

  def mod(%Decimal{} = dividend, divisor) when is_integer(divisor), do: mod(dividend, Decimal.new(divisor))
end
