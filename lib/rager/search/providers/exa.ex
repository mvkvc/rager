defmodule Rager.Search.Providers.Exa do
  @behaviour Rager.Search.Provider

  def search(query, opts \\ []) do
    headers = [
      {"accept", "application/json"},
      {"content-type", "application/json"},
      {"x-api-key", opts[:api_key]}
    ]

    body = %{
      query: query,
      type: "magic",
      numResults: opts[:num_results],
      contents: %{
        text: true
      }
    }

    case Req.post(
           "https://api.exa.ai/search",
           headers: headers,
           body: Jason.encode!(body)
         ) do
      {:ok, %Req.Response{status: 200, body: %{"results" => results}}} ->
        output =
          Enum.reduce(results, [], fn
            %{"title" => title, "url" => url, "text" => text}, acc ->
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
