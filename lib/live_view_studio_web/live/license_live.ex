defmodule LiveViewStudioWeb.LicenseLive do
  use LiveViewStudioWeb, :live_view

  alias LiveViewStudio.Licenses
  import Number.Currency

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Count down every second.
      :timer.send_interval(1000, self(), :tick)
    end

    one_hour_from_now = Timex.shift(Timex.now(), hours: 1)

    initial_state = %{
      seats: 3,
      amount: Licenses.calculate(3),
      expiration_time: one_hour_from_now,
      time_remaining: time_remaining(one_hour_from_now)
    }

    {:ok, assign(socket, initial_state)}
  end

  def render(assigns) do
    ~L"""
    <h1>Team License</h1>

    <div id="license">
      <div class="card">
        <div class="content">
          <div class="seats">
            <img src="images/license.svg">
            <span>
              Your license is currently for
              <strong><%= @seats %></strong> <%= Inflex.inflect("seat", @seats) %>.
            </span>
          </div>

          <form phx-change="update">
            <input type="range" min="1" max="10"
                   name="seats" value="<%= @seats %>" />
          </form>

          <div class="amount">
            <%= number_to_currency(@amount) %>
          </div>

          <p class="m-4 font-semibold text-indigo-800">
            <%= if @time_remaining > 0 do %>
              <%= format_time(@time_remaining) %> left to save 20%
            <% else %>
              Expired!
            <% end %>
          </p>
        </div>

      </div>
    </div>
    """
  end

  @doc """
  Called when the form is changed. The second argument is metadata about the
  event including the form data.
  """
  def handle_event("update", %{"seats" => seats}, socket) do
    seats = String.to_integer(seats)

    socket =
      assign(socket,
        seats: seats,
        amount: Licenses.calculate(seats)
      )

    {:noreply, socket}
  end

  @doc """
  Called every second. Updates the time remaining.
  """
  def handle_info(:tick, socket) do
    expiration_time = socket.assigns.expiration_time
    socket = assign(socket, time_remaining: time_remaining(expiration_time))
    {:noreply, socket}
  end

  # Returns time remaining in seconds.
  #
  # ## Examples
  #
  #     iex> expiration_time = Timex.shift(now, minutes: 30)
  #     ~U[2020-09-12 21:36:57.142111Z]
  #
  #     iex> time_remaining(expiration_time)
  #     1347
  #
  defp time_remaining(expiration_time) do
    DateTime.diff(expiration_time, Timex.now())
  end

  # Converts seconds to humanized time string.
  #
  # ## Examples
  #
  #     iex> format_time(1347)
  #     "22 minutes, 27 seconds"
  #
  defp format_time(seconds) do
    seconds
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end
end
