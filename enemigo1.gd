extends KinematicBody2D

var speed = 200
var puppet_velocity
var puppet_facing
var velocity = Vector2()
var facing = 0
var player = null



func _ready():
	Global.alive_enemies.append(self)



func _physics_process(delta):
	if (player):
		if is_network_master():
			self.rpc("_update_state",puppet_velocity,puppet_facing)
			#self.rset("actualizar_enemigo",player,speed)
			print("Server agewgowjrg")
		else:
			print("Actualizando enemigo")
			velocity= puppet_velocity
			facing= puppet_facing
		
		move_and_slide(velocity * speed)
		if not is_network_master():
			puppet_velocity = velocity
	#no tira
	#rpc("actualizar_enemigo")
#	if is_network_master():
#        rpc("_update_state", puppet_pos, puppet_motion)
#    else:
#       position = puppet_pos
#        motion = puppet_motion
#
#    move_and_slide(motion * MOTION_SPEED)
#    if not is_network_master():
#        puppet_pos = position # To avoid jitter
	
	
puppet func _update_state(p_pos, p_facing):
	puppet_velocity = p_pos
	puppet_facing = p_facing
	
puppet func actualizar_enemigo(player,speedo):
	velocity = move_and_slide( ((player.global_position - self.global_position).normalized()) * speedo)
	facing = look_at(player.position)
	self.motion
											
func _on_PlayerDetectionZone_body_entered(body):
	if (body.is_in_group("Player") and player == null):
		if (get_tree().is_network_server()):
			rpc("seek_new_player",body)
			print("signar player")
	#	hacer que si hay otro player más cerca, siga al nuevo player
	#elif (body.is_in_group("Player") and player.distance_to(self)>=body.distance_to(self)):
		#player=body

puppet func seek_new_player(body):
	print("signated player")
	player=body


func _on_hurtBox_area_entered(area):
	if (area.is_in_group("Player_damager")):
		# Aquí algo para que envié la señal de muerte a todos
		if get_tree().has_network_peer():
			if (get_tree().is_network_server()):
				rpc("destroy_enemy1")

remotesync func destroy_enemy1():
		Global.alive_enemies.erase(self)
		queue_free()
		
# hay que meterle un tween y interpolate entre las posiciones del server y del cliente. Luego una sync func que actualice la posicion. deberia prevalecer la posicion del servidor
