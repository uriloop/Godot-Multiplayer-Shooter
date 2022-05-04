extends KinematicBody2D



var speed = 200

var velocity = Vector2(0, 0)
var facing = 0
var player = null

func _physics_process(delta):
	if (player):
		var direction = (player.position - position).normalized()
		move_and_slide(direction * speed)
		facing = look_at(player.position)



sync func _on_PlayerDetectionZone_body_entered(body):
	if (body.is_in_group("Player") and player == null):
		player = body
		


func _on_hurtBox_area_entered(area):
	if (area.is_in_group("Player_damager")):
		# Aquí algo para que envié la señal de muerte a todos
		rpc("destroy_enemy1")

sync func destroy_enemy1():
		queue_free()
	
# hay que meterle un tween y interpolate entre las posiciones del server y del cliente. Luego una sync func que actualice la posicion. deberia prevalecer la posicion del servidor
