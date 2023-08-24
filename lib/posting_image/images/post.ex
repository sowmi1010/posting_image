defmodule PostingImage.Images.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :username, :string
    field :descrption, :string
    field :uploaded_files, {:array, :string}, default: []
    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:username, :descrption])
    |> validate_required([:username, :descrption])
  end
end
