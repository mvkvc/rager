defmodule Rager.Search do
  # alias Rager.Search.Result
  alias Rager.Search.Providers.Exa
  alias Rager.Search.Providers.Serper

  defstruct query: nil,
            engine: nil,
            key: nil,
            n_results: 5,
            max_length: 1_000

  @engines %{
    :exa => Exa,
    :serper => Serper
  }

  # def new(query, engine, key, opts \\ []) do
  #   Map.get(@engines, engine)(opts[:engine]).search(query, opts)
  # end

  def run(%__MODULE__{engine: engine} = search) do
    Map.get(@engines, engine).search(search)
  end
end
