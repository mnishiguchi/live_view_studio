defmodule LiveViewStudioWeb.ParamHelpers do
  use Phoenix.HTML

  @moduledoc """
  A collection of generic utility functions for handling URL parameters.
  """

  @doc """
  Checks if a received URL parameter is in a list of permitted parameters. Falls
  back to the head of the allowlist.

  EXAMPLES:

      iex> params = %{"sort_by" => "name"}
      %{"sort_by" => "asc"}
      iex> ParamHelpers.get_param_or_first_permitted(params, "sort_by", ~w(id name))
      "name"
      iex> ParamHelpers.get_param_or_first_permitted(params, "INVALID_KEY", ~w(id name))
      "id"

  """
  def get_param_or_first_permitted(params, key, allowlist) do
    value = params[key]
    if value in allowlist, do: value, else: hd(allowlist)
  end

  @doc """
  Converts a value to an integer, falling back to the specified default value in
  case the conversion fails.

  EXAMPLES:

      iex> ParamHelpers.param_to_integer(nil, 5)
      5
      iex> ParamHelpers.param_to_integer(25, 5)
      25
      iex> ParamHelpers.param_to_integer("25", 5)
      25
      iex> ParamHelpers.param_to_integer("INVALID", 5)
      5

  """
  def param_to_integer(nil, default_value) when is_integer(default_value), do: default_value

  def param_to_integer(value, _) when is_integer(value), do: value

  def param_to_integer(value, default_value)
      when is_binary(value)
      when is_integer(default_value) do
    case Integer.parse(value) do
      {number, _} -> number
      :error -> default_value
    end
  end
end
