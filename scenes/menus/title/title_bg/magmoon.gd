extends Sprite2D

var progress = 0


func _process(delta):
	var dmod = 60 * delta
	var scalar = get_parent().scale_vec
	scale = scalar * Vector2.ONE
	progress = fmod(progress + (1.0 / 60.0) / 10 * dmod, 2.0)
	position.y = 90 - sin((progress - 0.1) * PI) * 45
	position.x = get_window().size.x * (progress - 0.1)
