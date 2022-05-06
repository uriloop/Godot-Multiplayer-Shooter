extends KinematicBody2D

var speed = 200

var velocity = Vector2()
var facing = 0
var player = null

func _ready():
	Global.alive_enemies.append(self)


func _physics_process(delta):
	if (player != null):
		#if (get_tree().is_network_server()):
		self.rpc_unreliable("actualizar_enemigo",player,speed)
		
	else:
		# Akí un movimiento random
		pass
	
	#no tira
	#rpc("actualizar_enemigo")
	
remotesync func actualizar_enemigo(player,speedo):
	if (player != null):
		velocity = move_and_slide( ((player.global_position - self.global_position).normalized()) * speedo)
		facing = look_at(player.position)

											
func _on_PlayerDetectionZone_body_entered(body):
	if (body.is_in_group("Player") and player == null):
		if (get_tree().is_network_server()):
			rpc("seek_new_player",body)
	#	hacer que si hay otro player más cerca, siga al nuevo player
	#elif (body.is_in_group("Player") and player.distance_to(self)>=body.distance_to(self)):
		#player=body

sync func seek_new_player(body):
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
