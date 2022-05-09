extends Node

var player_master = null
var ui = null

var alive_players = []

# array de enemigos para tenerlos controlados
var alive_enemies = []


func instance_node_at_location(node: Object, parent: Object, location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func update_position(name,position):
	if alive_enemies.has(name):
		alive_enemies[name].position = position
