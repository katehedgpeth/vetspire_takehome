import { type FC, useContext, useMemo } from "react";

import { SelectedBreedContext } from "../contexts/SelectedBreed";
import useBreedsQuery from "../hooks/useBreedsQuery";

import BreedImage from "./BreedImage";

const SelectedBreed: FC = () => {
  const selectedBreedId = useContext(SelectedBreedContext);
  const { data } = useBreedsQuery();

  const breed = useMemo(() => {
    return data && selectedBreedId ? data.breeds.get(selectedBreedId) : null;
  }, [selectedBreedId, data]);

  const image = useMemo(() => {
    return data && breed ? data.images.get(breed.image_id) : null;
  }, [breed, data]);

  if (!data || !breed) return null;
  if (!image)
    throw new Error("unable to find image for breed!", {
      cause: { data, breed },
    });

  return Array.from(data.images.values()).map((image) => (
    <BreedImage
      {...image}
      isHidden={image.breed_id !== breed.id}
      key={image.id}
    />
  ));
};

export default SelectedBreed;
