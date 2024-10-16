class_name SpawnTable
extends Resource
## Resource that holds all information about enemies that will be spawned during the game.
## Contains an array of SpawnWave resources that define all spawns within a given timeframe.
## Each wave consists of SpawnSequences, which specify the form in which the entity will be spawned,
## like pattern, interval, and count of the spawns.

## All waves that will be spawned in chronological order.
@export var duration: float
@export var timeline: Array[SpawnWave] = []

