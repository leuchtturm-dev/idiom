defmodule I18ex.LanguageUtils do
  def to_resolve_hierarchy(code, fallback_code \\ []) do
    fallback_codes = get_fallback_codes(fallback_code, code)
  end

  def get_fallback_codes(nil, code), do: []
  def get_fallback_codes(fallbacks, _code) when is_list(fallbacks), do: fallbacks
  def get_fallback_codes(fallbacks, code) when is_function(fallbacks), do: fallbacks.(code)
  def get_fallback_codes(fallbacks, _code) when is_binary(fallbacks), do: [fallbacks]

  def get_fallback_codes(fallbacks, nil) when is_map(fallbacks),
    do: Map.get(fallbacks, :default, [])

  def get_fallback_codes(fallbacks, code) do
    Map.get(fallbacks, code) ||
      Map.get(fallbacks, get_script_part_from_code(code)) ||
      []
  end

  def get_script_part_from_code(code) do
    String.replace(code, "_", "-")
    |> String.split("-")
    |> case do
      nil -> nil
      parts when is_list(parts) and length(parts) == 2 -> nil
      # TODO: Format language code
      parts when is_list(parts) -> Enum.take(parts, 2) |> Enum.join("-")
    end
  end
end
