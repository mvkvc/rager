defmodule Rager.Search do
  # alias Rager.Search.Result
  alias Rager.Search.Providers.Exa
  alias Rager.Search.Providers.Serper

  # Configure keys to read from Application.get_env

  defstruct query: nil,
            engine: :serper,
            n_results: 5,
            max_length: 1_000

  @engines [:serper, :exa]
  @engine_lookup %{
    :serper => Serper,
    :exa => Exa,
  }

  def run(%__MODULE__{engine: engine} = search) when engine in @engines do
    Map.get(@engine_lookup, engine).search(search)
  end
end
