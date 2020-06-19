# Make APIs fun project

Welcome to the "Make APIs fun" open source project 🔥 Who said that works with Rest APIs was boring?

In this repository you will find a set of APIs to play classic board games using just REST requests 😱

![https://github.com/jcagarcia/make-apis-fun/blob/master/banner.png](banner.png)

## How to play

### Online

You can play to all the games developed inside the "Make APIs fun" project in http://make-apis-fun.com

**Remember to read the documentation** of each game carefuly before start playing.

### Local

1. Clone this repository
```
git clone https://github.com/jcagarcia/make-apis-fun.git
```
2. Inside the `games` folder you will find a list of games ready to be played. All the games are `dockerized` and they include `make up` instruction. Execute the following command to run a game:
```
~/make-apis-fun $ cd games/
~/make-apis-fun/games $ cd clue-api/
~/make-apis-fun/games/clue-api $ make up
```
3. The desired game will be running in `localhost:8080`. You can use [curl](https://github.com/curl/curl), [postman](https://github.com/postmanlabs), etc. to start playing. 

4. **Remember to read the documentation** of each game carefuly before start playing.

Enjoy it!

## List of games

* [Clue](https://github.com/jcagarcia/make-apis-fun/tree/master/games/clue-api): Cards game

## Contributions

Do you want to contribute to the "Make APIs fun" project? Contributions are really really welcome! 😍

Feel free to write new API games **using the language you prefer**. We 💛 all the existing languages.

You must follow these instructions if you are thinking on to do a Pull-Request to this repository:

* Your game must be inside the `games` folder.
* Your game must be dockerized to allow us to deploy it automatically in our page 🙂
* Your game must contain a `Makefile` with an `up` action to be able to run the game.
* Your game must contain a `README` file explaining the game and the rules.
* You must update the "Make APIs fun" documentation explaining how to play to your new game 🤓 

Also, **if you notice that some game needs any kind of improvement or bug fix, feel free to send a Pull Request too.**
