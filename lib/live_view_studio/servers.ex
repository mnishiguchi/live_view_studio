defmodule LiveViewStudio.Servers do
  @moduledoc """
  The Servers context.
  """

  import Ecto.Query, warn: false
  alias LiveViewStudio.Repo
  alias LiveViewStudio.Servers.Server

  @topic inspect(__MODULE__)

  def subscribe do
    Phoenix.PubSub.subscribe(LiveViewStudio.PubSub, @topic)
  end

  # Notifies subscribers about a record created or updated.
  # Accepts a result of Repo.insert()` or `Repo.update()` as a first argument
  # and an internal event name as a second argument. Returns the original Repo
  # result to conform to the contract.
  defp broadcast({:ok, server} = repo_result, event) do
    Phoenix.PubSub.broadcast(LiveViewStudio.PubSub, @topic, {event, server})
    repo_result
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  @doc """
  Returns the list of servers.

  ## Examples

      iex> list_servers()
      [%Server{}, ...]

  """
  def list_servers do
    # The most-recently added server is always at the top of the list.
    Repo.all(from s in Server, order_by: [desc: s.id])
  end

  @doc """
  Gets a single server.

  Raises `Ecto.NoResultsError` if the Server does not exist.

  ## Examples

      iex> get_server!(123)
      %Server{}

      iex> get_server!(456)
      ** (Ecto.NoResultsError)

  """
  def get_server!(id), do: Repo.get!(Server, id)

  @doc """
  Creates a server.

  ## Examples

      iex> create_server(%{field: value})
      {:ok, %Server{}}

      iex> create_server(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_server(attrs \\ %{}) do
    %Server{}
    |> Server.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:server_created)
  end

  @doc """
  Updates a server.

  ## Examples

      iex> update_server(server, %{field: new_value})
      {:ok, %Server{}}

      iex> update_server(server, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
    |> broadcast(:server_updated)
  end

  def toggle_status_of_server(%Server{} = server) do
    status =
      case server.status do
        "down" -> "up"
        _ -> "down"
      end

    update_server(server, %{status: status})
  end

  @doc """
  Deletes a server.

  ## Examples

      iex> delete_server(server)
      {:ok, %Server{}}

      iex> delete_server(server)
      {:error, %Ecto.Changeset{}}

  """
  def delete_server(%Server{} = server) do
    Repo.delete(server)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking server changes.

  ## Examples

      iex> change_server(server)
      %Ecto.Changeset{data: %Server{}}

  """
  def change_server(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end
end
