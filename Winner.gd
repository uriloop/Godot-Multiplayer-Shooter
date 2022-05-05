extends Label

# funcion syncronizada para cambiar a escena de lobby 
sync func return_to_lobby():
	get_tree().change_scene("res://Network_setup.tscn")

# cuando el timer de ganador llega a 0 enviamos señal de volver al lobby
func _on_Win_timer_timeout():
	if get_tree().is_network_server():
		rpc("return_to_lobby")

