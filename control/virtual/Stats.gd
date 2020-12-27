extends Node

export var max_health = 1 setget set_max_health
export var fins = true
export var laser = true
export var wings = true
export var canopy = true
export var barrel = true
export var missle = true
export var level = 1
export var missles = 30

#stored previous values
var pfins = true
var plaser = true
var pwings = true
var pcanopy = true
var pbarrel = true
var pmissle = true
var plevel = 1
var pmissles = 30
var phealth = max_health

var health = max_health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	max_health = value
	self.health = min(self.health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func _ready():
	self.health = max_health
	
func save_values():
	pfins = fins
	plaser = laser
	pwings = wings
	pcanopy = canopy
	pbarrel = barrel
	pmissle = missle
	plevel = level
	pmissles = missles
	phealth = health
	
func reset_values():
	fins = true
	laser = true
	wings = true
	canopy = true
	barrel = true
	missle = true
	level = 1
	missles = 30
	health = max_health
	save_values()

func revert_values():
	fins = pfins
	laser = plaser
	wings = pwings
	canopy = pcanopy
	barrel = pbarrel
	missle = pmissle
	level = plevel
	missles = pmissles
	health = phealth
