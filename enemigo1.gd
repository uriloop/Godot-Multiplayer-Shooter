extends KinematicBody2D

var speed = 200

var velocity = Vector2(0, 0)
var facing = 0 
var player = false
var direction = 0 
onready var playerDetectionZone = $PlayerDetectionZone
var jugador = null
var motion = Vector2.ZERO


onready var softCollision = $SoftCollision

func _ready():
	Global.alive_enemies.append(self)


func _physics_process(delta):
	if (player == true):
		jugador = playerDetectionZone.player
		if is_network_master():
			if jugador != null:
				print("soy servidor, creo que hago cosas")
#				if softCollision.is_colliding():
#					velocity += softCollision.get_push_vector() * delta * 400
				direction = (jugador.global_position - global_position).normalized()
				#velocity = move_and_slide(direction * speed)
				facing = look_at(direction)
				velocity = move_and_collide(direction * speed)
				rpc("movimiento",velocity,facing,jugador)
				#rpc("actualizar_enemigo_s",jugador.global_position, global_position)
#				move_and_slide(velocity * speed)
#				#rpc("actualizar_enemigo",direction,speed)
##				var antidirection = jugador.global_position - global_position
##				direction = antidirection.normalized()
##				velocity = move_and_collide(direction * speed)
#				facing = look_at(jugador.global_position)
#	#			rpc("actualizar_enemigo",player,speed)
#		else:
#			# Akí un movimiento random
#			print("soy cliente, pero no hago nada xD")
#			puppet_facing = facing
#			#puppet_direction = direction
#			#puppet_facing = look_at(puppet_jugador.global_position)
#			puppet_velocity = velocity
#			puppet_motion = puppet_motion.move_toward(puppet_velocity * speed, 300 * 8)
#			puppet_motion = move_and_slide(puppet_motion)
			
	else:
		seek_new_player()
	#no tira
	#rpc("actualizar_enemigo")

slave func movimiento(velo,fac,play):
	velocity = velo
	facing = fac
	jugador = play
	

sync func actualizar_enemigo_s(player,mi):
	direction = (player - mi).normalized()
	#velocity = move_and_slide(direction * speed)
	facing = look_at(direction)
	move_and_collide(direction * speed)
	#actualizar_enemigo(player,mi)
	
puppet func actualizar_enemigo(player,mi):
	direction = (player - mi).normalized()
	move_and_collide(direction * speed)
	#move_and_slide(direction * speed)
	facing = look_at(direction)

											
func _on_PlayerDetectionZone_body_entered(body):
	if (body.is_in_group("Player") and player == null):
		if (get_tree().is_network_server()):
			rpc("seek_new_player",body)
	#	hacer que si hay otro player más cerca, siga al nuevo player
	#elif (body.is_in_group("Player") and player.distance_to(self)>=body.distance_to(self)):
		#player=body

sync func seek_new_player():
	if playerDetectionZone.can_see_player():
		player = true


func _on_hurtBox_area_entered(area):
	if (area.is_in_group("Player_damager")):
		# Aquí algo para que envié la señal de muerte a todos
		if get_tree().has_network_peer():
			if (get_tree().is_network_server()):
				rpc("destroy_enemy1")

sync func destroy_enemy1():
		Global.alive_enemies.erase(self)
		queue_free()
		
# hay que meterle un tween y interpolate entre las posiciones del server y del cliente. Luego una sync func que actualice la posicion. deberia prevalecer la posicion del servidor
