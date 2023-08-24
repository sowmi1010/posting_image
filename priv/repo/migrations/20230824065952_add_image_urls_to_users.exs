defmodule PostingImage.Repo.Migrations.AddImageUrlsToUsers do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :uploaded_files, {:array, :string}, null: false, default: []
      timestamps()
    end
  end
end
