defmodule LiveViewStudio.Volunteers.Volunteer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "volunteers" do
    field :checked_out, :boolean, default: false
    field :name, :string
    field :phone, :string

    timestamps()
  end

  @doc false
  def changeset(volunteer, attrs) do
    volunteer
    |> cast(attrs, [:name, :phone, :checked_out])
    |> validate_required([:name, :phone, :checked_out])
  end
end
