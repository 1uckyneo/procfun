import std/num/random
import std/os/readline

// var err-count := 0
// val err-count = 0

effect debug
  fun inc-err(): ()

effect fail
  brk fail(exn: exception): a

struct game
  answer: int
  done: bool = False
  guesses: int = 0
  high: int

fun ask-guess(high: int): <console, exn, fail> int
  print("Guess a number between 1 and " ++ high.show ++ ": ")
  readline-checked().parse-int-checked

fun ask-guess-multi(high: int): <console, debug, div, fail> int
  with brk throw-exn(exc)
    println("I didn't understand")
    inc-err()
    ask-guess-multi(high)
  ask-guess(high)

fun parse-int-checked(text: string): exn int
  match text.parse-int
    Nothing -> throw("bad int: " ++ text)
    Just(n) -> n

fun pick-answer(high: int): random int
  (random-double() * high.double).int + 1

fun pick-answer-strong(high: int): ndet int
  srandom-int32-range(1.int32, high.int32).int

fun play(game: game): <console, debug, div, fail> game
  // game.done := True
  // game := game(done = True)
  val guess = ask-guess-multi(game.high)
  game.report(guess)
  val next = game.update(guess)
  if next.done then next else next.play

fun readline-checked(): <console, fail> string
  with brk throw-exn(exc)
    fail(exc)
  readline()

fun report(game: game, guess: int): console ()
  val description =
    if guess < game.answer then "too low"
    elif guess > game.answer then "too high"
    else "the answer!"
  println(guess.show ++ " is " ++ description)

fun update(game: game, guess: int): game  // or `total game`
  var done := False
  if guess == game.answer then
    done := True
  game(done = done, guesses = game.guesses + 1)

fun main(): <console, div, exn, random> ()  // or `io ()` without random
  with brk fail(exc) -> throw-exn(exc)
  // Track info for debug
  var err-count := 0
  with fun inc-err()
    err-count := err-count + 1
  // with fun random-int32() -> 0.int32
  // Main code
  val high = 100
  var game := Game(answer = pick-answer(high), high = high)
  game := game.play
  println("Finished in " ++ game.guesses.show ++ " guesses")
  println("Total input errors: " ++ err-count.show)
