extends StaticBody2D

onready var player = $"/root/Main/Player"


var rng = RandomNumberGenerator.new()
func _ready():
	rng.randi()
	var my_random_number = rng.randf_range(0, 2)
	$Sprite.set_frame(my_random_number)

func _on_DetectionArea_body_entered(body):
	if (player.state == player.s.pound_fall && body.global_position.y < global_position.y) or (player.state == player.s.spin and (body.global_position.y > global_position.y || body.global_position.y < global_position.y) and player.spin_timer > 0): 
		queue_free()


#only make it breakable when it's spinning towards its sides, and when it's only the first few nanoseconds of the spinning.
