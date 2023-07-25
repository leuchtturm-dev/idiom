defmodule Idiom.Supervisor do
  # TODO:
  @moduledoc """
  """

  use Supervisor

  alias Idiom.Cache

  def start_link(options) when is_list(options) do
    options =
      default_options()
      |> Keyword.merge(options)

    name = Keyword.fetch!(options, :name)
    Supervisor.start_link(__MODULE__, options, name: name)
  end

  defp default_options do
    [name: Idiom]
  end

  @impl Supervisor
  def init(options) do
    data = Keyword.get(options, :data, %{})
    local_data = Idiom.Source.Local.data()

    Map.merge(local_data, data)
    |> Cache.init()

    children =
      [
        {Finch, name: IdiomFinch},
        # TODO: make this configurable
        Idiom.Source.PhraseStrings
      ]
      |> Enum.reject(&is_nil/1)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
