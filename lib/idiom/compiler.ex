defmodule Idiom.Compiler do
  defmacro __before_compile__(_env) do
    quote do
      unquote(macros())
    end
  end

  defp macros() do
    quote unquote: false do
      defmacro t_extract(key, opts) do
        if Application.get_env(:idiom, :extracting?) do
          file = __CALLER__.file
          key = Idiom.Compiler.expand_to_binary(key, __CALLER__)
          namespace = Keyword.get(opts, :namespace) |> Idiom.Compiler.expand_to_binary( __CALLER__)
          has_count? = Keyword.has_key?(opts, :count) 

          if is_binary(key) do
            :ets.insert(:extracted_keys, {%{file: file, key: key, namespace: namespace, has_count?: has_count?}})
          end
        else
          :noop
        end
      end

      defmacro t(key, opts) when is_list(opts) do
        quote do
          t_extract(unquote(key), unquote(opts))

          Idiom.t(unquote(key), %{}, unquote(opts))
        end
      end

      defmacro t(key, bindings \\ Macro.escape(%{}), opts \\ Macro.escape([])) do
        quote do
          t_extract(unquote(key), unquote(opts))

          Idiom.t(unquote(key), unquote(bindings), unquote(opts))
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
