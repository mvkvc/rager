defmodule Rager.LLM do
  defp add_context(prompt, []), do: prompt

  defp add_context(prompt, context) do
    prompt <>
      """
      Personalized context:
      ---------------------
      #{Enum.join(context, "\n")}
      ---------------------\n
      """
  end

  defp add_search_results(prompt, []), do: prompt

  defp add_search_results(prompt, search_results) do
    prompt <>
      """
      Search results:
      ---------------
      #{Enum.join(search_results, "\n")}
      ---------------\n
      """
  end

  defp add_query(prompt, query) do
    prompt <>
      """
      Query: #{query}

      Answer:
      """
  end

  def template(query, opts \\ []) do
    prompt =
      Keyword.get(
        opts,
        :prompt,
        "Please help the user answer the following query. If additional information is given but not relevant then ignore it."
      )

    context = Keyword.get(opts, :context, [])
    search_results = Keyword.get(opts, :search_results, [])

    prompt
    |> add_context(context)
    |> add_search_results(search_results)
    |> add_query(query)
  end

  def build_history(query, opts \\ []) do
    system_prompt = Keyword.get(opts, :system_prompt, "You are a helpful assistant.")
    messages = Keyword.get(opts, :messages, [])

    Enum.concat([
      [%{role: "system", content: system_prompt}],
      messages,
      [
        %{
          role: "user",
          content: template(query, opts)
        }
      ]
    ])
  end

  defp handle_prefix({chunk, acc}) do
    if String.starts_with?(chunk, "data: ") do
      {chunk, acc}
    else
      {acc <> chunk, ""}
    end
  end

  defp handle_suffix({chunk, acc}) do
    if String.ends_with?(chunk, "\n\n") do
      {chunk, acc}
    else
      partials = String.split(chunk, "\n\n")
      {_keep, [trailing]} = Enum.split(partials, -1)
      new_chunk = String.replace_trailing(chunk, trailing, "")

      {new_chunk, trailing}
    end
  end

  defp parse_chunk(chunk) do
    chunk
    |> String.split("data: ", trim: true)
    |> Enum.reduce("", fn chunk, acc ->
      case String.trim(chunk, "\n") do
        "[DONE]" ->
          acc

        data ->
          with {:ok, json} <- Jason.decode(data),
               [_ | _] = choices <- Map.get(json, "choices"),
               choice <- List.first(choices),
               content when not is_nil(content) <- get_in(choice, ["delta", "content"]) do
            acc <> content
          else
            _ ->
              acc
          end
      end
    end)
  end

  def openai_stream_parser(chunk, acc \\ "") do
    {chunk, acc}
    |> handle_prefix()
    |> handle_suffix()
    |> (fn {chunk, acc} -> {parse_chunk(chunk), acc} end).()
  end

  def chat(query, opts \\ []) do
    base_url = Keyword.get(opts, :base_url, System.get_env("OPENAI_BASE_URL"))
    api_key = Keyword.get(opts, :api_key, System.get_env("OPENAI_API_KEY"))
    model = Keyword.get(opts, :model, System.get_env("OPENAI_MODEL"))
    stream = Keyword.get(opts, :stream, true)
    temperature = Keyword.get(opts, :temperature, 0.0)
    handler = Keyword.get(opts, :handler, fn _ -> nil end)

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    body = %{
      model: model,
      temperature: temperature,
      messages: build_history(query, opts),
      stream: stream
    }

    with %URI{scheme: "https"} <- URI.parse(base_url),
         {:ok, %{status: 200, body: body}} <-
           Req.post(base_url <> "/chat/completions",
             body: Jason.encode!(body),
             headers: headers,
             into: :self
           ) do
      {result, _acc} =
        Enum.reduce(body, {"", ""}, fn chunk, {acc_result, acc_local} ->
          {result, acc} = openai_stream_parser(chunk, acc_local)

          handler.(result)

          {acc_result <> result, acc}
        end)

      {:ok, result}
    else
      %URI{scheme: _scheme} -> {:error, "Invalid base URL"}
      {:ok, %{status: status}} -> {:error, "Request failed with status: #{status}"}
      {:error, _error} -> {:error, "Request failed"}
    end
  end
end
