defmodule Identicon do
  @moduledoc """
  Documentation for `Identicon`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Identicon.hello()
      :world

  """
  def main(input)do
    input
    |> hash
    |> pick_color
    |> list_to_grid
    |> filter_odds
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end
  def save_image(image, filename) do
    File.write("#{filename}.png", image)
  end
  def draw_image(image) do
    %Identicon.Image{color: color, pixel_map: pixel_map} = image
    img = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(img, start, stop, fill)
    end
    :egd.render(img)
  end
  def build_pixel_map(image) do
    %Identicon.Image{grid: grid} = image
    pixel_map = Enum.map grid, fn({_stuff, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}
      {top_left, bottom_right}
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end
  def filter_odds(image) do
    %Identicon.Image{grid: grid} = image
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end
  def pick_color(image) do
    %Identicon.Image{hex: [r, g, b | _tail]} = image
    %Identicon.Image{image | color: {r, g, b}}
  end
  def hash(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
  def list_to_grid(image) do
    %Identicon.Image{hex: hex} = image
    grid = hex
    |> Enum.chunk(3)
    |> Enum.map(&mirror_rows/1)
    |> List.flatten
    |> Enum.with_index

    %Identicon.Image{image | grid: grid}
  end
  def mirror_rows(row) do
    [first, second | _tail] = row
    row ++ [second, first]

  end
  def hello do
    :world
  end
end
