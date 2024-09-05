defmodule Rager.LLM.Provider do
  @callback result()
  @callback stream()
end
