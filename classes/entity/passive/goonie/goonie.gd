extends StaticBody2D

const TIME_UP: int = 469 # Maximum time a bird will flap up
const TIME_DOWN: int = 84 # Maximum time a bird will swoop down

export var disabled: bool = false setget set_disabled
export var mirror: bool = false

var rng = RandomNumberGenerator.new()
var vel: Vector2 = Vector2.ZERO
var reset_position: Vector2 = position
var camera_polygon: PoolVector2Array
var block_riders: Array = []
var time_count: int = 0
var riding: int = 0
var reset_timer: int = 90

onready var camera_area: Polygon2D = $"/root/Main/CameraArea"
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var ride_area: Area2D = $RideArea
onready var safety_net: Area2D = $SafetyNet

func _ready():
	sprite.flip_h = mirror
	if camera_area != null:
		camera_polygon = Geometry.offset_polygon_2d(camera_area.polygon, 224)[0]
		var points = camera_polygon.size()
		for i in range(points):
			var from : Vector2 = camera_polygon[i]
			var to : Vector2 = camera_polygon[(i + 1) % points]
			var back_vec = Vector2(-99999, 0)
			if mirror:
				back_vec.x *= -1
			var intersect = Geometry.segment_intersects_segment_2d(from, to, position, back_vec)
			if intersect != null:
				reset_position = intersect + Vector2.LEFT * 20
	rng.seed = hash(position.x + position.y * PI) # Each bird will be different, but deterministic
	sprite.frame = rng.seed % 7
	sprite.playing = !disabled
	
	# warning-ignore:integer_division
	time_count = rng.randi_range(0, TIME_UP / 2)
	vel.x = 2 + rng.randf() * 0.5
	vel.y = -0.7 - rng.randf() * 0.25


func _physics_process(_delta) -> void:
	if !disabled:
		physics_step()


func physics_step() -> void:
	var move_vec = Vector2.ZERO
	var flip_sign = 1
	if mirror:
		flip_sign = -1 # Flip the movement direction
	
	for body in block_riders:
		if body.vel.y > 0:
			riding += 1
			block_riders.erase(body)
	
	if riding > 0:
		move_vec = Vector2(vel.x * 32.0/60.0 * flip_sign, 0.36)
		position += move_vec
		for body in ride_area.get_overlapping_bodies():
			if body.is_on_floor():
				body.move_and_slide(move_vec * 60.0, Vector2.UP)
	else:
		if sprite.animation == "flap":
			move_vec = Vector2(vel.x * 32/60 * flip_sign, vel.y*32/60)
			position += move_vec
			if time_count >= TIME_UP and sprite.frame == 2:
				sprite.animation = "swoop"
				
				# warning-ignore:integer_division
				time_count = rng.randi_range(0, TIME_DOWN/2)
		else:
			move_vec = Vector2(vel.x * 1.5 * 32/60 * flip_sign, 1.5*32/60)
			position += move_vec
			if time_count >= TIME_DOWN:
				sprite.animation = "flap"
				sprite.frame = 5
				# warning-ignore:integer_division
				time_count = rng.randi_range(0, TIME_UP/2)
	
	if riding <= 0:
		time_count += 1
	
	if camera_area != null:
		if Geometry.is_point_in_polygon(position, camera_polygon):
			reset_timer = 90
		else:
			reset_timer -= 1
			if reset_timer <= 0:
				position = reset_position
				reset_timer = 90


func _on_RideArea_body_entered(body) -> void:
	if body.vel.y > 0:
		sprite.animation = "flap"
		sprite.speed_scale = 3
		riding += 1
	else:
		block_riders.append(body)


func _on_RideArea_body_exited(body) -> void:
	if block_riders.has(body):
		block_riders.erase(body)
	else:
		if body.vel.x == 0:
			body.vel.x = vel.x / 2
		riding -= 1
		if riding <= 0:
			sprite.speed_scale = 1


func set_disabled(val) -> void:
	disabled = val
	set_collision_layer_bit(0, 0 if val else 1)
	if safety_net == null:
		safety_net = $SafetyNet
	if ride_area == null:
		ride_area = $RideArea
	if sprite == null:
		sprite = $AnimatedSprite
	safety_net.monitoring = !val
	ride_area.monitoring = !val
	sprite.playing = !val