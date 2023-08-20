defmodule Idiom.Cache.InitTest do
  use ExUnit.Case, async: true
  alias Idiom.Cache

  setup do
    %{default_table_name: Cache.cache_table_name()}
  end

  test "initializes a public ETS with read concurrency table", %{default_table_name: default_table_name} do
    Cache.init()
    info = :ets.info(default_table_name)

    assert %{
             protection: :public,
             read_concurrency: true
           } = Map.new(info)
  end

  test "allows changing the name from default table" do
    Cache.init(%{}, :test_table)

    assert :ets.info(:test_table) != :undefined
  end

  test "allows setting initial data", %{default_table_name: default_table_name} do
    data = File.read!("test/data.json") |> Jason.decode!()

    Cache.init(data)

    assert Map.new(:ets.tab2list(default_table_name)) == %{
             {"de", "default", "butterfly"} => "Schmetterling",
             {"de", "signup", "create.account"} => "Erstelle dein Konto",
             {"en", "default", "Natural language: the colon-ing"} => "Colons",
             {"en", "default", "carrot_one"} => "1 carrot",
             {"en", "default", "carrot_other"} => "{{count}} carrots",
             {"en", "default", "deep.foo"} => "Deep bar",
             {"en", "default", "foo"} => "bar",
             {"en", "default", "hello"} => "hello",
             {"en", "default", "welcome"} => "welcome, {{name}}",
             {"en", "signup", "create.account"} => "Create your account",
             {"es", "default", "hello"} => "hola",
             {"fr", "default", "hello"} => "bonjour"
           }
  end
end
