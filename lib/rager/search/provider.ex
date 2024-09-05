defmodule Rager.Search.Provider do
  alias Rager.Search.Result

  @callback search(query :: String.t(), opts :: opts()) ::
              {:ok, [Result.t()]} | {:error, String.t()}
  @type opts() :: [
          {:engine, :exa},
          {:api_key, String.t()},
          {:num_results, integer()},
          {:content_max_length, integer()}
        ]
end
