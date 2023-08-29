defmodule Idiom.Compiler do
  defmacro __before_compile__(_env) do
    quote unquote: false do
      defmacro t_extract(key, opts) do
        file = __CALLER__.file
        key = Idiom.Compiler.expand_to_binary(key, __CALLER__)
        namespace = Keyword.get(opts, :namespace) |> Idiom.Compiler.expand_to_binary(__CALLER__)
        has_count? = Keyword.has_key?(opts, :count)

        if is_binary(key) and Application.get_env(:idiom, :extracting?) do
          :ets.insert(:extracted_keys, {%{file: file, key: key, namespace: namespace, has_count?: has_count?}})
        end
      end

      defmacro t(key, opts) when is_list(opts) do
        quote do
          if Idiom.Compiler.compiling?() do
            t_extract(unquote(key), unquote(opts))
          end

          Idiom.t(unquote(key), %{}, unquote(opts))
        end
      end

      defmacro t(key, bindings \\ Macro.escape(%{}), opts \\ Macro.escape([])) do
        quote do
          if Idiom.Compiler.compiling?() do
            t_extract(unquote(key), unquote(opts))
          end

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

  def compiling? do
    process_alive?(:can_await_module_compilation?)
  end

  defp process_alive?(:can_await_module_compilation?) do
    Code.ensure_loaded?(Code) &&
      apply(Code, :can_await_module_compilation?, [])
  end
end
