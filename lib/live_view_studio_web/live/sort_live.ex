defmodule LiveViewStudioWeb.SortLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Donations

  @default_page 1
  @default_per_page 5
  @permitted_sort_bys ~w[id item quantity days_until_expires]
  @permitted_sort_orders ~w[asc desc]

  def mount(_params, _session, socket) do
    {:ok, socket, temporary_assigns: [donations: []]}
  end

  def handle_params(params, _url, socket) do
    # Instead of pattern-matching the params, we just pluck them out.
    # If they do not exist, we use default values.
    #
    # For this example, we can assign all the state in handle_params since it
    # all changes as we navigate from page to page.

    paginate_options = build_paginate_options(params)
    sort_options = build_sort_options(params)

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

  defp build_paginate_options(params) do
    page = param_to_integer(params["page"], @default_page)
    per_page = param_to_integer(params["per_page"], @default_per_page)

    %{page: page, per_page: per_page}
  end

  defp build_sort_options(params) do
    sort_by =
      params
      |> param_or_first_permitted("sort_by", @permitted_sort_bys)
      |> String.to_atom()

    sort_order =
      params
      |> param_or_first_permitted("sort_order", @permitted_sort_orders)
      |> String.to_atom()

    sort_options = %{sort_by: sort_by, sort_order: sort_order}
  end

  # It's always wise to be suspicious of URL params and validate them in the
  # `handle_params` callback. One way to do that is to check if a received URL
  # parameter is in a list of permitted parameters.
  defp param_or_first_permitted(params, key, permitted) do
    value = params[key]
    if value in permitted, do: value, else: hd(permitted)
  end

  # TODO: You could even start to put generic helper functions like this in a
  # separate module so they could be invoked from other LiveView modules.
  defp param_to_integer(nil, default_value), do: default_value

  defp param_to_integer(param, default_value) do
    case Integer.parse(param) do
      {number, _} -> number
      :error -> default_value
    end
  end

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
    # Notice that it uses the pin operator (^) to pattern match against the
    # sort_by field's existing value. So it has the same effect of checking for
    # equivalence.
    link_text =
      case options do
        %{sort_by: ^sort_by, sort_order: sort_order} -> "#{text} #{sort_icon(sort_order)}"
        _ -> text
      end

    pagination_link(
      socket,
      link_text,
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
