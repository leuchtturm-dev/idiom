defmodule Idiom.Compiler do
  defmacro __before_compile__(_env) do
    quote do
      unquote(macros())
    end
  end

  defp macros() do
    quote unquote: false do
      defmacro t_extract(key, bindings, opts) do
        key =
          Idiom.Compiler.expand_to_binary(key, __CALLER__)
          |> IO.inspect(label: "key")

        namespace =
          opts[:namespace]
          |> IO.inspect(label: "ns")

        suffixes = Idiom.Plural.get_suffixes("en")

        keys_with_suffixes =
          if opts[:count],
            do: Enum.map(suffixes, fn suffix -> key <> "_" <> suffix end),
            else: [key]

        IO.inspect(keys_with_suffixes)

        key
      end

      defmacro t(key) do
        quote do
          key = t_extract(unquote(key), %{}, [])

          Idiom.t(key, %{}, [])
        end
      end

      defmacro t(key, opts) do
        quote do
          key = t_extract(unquote(key), %{}, unquote(opts))

          Idiom.t(key, %{}, unquote(opts))
        end
      end

      defmacro t(key, bindings, opts) do
        quote do
          key = t_extract(unquote(key), unquote(bindings), unquote(opts))

          Idiom.t(key, unquote(bindings), unquote(opts))
        end
      end
    end
  end

  def expand_to_binary(term, env) do
    case Macro.expand(term, env) do
      term when is_binary(term) or is_nil(term) ->
        term

      {:<<>>, _, pieces} ->
        if Enum.all?(pieces, &is_binary/1), do: Enum.join(pieces), else: nil

      _other ->
        nil
    end
  end
end
