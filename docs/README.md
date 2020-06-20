# Make APIs fun - APIs Documentation

We use the [Slate project](https://github.com/slatedocs/slate) in order to generate the "Make APIs fun" API documentation.

## How to read this documentation

### Online

You can check the documentation of the "Make APIs fun" project in http://make-apis-fun.com/docs

### Local

Inside this folder, perform the following commands:

```
docker build . -t slate
docker run -d --rm --name slate -p 4567:4567 -v $(pwd)/build:/srv/slate/build -v $(pwd)/source:/srv/slate/source slate
```

and you will be able to access your site at http://localhost:4567.

## Contribute

Do you want to contribute to the "Make APIs fun" project? Contributions are really really welcome! 😍

All the APIs games developed under the "Make APIs fun" project should document all their endpoints and the creators should explain how to play to them. As much details you include in your documentation, more easy will be to play.

**If you notice that some game needs a documentation improvement, documentation fix, etc. feel free to send a Pull Request.**

### Documenting a new game

All the documentation files are included under the `sources/includes` folder. 

If you have created or you are creating a new game, you must create a new `markdown` file using the name of your game and including on it all the endpoints you want to offer to the consumers.