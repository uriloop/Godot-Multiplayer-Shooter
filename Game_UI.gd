extends CanvasLayer

onready var win_timer = $Control/Winner/Win_timer
onready var winner = $Control/Winner

func _ready() -> void:
	# escondemos el mensaje de ganador
	winner.hide()

# Esto se ejecuta cada frame
func _process(_delta: float) -> void:
	# Si queda un solo jugador en el array jugadores y todavia esta activa la conexión peer to peer
	if Global.alive_players.size() == 1 and get_tree().has_network_peer():
		# Comprovamos que se corresponde con el player correcto
		if Global.alive_players[0].name == str(get_tree().get_network_unique_id()):
			# Mostramos el mensaje de winner
			winner.show()
		# Si el timer de ganador está inactivo, se inicia
		if win_timer.time_left <= 0:
			win_timer.start()
