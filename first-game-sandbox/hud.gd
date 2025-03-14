extends CanvasLayer

signal start_game
signal pause_game
signal upgrade_shields
signal upgrade_projectile

var s_upgrade = 0
var p_upgrade = 0

var s_cost_1 = 15
var p_cost_1 = 20
var p_cost_2 = 40

var score = 0
var coins = 0

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_game_over():
	show_message("Game Over")
	$PauseButton.hide()
	
	coins += score
	update_coins()
	check_buy()
	
	await get_tree().create_timer(1.0).timeout
	$ShieldUpgrade.show() 
	$ProjectileUpgrade.show()
	$CoinLabel.show()
	await $MessageTimer.timeout
	$Message.text = "Dodge the Baddies!"
	$Message.show()
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func update_score(new_score):
	$ScoreLabel.text = str(new_score)
	score = new_score

func update_highscore(high_score):
	$HighScoreLabel.text = str(high_score)

func update_shields(player_shields):
	$ShieldLabel.text = str(player_shields)

func _on_message_timer_timeout():
	$Message.hide()

func _on_start_button_pressed():
	$StartButton.hide()
	$StartButton.text = "Again"
	$PauseButton.show()
	$ShieldUpgrade.hide()
	$ProjectileUpgrade.hide()
	$CoinLabel.hide()
	start_game.emit()

func _on_pause_button_pressed():
	if $PauseButton.text == "Pause":
		$PauseButton.text = "Resume"
		show_message("Paused")
		pause_game.emit()
	else:
		$PauseButton.text = "Pause"
		$Message.hide()
		pause_game.emit()

func _on_shield_upgrade_pressed() -> void:	
	upgrade_shields.emit()
	s_upgrade += 1
	if s_upgrade > 0:
		coins -= s_cost_1
		update_coins()
		$ShieldUpgrade.text = "Max Shields"
		$ShieldUpgrade.disabled = true
	check_buy()
	
func _on_projectile_upgrade_pressed():
	upgrade_projectile.emit()
	p_upgrade += 1
	if p_upgrade == 1:
		coins -= p_cost_1
		update_coins()
		$ProjectileUpgrade.text = "Upgrade Projectile | $40"
	elif p_upgrade > 1:
		coins -= p_cost_2
		update_coins()
		$ProjectileUpgrade.text = "Max Projectile"
		$ProjectileUpgrade.disabled = true
	check_buy()

func update_coins():
	$CoinLabel.text = "$" + str(coins)

func check_buy():
	if s_upgrade < 1 && coins >= s_cost_1:
		$ShieldUpgrade.disabled = false
	else:
		$ShieldUpgrade.disabled = true
	
	if p_upgrade < 1 && coins >= p_cost_1:
		$ProjectileUpgrade.disabled = false
	elif p_upgrade == 1 && coins >= p_cost_2:
		$ProjectileUpgrade.disabled = false
	else:
		$ProjectileUpgrade.disabled = true
