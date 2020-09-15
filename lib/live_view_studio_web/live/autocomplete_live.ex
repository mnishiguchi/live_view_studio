defmodule LiveViewStudioWeb.AutocompleteLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Stores
  alias LiveViewStudio.Cities

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        zip: "",
        city: "",
        matches: [],
        stores: [],
        loading: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Find a Store</h1>

    <div id="search">
      <form phx-submit="zip-search">
        <input type="text" name="zip" value="<%= @zip %>"
              placeholder="Zip Code (e.g. 80204)"
              autofucus autocomplete="off"
              <%= if @loading, do: "readonly" %> />
        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <form phx-submit="city-search" phx-change="suggest-city">
        <input type="text" name="city" value="<%= @city %>"
              placeholder="City"
              autofucus autocomplete="off"
              list="matches"
              phx-debounce="1000"
              <%= if @loading, do: "readonly" %> />
        <button type="submit">
          <img src="images/search.svg">
        </button>
      </form>

      <datalist id="matches">
        <%= for match <- @matches do %>
          <option value="<%= match %>"><%= match %></option>
        <% end %>
      </datalist>

      <%= if @loading do %>
        <div class="loader">
          Loading...
        </div>
      <% end %>

      <div class="stores">
        <ul>
          <%= for store <- @stores do %>
            <li>
              <div class="first-line">
                <div class="name">
                  <%= store.name %>
                </div>
                <div class="status">
                  <%= if store.open do %>
                    <span class="open">Open</span>
                  <% else %>
                    <span class="closed">Closed</span>
                  <% end %>
                </div>
              </div>

              <div class="second-line">
                <div class="street">
                  <img src="images/location.svg">
                  <%= store.street %>
                </div>
                <div class="phone_number">
                  <img src="images/phone.svg">
                  <%= store.phone_number %>
                </div>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def handle_event("zip-search", %{"zip" => zip}, socket) do
    # Run the zip search async.
    send(self(), {:run_search, :zip, zip})

    # Assign the loading state.
    socket =
      assign(socket,
        zip: zip,
        stores: [],
        loading: true
      )

    {:noreply, socket}
  end

  def handle_event("suggest-city", %{"city" => city}, socket) do
    socket = assign(socket, matches: Cities.suggest(city))
    {:noreply, socket}
  end

  def handle_event("city-search", %{"city" => city}, socket) do
    # Run the city search async.
    send(self(), {:run_search, :city, city})

    # Assign the loading state.
    socket =
      assign(socket,
        city: city,
        stores: [],
        loading: true
      )

    {:noreply, socket}
  end

  @doc """
  Performs search and assigns the result.
  """
  def handle_info({:run_search, field, term}, socket) do
    case store_search(field, term) do
      [] ->
        socket =
          socket
          |> put_flash(:info, ~s(No store matching "#{term}"))
          |> assign(stores: [], loading: false)

        {:noreply, socket}

      stores ->
        socket =
          socket
          |> clear_flash()
          |> assign(stores: stores, loading: false)

        {:noreply, socket}
    end
  end

  defp store_search(:zip, term), do: Stores.search_by_zip(term)
  defp store_search(:city, term), do: Stores.search_by_city(term)
end
