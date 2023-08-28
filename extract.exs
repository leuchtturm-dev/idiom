# scripts/schema_validator.exs
defmodule SchemaValidator do
  def run() do
    :ets.new(:schemas, [:named_table, :public])
    Mix.Task.clear()
    Mix.Task.run("compile", ["--force", "--tracer", __MODULE__])
  end

  @spec trace(tuple, Macro.Env.t()) :: :ok
  def trace({:remote_function, meta, Idiom, name, arity} = tuple, env) do
    IO.inspect(tuple)
  end

  def trace(_, _), do: :ok
end

SchemaValidator.run()
