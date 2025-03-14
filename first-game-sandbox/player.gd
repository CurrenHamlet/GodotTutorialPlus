extends Area2D

signal hit
signal update_shields
signal shield_picked_up

@export var projectile_scene: PackedScene

#Adds "speed" to inspector
@export var speed = 400

var screen_size
var player_shields
var ammo
var p_upgrade

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_shields = 0
	ammo = 0
	p_upgrade = 0
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
#Move the player
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
#Normalize player movement speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
#Clamp player to screen area
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
#Animate & rotate player
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.rotation = velocity.angle()
	
#Animate & rotate gun
	if ammo > 0:
		$Gun.visible = true
	elif ammo < 1:
		$Gun.visible = false
	
	if $Gun.visible == true:
		$Gun.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot") && $Gun.visible == true:
		shoot()

#Collide check & update shields
func _on_body_entered(body: Node2D) -> void:
		var n = body.name
		if body.is_in_group("mobs") && player_shields < 1:
			hide()
			ammo = 0
			hit.emit()
			$CollisionShape2D.set_deferred("disabled", true)
		elif body.is_in_group("mobs") && player_shields > 0:
			player_shields -= 1
			update_shields.emit(player_shields)
		elif body.is_in_group("shields"):
			player_shields = 1
			#get_tree().call_group("shields", "queue_free")
			body.queue_free()
			update_shields.emit(player_shields)
			shield_picked_up.emit()
			if p_upgrade > 0:
				ammo = 1
		
		#OLD way to reference body names (might be useful another time)
		#if n.contains("Mob") && player_shields < 1:
			#hide()
			#hit.emit()
			#$CollisionShape2D.set_deferred("disabled", true)
		#elif n.contains("Mob") && player_shields > 0:
			#player_shields -= 1
			#update_shields.emit(player_shields)
		#elif n.contains("Shield"):
			#player_shields = 1
			#get_tree().call_group("shields", "queue_free")
			#update_shields.emit(player_shields)
			#shield_picked_up.emit()

#Visible shield toggle
func _on_update_shields(player_shields) -> void:
	if player_shields > 0:
		$Shielded.visible = true
	elif player_shields < 1:
		$Shielded.visible = false

#Establish start position, show player, and activate collision
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

#Shoot
func shoot():
	var p = projectile_scene.instantiate()
	p.pen = p_upgrade
	get_tree().root.add_child(p)
	p.transform = $Gun/Marker2D.global_transform
	ammo -= 1

func _on_hud_upgrade_projectile() -> void:
	p_upgrade += 1
