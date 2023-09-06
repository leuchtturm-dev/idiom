defmodule Idiom.Formats.Lokalise do
  @moduledoc false
  def transform(data, namespace) do
    data
    |> Enum.map(fn %{"iso" => locale, "items" => items} ->
      Map.new([{locale, %{namespace => transform_items(items)}}])
    end)
    |> Enum.reduce(%{}, fn locale, acc -> Map.merge(acc, locale) end)
  end

  defp transform_items(items) do
    items
    |> Enum.map(&transform_item(&1))
    |> List.flatten()
    |> Map.new()
  end

  defp transform_item(%{"key" => key, "value" => value}) do
    # Key can either be a string or a stringified JSON object
    case Jason.decode(value) do
      {:ok, decoded_value} -> transform_item(key, decoded_value)
      {:error, _error} -> transform_item(key, value)
    end
  end

  defp transform_item(key, value) when is_binary(value), do: {key, value}

  defp transform_item(key, value) when is_map(value) do
    Enum.map(value, fn {suffix, value} -> {"#{key}_#{suffix}", value} end)
  end
end
