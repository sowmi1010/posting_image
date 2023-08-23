defmodule PostingImage.Repo do
  use Ecto.Repo,
    otp_app: :posting_image,
    adapter: Ecto.Adapters.Postgres
end
