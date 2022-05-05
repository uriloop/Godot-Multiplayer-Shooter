extends KinematicBody2D

var speed = 200

var velocity = Vector2(0, 0)
var facing = 0
var player = null

func _ready():
	Global.alive_enemies.append(self)


func _physics_process(delta):
	if (player):
		var direction = (player.position - self.position).normalized()
		velocity = move_and_slide(direction * speed)
		facing = look_at(player.position)
	else:
		# Akí un movimiento random
		pass
	
	#no tira
	#rpc("actualizar_enemigo")
	
sync func actualizar_enemigo():
	#global_position=velocity
	#global_rotation=facing
	#puppet_player_seeking = player
	for enemy in Global.alive_enemies:
		if (self.get_instance_id()==enemy.get_instance_id()):
			enemy.position=velocity
			enemy.rotation=facing
			enemy.player=player
			

											
func _on_PlayerDetectionZone_body_entered(body):
	if (body.is_in_group("Player") and player == null):
		if get_tree().has_network_peer():
			if (get_tree().is_network_server()):
				player=body
	#	hacer que si hay otro player más cerca, siga al nuevo player
	#elif (body.is_in_group("Player") and player.distance_to(self)>=body.distance_to(self)):
		#player=body


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
