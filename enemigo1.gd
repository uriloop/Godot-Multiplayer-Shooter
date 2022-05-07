extends KinematicBody2D



var speed = 250

var vectorPosicion = Vector2(0, 0)
var facing = 0
var player = null

func _physics_process(delta):
	if (is_network_master()):
		if (player):
			var posPlayer = (player.global_position - position).normalized()
			vectorPosicion = move_and_slide(posPlayer * speed)
			facing = look_at(posPlayer)
		rpc("setStats",vectorPosicion,facing)

slave func setStats(vel,fac):
	vectorPosicion= vel
	facing=fac


func _on_PlayerDetectionZone_body_entered(body):
	if (body.is_in_group("Player") and player == null):
		player = body



func _on_hurtBox_body_entered(area):
	if (area.is_in_group("Player_damager")):
		if is_network_master():
			rpc("destroyEnemy")
			queue_free()
		

sync func destroyEnemy():
	queue_free()
