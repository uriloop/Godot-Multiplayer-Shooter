extends Camera2D

var target_player = null

func _process(delta: float) -> void:
	# Si el player original está vivo
	if Global.player_master != null:
		# la camara sigue al player 
		global_position = lerp(global_position, Global.player_master.global_position, delta * 10)
	else:
		# si el player ha muerto y todavia quedan players vivos la camara sigue a otro player
		if Global.alive_players.size() >= 1:
			# El target player es null si acaba de morir
			if target_player == null:
				# El target player pasa a ser un player random entre los que quedan vivos
				target_player = Global.alive_players[round(rand_range(0, Global.alive_players.size() - 1))]
			else:
				#Si ya hay un target player lo seguimos
				global_position = lerp(global_position, target_player.global_position, delta * 10)
