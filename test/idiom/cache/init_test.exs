defmodule Idiom.Cache.InitTest do
  use ExUnit.Case, async: false

  alias Idiom.Cache

  setup do
    default_table_name = Cache.default_table_name()

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
end
