extends Node

@export var mob_scene: PackedScene
@export var shield_scene: PackedScene

var new_score
var high_score
var s_upgrade
var p_upgrade

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	high_score = 0
	s_upgrade = 0
	p_upgrade = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_player_hit() -> void:
	pass # Replace with function body.

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$ShieldTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	$DeathSound.play()
	
	if new_score > high_score:
		high_score = new_score
		$HUD.update_highscore(high_score)

func new_game():
	new_score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(new_score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("shields", "queue_free")
	$Music.play()

#Pause game
func pause_game():
	if get_tree().paused == false:
		get_tree().paused = true
	elif get_tree().paused == true:
		get_tree().paused = false

func _on_score_timer_timeout():
	new_score += 1
	$HUD.update_score(new_score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	$ShieldTimer.start()

#Spawn mobs
func _on_mob_timer_timeout():
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location.position
	
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
#Mob velocity at different levels
	if new_score < 5:
		var velocity = Vector2(randf_range(100.0, 150.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)
		$MobTimer.wait_time = 1.5
	elif new_score > 4 && new_score < 10:
		var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)
		$MobTimer.wait_time = 1.0
	elif new_score > 9 && new_score < 20:
		var velocity = Vector2(randf_range(250.0, 300.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)
		$MobTimer.wait_time = 0.5
	elif new_score > 19:
		var velocity = Vector2(randf_range(300.0, 350.0), 0.0)
		mob.linear_velocity = velocity.rotated(direction)
		$MobTimer.wait_time = 0.3
	
	add_child(mob, true)

#Spawn shields
func _on_shield_timer_timeout():
	if s_upgrade > 0:
		var shield = shield_scene.instantiate()
		var shield_spawn_location = $ShieldSpawnLocation
		shield_spawn_location.position = Vector2(randf_range(50, 350), randf_range(60, 600))
		shield.position = shield_spawn_location.position
	
		add_child(shield, true)

func _on_player_shield_picked_up() -> void:
	$ShieldTimer.start(randf_range(2.0, 8.0))

#Update shields on HUD (passed through from Player to HUD)
func _on_player_update_shields(player_shields) -> void:
	$HUD.update_shields(player_shields)

#Upgrades
func _on_hud_upgrade_shields():
	s_upgrade += 1

func _on_hud_upgrade_projectile():
	p_upgrade += 1
