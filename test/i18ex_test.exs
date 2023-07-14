defmodule IdiomTest do
  use ExUnit.Case, async: true

  defp start_client do
    base_name = UUID.uuid4() |> String.to_atom()
    name = Idiom.Supervisor.client_name(base_name)

    options = [
      name: name
    ]

    {:ok, _pid} = start_supervised({Client, options})

    {:ok, base_name}
  end
end
