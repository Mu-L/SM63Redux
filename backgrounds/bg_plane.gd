extends TextureRect

export var parallax_factor = Vector2(1.0/20, 1.0/5)

var scroll = 0

onready var cam = $"/root/Main".find_node("Camera", true, false)
onready var size = texture.get_size()
onready var offset = Vector2(margin_left, margin_top)


func _process(_delta):
	# Get zoom level so we can factor that in.
	rect_scale = Vector2.ONE * Singleton.get_screen_scale(1)
	
	# Ensure we have a valid camera reference.
	if !weakref(cam).get_ref(): # DO NOT use an else statement, this has to happen sequentially
		cam = $"/root/Main".find_node("Camera", true, false)
	
	# If we successfully got a valid camera reference, do parallax logic.
	if weakref(cam).get_ref():
		# Save dimensions of camera for later.
		var cam_pos = cam.get_camera_screen_center()
		
		# Plane can't actually move relative to the camera.
		# Instead, simulate scrolling.
		
		# Find un-parallax'd position of the plane.
		var position = -cam_pos + -size
		# Parallax it.
		position *= parallax_factor
		# Apply start offset so it ends up in an expected place.
		position += offset
		
		# Wrap X position to within the main width of the texture.
		margin_left = fmod(position.x, size.x)
		# Counteract camera zoom so BG stays same size onscreen.
		margin_left *= rect_scale.x
		
		# Place Y position at its proper height.
		margin_top = position.y
		# Counteract camera zoom so BG stays same size onscreen.
		margin_top *= rect_scale.x
		# Ensure the camera never crosses below the plane.
		#margin_top = max(-size.y, margin_top)
