defmodule Mix.Tasks.Idiom.Extract do
  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Idiom.Extract.run()
  end
end
