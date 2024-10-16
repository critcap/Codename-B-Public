## Defines a wave of enemies within a specific timeframe. Can hold multiple SpawnSequences.
#class_name SpawnWave 
extends Resource
## Duration of the wave in seconds.
@export var duration: int
## SpawnSequences of the wave.
## Allows for a mix of different enemies with varying amounts and frequencies of spawns.
@export var sequences: Array[SpawnSequence]