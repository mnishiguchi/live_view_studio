defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias Phoenix.LiveView.Socket
  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    if connected?(socket), do: Volunteers.subscribe()

    socket =
      assign(socket,
        volunteers: Volunteers.list_volunteers(),
        changeset: Volunteers.change_volunteer(%Volunteer{})
      )

    # We do not need to hold on to or track volunteers after they have been
    # rendered. So this would be a good scenario for making the volunteers' list
    # as being temporary.
    {:ok, socket, temporary_assigns: [volunteers: []]}
  end

  def handle_event("validate_volunteer", %{"volunteer" => params}, socket) do
    changeset =
      %Volunteer{}
      |> Volunteers.change_volunteer(params)
      # Without this, we will not see any inline validation errors.
      # The action is normally set for us such as when we call `Repo.insert`.
      # But in this situation, we are just trying to validate the data and we
      # have not called a repo function so we have to specify the action of the
      # changeset.
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("create_volunteer", %{"volunteer" => params}, socket) do
    case Volunteers.create_volunteer(params) do
      {:ok, _volunteer} ->
        # Clear the form.
        changeset = Volunteers.change_volunteer(%Volunteer{})
        {:noreply, assign(socket, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        # This changeset has validation errors.
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("toggle_status", %{"id" => id}, socket) do
    # Although update_volunteer can return an error tuple there is no reason it
    # should so we pattern match an OK tuple and just let it fail otherwise.
    {:ok, _volunteer} =
      id
      |> Volunteers.get_volunteer!()
      |> Volunteers.toggle_status_of_volunteer()

    # We do not need to re-fetch a collection from the database because we
    # subscribe for changes and handlers will update the state.

    {:noreply, socket}
  end

  def handle_info({:volunteer_created, volunteer}, socket) do
    {:noreply, prepend_volunteer_to_list(socket, volunteer)}
  end

  def handle_info({:volunteer_updated, volunteer}, socket) do
    {:noreply, prepend_volunteer_to_list(socket, volunteer)}
  end

  defp prepend_volunteer_to_list(%Socket{} = socket, %Volunteer{} = volunteer) do
    # Even if we are prepending the entry to the list here, it wont be prepended
    # to the list in the DOM, because the ID of this entry already exists in the
    # DOM list, so it'll just be replaced with the updated entry instead.
    update(socket, :volunteers, &[volunteer | &1])
  end
end
