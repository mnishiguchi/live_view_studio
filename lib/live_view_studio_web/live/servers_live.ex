defmodule LiveViewStudioWeb.ServersLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Servers
  alias LiveViewStudio.Servers.Server

  def mount(_params, _session, socket) do
    servers = Servers.list_servers()

    # Using temporary_assigns is not a good fit for this because server list is
    # needed when a live-patch link is clicked.
    socket =
      assign(socket,
        servers: servers
      )

    {:ok, socket}
  end

  @doc """
  ## When `handle_params` is invoked

  1. when the LiveView is mounted.
  2. when a link generated by `live_patch` is clicked.

  ## Where to assign state

  - In `handle_params` if you have state the can change as you navigate based on
  URL query params.
  - In mount otherwise.

  """
  def handle_params(%{"id" => id}, _url, socket) do
    id = String.to_integer(id)
    server = Servers.get_server!(id)

    socket =
      assign(socket,
        selected_server: server,
        page_title: server.name
      )

    {:noreply, socket}
  end

  # Handles a URL with no params.
  def handle_params(_params, _url, socket) do
    case socket.assigns.live_action do
      :new ->
        socket =
          assign(socket,
            selected_server: nil,
            changeset: Servers.change_server(%Server{})
          )

        {:noreply, socket}

      _ ->
        socket =
          assign(socket,
            selected_server: hd(socket.assigns.servers)
          )

        {:noreply, socket}
    end
  end

  def handle_event("validate_server", %{"server" => params}, socket) do
    changeset =
      %Server{}
      |> Servers.change_server(params)
      |> Map.put(:action, :insert)

    socket = assign(socket, changeset: changeset)
    {:noreply, socket}
  end

  def handle_event("create_server", %{"server" => params}, socket) do
    case Servers.create_server(params) do
      {:ok, server} ->
        socket =
          socket
          # Prepend the newly-created server to the list.
          |> update(:servers, fn servers -> [server | servers] end)
          # Navigate to the new server's detail page.
          |> push_patch(
            to:
              Routes.live_path(
                socket,
                __MODULE__,
                id: server.id
              )
          )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        # This changeset has validation errors.
        socket = assign(socket, changeset: changeset)
        {:noreply, socket}
    end
  end

  # ## Difference between typical HTML href and live_patch
  #
  # - typical href: sends a new HTTP request
  # - live_patch: ensures the event is pushed to the current LiveView process
  #
  defp link_to_server(socket, server, selected_server) do
    live_patch(build_server_link_body(server),
      to:
        Routes.live_path(
          socket,
          __MODULE__,
          id: server.id
        ),
      replace: true,
      class: if(server == selected_server, do: "active")
    )
  end

  defp build_server_link_body(server) do
    assigns = %{
      name: server.name,
      status: server.status
    }

    ~L"""
    <span class="status <%= @status %>"></span>
    <img src="/images/server.svg">
    <%= @name %>
    """
  end
end
