defmodule LiveViewStudioWeb.PaginateLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    # Instead of pattern-matching the params, we just pluck them out.
    # If they do not exist, we use default values.
    #
    # For this example, we can assign all the state in handle_params since it
    # all changes as we navigate from page to page.
    page = String.to_integer(params["page"] || "1")
    per_page = String.to_integer(params["per_page"] || "5")

    paginate_options = %{page: page, per_page: per_page}
    donations = Donations.list_donations(paginate: paginate_options)

    socket =
      assign(socket,
        options: paginate_options,
        donations: donations
      )

    {:noreply, socket}
  end

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)
    %{assigns: %{options: %{page: page}}} = socket

    # When push_patch is invoked, handle_params is invoked immediately to handle
    # the change in parameters and update the state. Then the new diff and the
    # new URL are pushed back to the client, and the browser's location is
    # updated to that URL.
    # So by doing this , we are basically navigating to the current LiveView
    # with updated URL params, but we are initiating is from the server side.
    socket =
      push_patch(
        socket,
        to:
          Routes.live_path(
            socket,
            __MODULE__,
            page: page,
            per_page: per_page
          )
      )

    {:noreply, socket}
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "eat-now", else: "fresh"
  end

  defp pagination_link(socket, text: text, page: page, per_page: per_page, class: class) do
    live_patch(text,
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          page: page,
          per_page: per_page
        ),
      replace: false,
      class: class
    )
  end
end
