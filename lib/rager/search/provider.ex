defmodule Rager.Search.Provider do
  @callback search(query :: String.t(), options :: options()) ::
              {:ok, map()} | {:error, String.t()}

  @type options() :: [
          {:engine, :exa},
          {:api_key, String.t()},
          {:num_results, integer()},
          {:content_max_length, integer()}
        ]
end
