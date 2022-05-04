extends KinematicBody2D

puppet var puppet_player_seeking = Vector2(0, 0) 
puppet var puppet_velocity = Vector2()
puppet var puppet_facing = 0

var speed = 200

var velocity = Vector2(0, 0)
var facing = 0
var player = null

func _physics_process(delta):
	if (player):
		var direction = (player.position - self.position).normalized()
		velocity = move_and_slide(direction * speed)
		facing = look_at(player.position)
	else:
		# Akí un movimiento random
		pass
	
	#rpc("actualizar_enemigo")
	
	#no tira
sync func actualizar_enemigo():
	global_position=velocity
	global_rotation=facing
	puppet_player_seeking = player


func _on_PlayerDetectionZone_body_entered(body):
	if (body.is_in_group("Player") and player == null):
		player=body
	#	
	elif (body.is_in_group("Player") and player.distance_to(self)>=body.distance_to(self)):
		player=body



func _on_hurtBox_area_entered(area):
	if (area.is_in_group("Player_damager")):
		# Aquí algo para que envié la señal de muerte a todos
		rpc("destroy_enemy1")

sync func destroy_enemy1():
		queue_free()
	
# hay que meterle un tween y interpolate entre las posiciones del server y del cliente. Luego una sync func que actualice la posicion. deberia prevalecer la posicion del servidor
