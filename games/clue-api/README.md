# Clue (API Version)

Clue is a murder mystery game for *three* to *six* players that was devised in 1943 by *Anthony E. Pratt*.

The object of the game is to determine **who** murdered the game's victim, **where** the crime took place, and **which** weapon was used. 

To achieve this goal, you should analyze the game, think about how the cards are distributed between players and perform hypothesis in your turn. After each hypothesis, you will be closer to resolve the mistery. Read **Rules** section for more information about how the game works.

![https://github.com/jcagarcia/make-apis-fun/tree/master/games/clue-api/banner.png](banner.png)

## Rules

When some player creates the new game using the `POST` endpoint, three cards (one suspect, one room, and one weapon) are chosen at random. Those cards are not going to be provided by any endpoint in any moment, so no one can see them. **These cards represent the facts of the case**. The remainder of the cards are distributed among the players. 

The objective of the game is to deduce the details of the murder, i.e. the cards selected randomly by the system. There are **six characters**, **six murder weapons** and **nine rooms**, leaving the players with **324 possibilities**. As soon as the turn of a player starts, they may perform an hypothesis as to the details, naming a suspect, a room and a weapon. For example: "I suggest it was James, in the Dining Room, with the Knife." A player's suggestion may name themself as the murderer and may include cards in their own hand.

Once a player makes a suggestion, the others are called upon to disprove it. If the player to their left holds any of the three named cards, that player must privately show one (and only one) of the cards to them. If not, the process continues clockwise around the table until either one player disproves the suggestion, or no one can do so. A player's turn normally ends once their suggestion is completed. 

**NOTE**: In this API version, as a player cannot wait to other player actions, the players that have any of the suggested cards will not need to perform any action. **Is the system who will automatically return a card** to the requester following the strategy explained above.

A player who believes they have determined the correct elements may try to resolve on their turn. The accusation can include any room, any weapon and any murderer. **If they match the accusation, the player wins and the game is marked as finished**; if not, the player may not perform hypothesis/resolve actions for the remainder of the game; **in effect, "losing"**. However, other players will continue receiving cards from that disabled player in order to disprove suggestions.

## API version limitations

As this is an API version and not the original board version, it has some limitations.

* In tis API version there is not any board, so the players just perform hypothesis during their turn without needed of move across the board.

* When a new game is created, the player can specify the number of players (3 to 6). Also, the player can specify if the game is going to be in `play_with_friends` mode or `play_against_the_machine` mode.
** In `play_with_friends` mode, the creator of the game needs to share the game id with his friends and they should join the game using the `POST` join operation. **The creator needs to perform the join operation too**. When all the player will joined the game, it will start.
** In `play_against_the_machine` mode, the game is created with all the players joined except the last one. That players are bots of the system. The creator should join the match to start the game. In this mode, the hypothesys of the other players are performed automatically and **they will never try to resolve the game**, so after the player executes an action, is going to be his turn again.

* The turns don't expire in time. So until a player don't perform an hypothesis action, the next player will not be able to perform its hypothesis. Meanwhile, other players can check the **Logs** of the game using the `GET` operation in order to analyze the situation and try to resolve the mistery.

* If any hypothesis has been performed in **5 minutes**, the system assumes that the game has finished without any winner.

## Hints

### Check the logs

Each player begins the game with three to six cards in their hand, depending on the number of players. **Keeping track of which cards are shown to each player is important in deducing the solution.** To do that, the players **must perform a `GET` endpoint to see the status of the game and check the logs that contains the iterations that happened during all the match**.

The logs keep all **the hypothesis** made by all the players and which cards had been shown by the rest of the players. It can also be useful in deducing **which cards the other players have shown one another**. For example, if *Player A* disproves *Player B* suggestion that *James* did the crime in the *Ballroom* with the *Guitar*, a player with both the *Ballroom* and *James* cards in their hand can then deduce that *Player A* has the *Guitar*. **A player makes a suggestion to learn which cards may be eliminated from suspicion**. However, in some cases it **may be advantageous for a player to include one of their own cards in a suggestion**. This technique can be used for both forcing a player to reveal a different card as well as misleading other players into believing a specific card is suspect.

### Notetaking

One reason the game is enjoyed by many ages and skill levels is that the complexity of note-taking can increase as a player becomes more skillful. Beginners may simply mark off the cards they have been shown; more advanced players will keep track of who has and who does not have a particular card, possibly with the aid of an additional grid. Expert players may keep track of each suggestion made, knowing that the player who answers it must have at least one of the cards named; which one can be deduced by later events. One can also keep track of which cards a given player has seen, in order to minimize information revealed to that player and/or to read into that player's suggestions. 

**NOTE**: In this API version, the API offers a `GET` endpoint to retrieve information about the `match`. The response includes a `log` that contains the iterations that happened during all the match. **We really recommend you to check the logs and not only take into account the responses you receive when perform an hypothesis**


## Changelog

* 2020-06-19: Initial release.

## Author

Clue (API Version) by [jcagarcia](https://github.com/jcagarcia)

### Contributors

If you notice that this game needs any kind of improvement or bug fix, **feel free to send a Pull Request**.