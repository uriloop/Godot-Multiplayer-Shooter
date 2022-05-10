extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 200
var velocity = Vector2()
var playerSeeking = null
var facing=0


puppet var puppet_position = Vector2()
puppet var puppet_velocity = Vector2()
puppet var puppet_rotation = 0

func _ready():
	yield(get_tree(), "idle_frame")
	
	if get_tree().has_network_peer():
		if is_network_master():
			velocity = Vector2(0,0)
			facing = 0
			rset("puppet_velocity", velocity)
			rset("puppet_rotation", facing)
			rset("puppet_position", global_position)



func _process(delta):
	if get_tree().has_network_peer():

		if is_network_master():
			if is_network_master():
				if playerSeeking:
					
					velocity = (playerSeeking.position - position).normalized()
					position= move_and_slide(velocity * speed).normalized()
					facing = look_at(playerSeeking.position)
					rset("puppet_velocity", velocity)
					rset("puppet_rotation", facing)
					rset("puppet_position", global_position)
		
	
		else:
			facing= puppet_rotation
			velocity=puppet_velocity
			position = puppet_position


sync func newPlayerSeeking(playerToSeek):
	for child in Persistent_nodes.get_children():
		if child.name == playerToSeek:
			playerSeeking= child

func _on_seekArea_area_entered(area):
	if (area.get_parent().is_in_group('Player') and playerSeeking == null):
		rpc('newPlayerSeeking', area.get_parent().name)
