defmodule PostingImage.ImagesTest do
  use PostingImage.DataCase

  alias PostingImage.Images

  describe "posts" do
    alias PostingImage.Images.Post

    import PostingImage.ImagesFixtures

    @invalid_attrs %{username: nil, descrption: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Images.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Images.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{username: "some username", descrption: "some descrption"}

      assert {:ok, %Post{} = post} = Images.create_post(valid_attrs)
      assert post.username == "some username"
      assert post.descrption == "some descrption"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Images.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{username: "some updated username", descrption: "some updated descrption"}

      assert {:ok, %Post{} = post} = Images.update_post(post, update_attrs)
      assert post.username == "some updated username"
      assert post.descrption == "some updated descrption"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Images.update_post(post, @invalid_attrs)
      assert post == Images.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Images.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Images.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Images.change_post(post)
    end
  end
end
