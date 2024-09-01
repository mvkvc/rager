defmodule Rager.LLM.Providers.OpenAI do
  defp extract_text_result(result) do
    try do
      result
      |> Map.get("choices")
      |> List.first()
      |> get_in(["message", "content"])
    rescue
      _ -> ""
    end
  end

  defp extract_text_chunk(chunk) do
    chunk
    |> String.trim()
    |> String.split("data: ")
    |> Enum.reduce("", fn str, acc ->
      if str == "[DONE]" do
        acc
      else
        str_formatted =
          str
          |> String.trim()
          |> (fn s -> if String.starts_with?(s, "{\""), do: s, else: "{\"#{s}" end).()
          |> (fn s -> if String.ends_with?(s, "}"), do: s, else: "#{s}}" end).()

        case Jason.decode(str_formatted) do
          {:ok, decoded} ->
            text =
              try do
                decoded
                |> Map.get("choices", [])
                |> List.first()
                |> get_in(["delta", "content"])
              rescue
                _ -> ""
              end

            acc <> text

          {:error, _} ->
            acc
        end
      end
    end)
  end
end
