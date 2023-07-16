defmodule Idiom.Languages do
  def to_resolve_hierarchy(code, opts \\ []) do
    fallback = Keyword.get(opts, :fallback)

    ([code, get_script_part_from_code(code), get_language_part_from_code(code)] ++ List.wrap(fallback))
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  def get_language_part_from_code(code) do
    if String.contains?(code, "-") do
      String.replace(code, "_", "-") |> String.split("-") |> List.first()
    else
      code
    end
  end

  defp get_script_part_from_code(code) do
    if String.contains?(code, "-") do
      String.replace(code, "_", "-")
      |> String.split("-")
      |> case do
        nil -> nil
        parts when is_list(parts) and length(parts) == 2 -> nil
        # TODO: Format language code
        parts when is_list(parts) -> Enum.take(parts, 2) |> Enum.join("-")
      end
    else
      code
    end
  end
end
