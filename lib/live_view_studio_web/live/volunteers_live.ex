defmodule LiveViewStudioWeb.VolunteersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Volunteers
  alias LiveViewStudio.Volunteers.Volunteer

  def mount(_params, _session, socket) do
    volunteers = Volunteers.list_volunteers()

    changeset = Volunteers.change_volunteer(%Volunteer{})

    socket =
      assign(socket,
        volunteers: volunteers,
        changeset: changeset
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

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("create_volunteer", %{"volunteer" => params}, socket) do
    case Volunteers.create_volunteer(params) do
      {:ok, volunteer} ->
        # Prepend the newly-created volunteer to the list.
        socket =
          update(
            socket,
            :volunteers,
            fn volunteers -> [volunteer | volunteers] end
          )

        # Clear the form.
        changeset = Volunteers.change_volunteer(%Volunteer{})
        socket = assign(socket, changeset: changeset)

        # A short delay so that we can see the disabled button text.
        :timer.sleep(500)

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        # This changeset has validation errors.
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  def handle_event("toggle_status", %{"id" => id}, socket) do
    volunteer = Volunteers.get_volunteer!(id)

    # Although update_volunteer can return an error tuple there is no reason it
    # should so we pattern match an OK tuple and just let it fail otherwise.
    {:ok, _volunteer} = Volunteers.toggle_status_of_volunteer(volunteer)

    # We need to re-fetch a collection from the database because `volunteers` is
    # a temporary assign.
    volunteers = Volunteers.list_volunteers()

    socket = assign(
      socket,
      volunteers: volunteers
    )

    {:noreply, socket}
  end
end
