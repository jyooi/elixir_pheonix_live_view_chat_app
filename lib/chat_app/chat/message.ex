defmodule ChatApp.Chat.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :user, :string
    field :body, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:user, :body])
    |> validate_required([:user, :body])
  end
end
