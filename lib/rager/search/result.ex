defmodule Rager.Search.Result do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:url, :string)
    field(:title, :string)
    field(:content, :string)
  end

  def changeset(result, attrs \\ %{}) do
    result
    |> cast(attrs, [:url, :title, :content])
    |> validate_required([:url, :title, :content])
  end

  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:validate)
  end
end
