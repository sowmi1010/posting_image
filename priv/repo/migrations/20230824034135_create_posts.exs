defmodule PostingImage.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :username, :string
      add :descrption, :string
    end
  end
end
