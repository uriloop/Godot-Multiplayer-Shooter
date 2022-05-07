extends KinematicBody2D

var speed = 200

var velocity = Vector2(0, 0) setget set_velocity
var facing = 0 setget set_facing
var player = false
var direction = 0 setget set_direction
onready var playerDetectionZone = $PlayerDetectionZone
var jugador = null setget set_jugador
var motion = Vector2.ZERO


onready var softCollision = $SoftCollision

puppet var puppet_motion = Vector2.ZERO setget puppet_motion_set
puppet var puppet_jugador = null setget puppet_jugador_set
puppet var puppet_direction = Vector2() setget puppet_direction_set
puppet var puppet_velocity = Vector2() setget puppet_velocity_set
puppet var puppet_facing = 0 setget puppet_facing_set

func puppet_motion_set(new_value) -> void:
	puppet_motion = new_value
	
	if not is_network_master():
		motion = puppet_motion

func puppet_jugador_set(new_value) -> void:
	puppet_jugador = new_value
	
	if not is_network_master():
		jugador = puppet_jugador

func set_jugador(new_value):
	jugador = new_value	
	
	if is_network_master():
		rset("puppet_jugador_set", jugador)

func puppet_direction_set(new_value) -> void:
	puppet_direction = new_value
	
	if not is_network_master():
		direction = puppet_direction

func puppet_facing_set(new_value) -> void:
	facing = new_value
	
func set_facing(new_value):
	facing = new_value	
	
	if is_network_master():
		rset("puppet_facing_set", facing)

func puppet_velocity_set(new_value) -> void:
	velocity = new_value
	
	if not is_network_master():
		velocity = puppet_velocity

func set_velocity(new_value):
	velocity = new_value
	
	if is_network_master():
		rset("puppet_velocity_set", velocity)

func set_direction(new_value):
	direction = new_value
	
	if is_network_master():
		rset("puppet_direction_set", direction)

func _ready():
	Global.alive_enemies.append(self)


func _physics_process(delta):
	if (player == true):
		jugador = playerDetectionZone.player
		if is_network_master():
			if jugador != null:
				print("soy servidor, creo que hago cosas")
				if softCollision.is_colliding():
					velocity += softCollision.get_push_vector() * delta * 400
				rpc("actualizar_enemigo_s",jugador.global_position, global_position)
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
