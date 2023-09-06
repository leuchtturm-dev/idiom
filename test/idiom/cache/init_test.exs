defmodule Idiom.Cache.InitTest do
  use ExUnit.Case, async: false

  alias Idiom.Cache

  setup do
    default_table_name = Cache.cache_table_name()

    on_exit(fn ->
      if :ets.info(default_table_name) != :undefined do
        :ets.delete(default_table_name)
      end
    end)

    %{default_table_name: default_table_name}
  end

  test "initializes a public ETS with read concurrency table", %{
    default_table_name: default_table_name
  } do
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
    data = "test/data.json" |> File.read!() |> Jason.decode!()

    Cache.init(data)

    assert default_table_name
           |> :ets.tab2list()
           |> Map.new() ==
             %{
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
               {"fr", "default", "hello"} => "bonjour",
               {"ar", "default", "Hello world"} => "مرحبا بالعالم",
               {"en", "default", "Welcome to our site 😊"} => "Welcome to our site 😊",
               {"ja", "default", "Hello world"} => "こんにちは世界",
               {"zh", "default", "Hello world"} => "你好世界",
               {"en", "default", "cake_one"} => "1st cake",
               {"en", "default", "cake_other"} => "{{count}}th cake",
               {"en", "default", "cake_two"} => "2nd cake"
             }
  end
end
