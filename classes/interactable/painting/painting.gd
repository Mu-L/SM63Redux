extends InteractableWarp

const TIME_PEAK_JUMP = 30 # Time it takes the animated jump to reach its peak
const TIME_PEAK_SWIM = 20 # Temporary--haven't checked
const TIME_END_LONGJUMP = 8
const TIME_START_SHRINK = 16
const SHRINK_DURATION = 8
const TIME_END_SHRINK = TIME_START_SHRINK + SHRINK_DURATION
const SHRINK_SCALE_MIN = 0.75


func _animation_length() -> int:
	return 90 if move_to_scene else 60


func _begin_animation(_player):
	if !_player.swimming:
		# Force a single jump.
		_player.double_jump_state = 0
		_player.action_jump()
	
		# Set appropriate animation.
		# TODO: Control this animation manually.
		_player.airborne_anim()
	else:
		# Force a swim upward.
		_player.action_swim()


func _update_animation(_frame, _player):
	# Jump into painting
	if _frame < TIME_PEAK_JUMP:
		# Simulate a player jump.
		# TODO: Player falls differently underwater.
		# Account for this.
		
		# Apply gravity.
		_player.player_fall()
		
		# For a while, hold jump button to give extra height.
		if _frame < TIME_END_LONGJUMP:
			_player.player_jump_vary_height()
		
		# Apply movement.
		_player.player_move()
	# When this duration passes, player will hang in midair.
	
	if _frame > TIME_START_SHRINK:
		#Shrink into the painting.
		var shrink_fac = float(_frame - TIME_START_SHRINK) / SHRINK_DURATION
		_player.scale = Vector2.ONE * lerp(1, SHRINK_SCALE_MIN, shrink_fac)
			
	
	if _frame == TIME_END_SHRINK:
		# Hide player
		_player.sprite.modulate.a = 0
		
		# TODO: Juicen this up with a flash
		# (and a ripple, but that'll take shaders


func _end_animation(_player):
	#Reset player to full size and visibility.
	_player.scale = Vector2(1,1)
	_player.sprite.modulate.a = 1