defmodule PostingImage.ImagesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PostingImage.Images` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        username: "some username",
        descrption: "some descrption"
      })
      |> PostingImage.Images.create_post()

    post
  end
end
