extends Area2D

@export var projectile_speed = 10000

var pen

func _physics_process(delta: float):
	position += transform.x * projectile_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("mobs"):
		body.queue_free()
		if pen < 2:
			queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
