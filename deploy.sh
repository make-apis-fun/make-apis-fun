#/bin/bash

cd games
for d in */ ; do
  cd $d
  make up
  cd ..
done

cd ../docs
docker build . -t slate
docker run -d --rm --name slate -p 4567:4567 -v $(pwd)/build:/srv/slate/build -v $(pwd)/source:/srv/slate/source slate