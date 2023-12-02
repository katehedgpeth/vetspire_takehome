defmodule Mix.Tasks.Linneaus.SeedDb do
  require Logger
  use Mix.Task

  alias Linneaus.Dog

  @moduledoc """
  Seeds the database using the list of images in priv/images/dogs.

  Options:
    --limit=NUMBER (optional)    limit the number of created records

  usage:
  $ mix dog_breeds.seed_db --limit=3
  """

  @requirements ["app.config", "app.start"]

  @static_path Path.join([
                 :code.priv_dir(:linneaus),
                 "static",
                 "images",
                 "dogs"
               ])
  @files File.ls!(@static_path)

  def run(args) do
    args
    |> parse_args()
    |> seed_db()
  end

  defp parse_args(["--limit=" <> limit]) do
    %{limit: String.to_integer(limit)}
  end

  defp parse_args([]) do
    %{limit: length(@files)}
  end

  def seed_db(%{limit: limit}) do
    @files
    |> Enum.take(limit)
    |> Enum.each(&insert_breed/1)
  end

  defp insert_breed(file_name) do
    case Dog.Breed.new(%{
           name: parse_breed_name(file_name),
           image: %{
             asset_url: Path.join(["images", "dogs", file_name])
           }
         }) do
      {:ok, %Dog.Breed{}} ->
        :ok

      {:error, changeset} ->
        Logger.warning(
          error: "breed not inserted",
          changeset: changeset
        )
    end
  end

  defp parse_breed_name(file_name) do
    file_name
    |> String.split(".")
    |> Enum.at(0)
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end