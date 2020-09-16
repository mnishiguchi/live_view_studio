defmodule LiveViewStudioWeb.FilterLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Boats

  def mount(_params, _session, socket) do
    # This assigns all the boats to the socket and it renders them. This is a
    # stateful process so those boats are kept in memory. They do not need to be
    # kept in memory because when we handle the filter event, we load an
    # entirely new list of boats from the database and assign those boats to the
    # socket. In general, anytime the data comes from a database, temporary
    # assigns is a great option because you can just load the data from the
    # database again. If you had hundreds of thousands of these processes
    # saving a small amount of memory in each one really adds up.
    socket =
      assign(socket,
        boats: Boats.list_boats(),
        type: "",
        prices: []
      )

    # We want the boats to be reset to an empty list after render. That way
    # they are not held in memory.
    {:ok, socket, temporary_assigns: [boats: []]}
  end

  def render(assigns) do
    ~L"""
    <h1>Daily Boat Rentals</h1>

    <div id="filter">
      <form phx-change="filter">
        <div class="filters">
          <select name="type">
            <%= options_for_select(type_options(), @type) %>
          </select>

          <div class="prices">
            <input type="hidden" name="prices[]" value="" />
            <%= for price <- ["$", "$$", "$$$"] do %>
              <%= render_price_checkbox(price: price, checked: price in @prices) %>
            <% end %>
          </div>
        </div>
      </form>

      <div class="boats">
        <%= for boat <- @boats do %>
          <div class="card">
            <img src="<%= boat.image %>">
            <div class="content">
              <div class="model">
                <%= boat.model %>
              </div>
              <div class="details">
                <span class="price">
                  <%= boat.price %>
                </span>
                <span class="type">
                  <%= boat.type %>
                </span>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_event("filter", %{"type" => type, "prices" => prices}, socket) do
    filter_params = [type: type, prices: prices]
    boats = Boats.list_boats(filter_params)
    socket = assign(socket, filter_params ++ [boats: boats])
    {:noreply, socket}
  end

  defp type_options do
    [
      "All Types": "",
      Fishing: "fishing",
      Sporting: "sporting",
      Sailing: "sailing"
    ]
  end

  defp render_price_checkbox(assigns) do
    # Anytime we have a LiveView template like this, it expects a variable named
    # assigns that is a map to be in scope. Else CompileError will be raised.
    # It gives us the ability to use @ sign to reference state variables in the
    # template.
    assigns = Enum.into(assigns, %{})

    ~L"""
    <input type="checkbox" id="<%= @price %>"
          name="prices[]" value="<%= @price %>"
          <%= if @checked, do: "checked" %> />
    <label for="<%= @price %>"><%= @price %></label>
    """
  end
end
