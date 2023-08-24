defmodule PostingImageWeb.PostLive.FormComponent do
  use PostingImageWeb, :live_component

  alias PostingImage.Images

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage post records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        phx-drop-target={@uploads.avatar.ref}
      >
        <.input field={@form[:username]} type="text" label="Username" />
        <.input field={@form[:descrption]} type="text" label="Descrption" />
        <form id="upload-form" phx-submit="save" phx-change="validate">
          <.live_file_input upload={@uploads.avatar} />
          <button type="submit">Upload</button>
        </form>

        <section class="flex flex-col gap-1">
          <div class="flex flex-wrap gap-1">
            <%= for entry <- @uploads.avatar.entries do %>
              <article class="upload-entry">
                <figure>
                  <.live_img_preview class="h-48 w-48 rounded-lg object-cever" entry={entry} />
                  <figcaption class="text-sm font-bold text-purple-600 text-center">
                    <%= entry.client_name %>
                  </figcaption>
                </figure>

                <div class="flex gap-2 justify-center items-center">
                  <progress class="h-1.5 bg-gray-600" value={entry.progress} max="100">
                    <%= entry.progress %>%
                  </progress>
                  <button
                    type="button"
                    phx-click="cancel-upload"
                    phx-value-ref={entry.ref}
                    aria-label="cancel"
                  >
                    &times;
                  </button>
                </div>

                <%= for err <- upload_errors(@uploads.avatar, entry) do %>
                  <p class="alert alert-danger text-bold text-center text-red-600 font-mono">
                    <%= error_to_string(err) %>
                  </p>
                <% end %>
              </article>
            <% end %>
          </div>

          <%= for err <- upload_errors(@uploads.avatar) do %>
            <p class="alert alert-danger text-bold text-left text-red-600 font-mono">
              <%= error_to_string(err) %>
            </p>
          <% end %>
        </section>

        <:actions>
          <.button phx-disable-with="Saving...">Save Post</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Images.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg), max_entries: 3)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Images.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        dest =
          Path.join([:code.priv_dir(:posting_image), "static", "uploads", Path.basename(path)])

        File.cp!(path, dest)
        {:ok, ~p"/uploads/#{Path.basename(dest)}"}
      end)

    post_params =
      unless Enum.empty?(uploaded_files) do
        Map.replace(post_params, "uploaded_files", true)
      else
        post_params
      end

    save_post(socket, socket.assigns.action, post_params)
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref} = _params, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp save_post(socket, :edit, post_params) do
    case Images.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    case Images.create_post(post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  def error_to_string(:too_large), do: "Too large"
  def error_to_string(:not_accepted), do: "You have selected an unacceptable file type"

  def error_to_string(:too_many_files), do: "You have selected too many files"
end
