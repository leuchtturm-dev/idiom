defmodule Idiom.Idiom.TTest do
  use ExUnit.Case, async: true

  alias Idiom.Cache

  require UseIdiom

  setup_all do
    "test/data.json"
    |> File.read!()
    |> Jason.decode!()
    |> Cache.init(:t_test)
  end

  describe "without bindings" do
    tests = [
      # With key
      %{key: "hello", opts: [cache_table_name: :t_test], expected: "hello"},
      %{key: "foo", opts: [cache_table_name: :t_test], expected: "bar"},
      # With key and explicit target language
      %{key: "hello", opts: [to: "fr", cache_table_name: :t_test], expected: "bonjour"},
      %{key: "hello", opts: [to: "es", cache_table_name: :t_test], expected: "hola"},
      # With key and namespace
      %{
        key: "create.account",
        opts: [namespace: "signup", cache_table_name: :t_test],
        expected: "Create your account"
      },
      # With key, namespace and target language
      %{
        key: "create.account",
        opts: [to: "de", namespace: "signup", cache_table_name: :t_test],
        expected: "Erstelle dein Konto"
      },
      # With key, target language and fallback
      %{
        key: "hello",
        opts: [to: "zh", fallback: "es", cache_table_name: :t_test],
        expected: "hola"
      },
      %{
        key: "hello",
        opts: [to: "zh", fallback: ["fr", "es"], cache_table_name: :t_test],
        expected: "bonjour"
      },
      # With key, namespace, target language and fallback
      %{
        key: "create.account",
        opts: [to: "de", namespace: "signup", fallback: "de", cache_table_name: :t_test],
        expected: "Erstelle dein Konto"
      },
      # With plural
      %{
        key: "carrot",
        opts: [count: 1, cache_table_name: :t_test],
        expected: "1 carrot"
      },
      %{
        key: "carrot",
        opts: [count: 2, cache_table_name: :t_test],
        expected: "2 carrots"
      },
      # With ordinal plural
      %{
        key: "cake",
        opts: [count: 1, plural: :ordinal, cache_table_name: :t_test],
        expected: "1st cake"
      },
      %{
        key: "cake",
        opts: [count: 2, plural: :ordinal, cache_table_name: :t_test],
        expected: "2nd cake"
      },
      %{
        key: "cake",
        opts: [count: 10, plural: :ordinal, cache_table_name: :t_test],
        expected: "10th cake"
      },
      # With plural key and explicit suffix
      %{
        key: "carrot_one",
        opts: [count: 2, cache_table_name: :t_test],
        expected: "1 carrot"
      },
      # With different scripts
      %{
        key: "Hello world",
        opts: [to: "ar", cache_table_name: :t_test],
        expected: "مرحبا بالعالم"
      },
      %{
        key: "Hello world",
        opts: [to: "zh", cache_table_name: :t_test],
        expected: "你好世界"
      },
      %{
        key: "Hello world",
        opts: [to: "ja", cache_table_name: :t_test],
        expected: "こんにちは世界"
      },
      # With emoji
      %{
        key: "Welcome to our site 😊",
        opts: [cache_table_name: :t_test],
        expected: "Welcome to our site 😊"
      }
    ]

    for %{key: key, opts: opts, expected: expected} <- tests do
      test "function - correctly translates `#{key}` with opts `#{inspect(opts)}`" do
        assert Idiom.t(unquote(key), unquote(opts)) == unquote(expected)
      end

      test "macro - correctly translates `#{key}` with opts `#{inspect(opts)}`" do
        assert UseIdiom.t(unquote(key), unquote(opts)) == unquote(expected)
      end
    end
  end

  describe "with bindings" do
    tests = [
      # With basic interpolation
      %{
        key: "welcome",
        bindings: Macro.escape(%{name: "foo"}),
        opts: [cache_table_name: :t_test],
        expected: "welcome, foo"
      },
      # With plural
      %{
        key: "carrot",
        bindings: Macro.escape(%{count: 3}),
        opts: [count: 2, cache_table_name: :t_test],
        expected: "3 carrots"
      }
    ]

    for %{key: key, bindings: bindings, opts: opts, expected: expected} <- tests do
      test "function - correctly translates `#{key}` with bindings `#{inspect(bindings)}` and opts `#{inspect(opts)}`" do
        assert Idiom.t(unquote(key), unquote(bindings), unquote(opts)) ==
                 unquote(expected)
      end

      test "macro - correctly translates `#{key}` with bindings `#{inspect(bindings)}` and opts `#{inspect(opts)}`" do
        assert UseIdiom.t(unquote(key), unquote(bindings), unquote(opts)) == unquote(expected)
      end
    end
  end
end
