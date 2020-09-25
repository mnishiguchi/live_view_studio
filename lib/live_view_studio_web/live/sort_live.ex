defmodule LiveViewStudioWeb.SortLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  @default_page 1
  @default_per_page 5
  @default_sort_by :id
  @default_sort_order :asc

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    # Instead of pattern-matching the params, we just pluck them out.
    # If they do not exist, we use default values.
    #
    # For this example, we can assign all the state in handle_params since it
    # all changes as we navigate from page to page.
    paginate_options = %{
      page: build_option_value(:page, params["page"]),
      per_page: build_option_value(:per_mage, params["per_page"])
    }

    sort_options = %{
      sort_by: build_option_value(:sort_by, params["sort_by"]),
      sort_order: build_option_value(:sort_order, params["sort_order"])
    }

    donations =
      Donations.list_donations(
        paginate: paginate_options,
        sort: sort_options
      )

    socket =
      socket
      |> assign(
        options: Map.merge(paginate_options, sort_options),
        donations: donations
      )

    case donations do
      [] ->
        socket = put_flash(socket, :error, "Ran out of items")
        {:noreply, socket}

      _ ->
        socket = clear_flash(socket)
        {:noreply, socket}
    end
  end

  defp build_option_value(:page, nil), do: @default_page
  defp build_option_value(:page, value) when is_binary(value), do: String.to_integer(value)

  defp build_option_value(:per_mage, nil), do: @default_per_page
  defp build_option_value(:per_mage, value) when is_binary(value), do: String.to_integer(value)

  defp build_option_value(:sort_by, nil), do: @default_sort_by
  defp build_option_value(:sort_by, value) when is_binary(value), do: String.to_atom(value)

  defp build_option_value(:sort_order, nil), do: @default_sort_order
  defp build_option_value(:sort_order, value) when is_binary(value), do: String.to_atom(value)

  def handle_event("select-per-page", %{"per-page" => per_page}, socket) do
    per_page = String.to_integer(per_page)

    # When push_patch is invoked, handle_params is invoked immediately to handle
    # the change in parameters and update the state. Then the new diff and the
    # new URL are pushed back to the client, and the browser's location is
    # updated to that URL.
    # So by doing this , we are basically navigating to the current LiveView
    # with updated URL params, but we are initiating is from the server side.
    socket =
      push_patch(socket,
        to:
          Routes.live_path(socket, __MODULE__,
            page: socket.assigns.options.page,
            per_page: per_page,
            sort_by: socket.assigns.options.sort_by,
            sort_order: socket.assigns.options.sort_order
          )
      )

    {:noreply, socket}
  end

  defp expires_class(donation) do
    if Donations.almost_expired?(donation), do: "eat-now", else: "fresh"
  end

  defp sort_link(socket, text, sort_by, %{} = options) do
    text =
      if sort_by == options.sort_by,
        do: "#{text} #{sort_icon(options.sort_order)}",
        else: text

    pagination_link(
      socket,
      text,
      Map.merge(
        options,
        %{
          sort_by: sort_by,
          sort_order: toggle_sort_order(options.sort_order)
        }
      )
    )
  end

  defp toggle_sort_order(:asc), do: :desc
  defp toggle_sort_order(:desc), do: :asc
  defp sort_icon(:asc), do: "↓"
  defp sort_icon(:desc), do: " ↑"

  defp pagination_link(socket, text, %{} = options) do
    live_patch(text,
      to:
        Routes.live_path(socket, __MODULE__,
          page: options.page,
          per_page: options.per_page,
          sort_by: options.sort_by,
          sort_order: options.sort_order
        ),
      replace: options[:replace],
      class: options[:class]
    )
  end
end
