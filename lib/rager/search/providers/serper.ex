defmodule Rager.Search.Providers.Serper do
  @behaviour Rager.Search.Provider

  def search(query, opts \\ []) do
    headers = [
      {"content-type", "application/json"},
      {"x-api-key", opts[:api_key]}
    ]

    body = %{
      q: query,
      num: opts[:num_results]
    }

    case Req.post(
           "https://google.serper.dev/search",
           headers: headers,
           body: Jason.encode!(body)
         ) do
      {:ok, %Req.Response{status: 200, body: %{"organic" => results}}} = _response ->
        output =
          Enum.reduce(results, [], fn
            %{"title" => title, "link" => url, "snippet" => text}, acc ->
              content = String.slice(text, 0, opts[:content_max_length])
              [%{"url" => url, "title" => title, "content" => content} | acc]

            _result, acc ->
              acc
          end)

        {:ok, output}

      {:ok, %Req.Response{status: status}} ->
        {:error, status}
    end
  end
end
