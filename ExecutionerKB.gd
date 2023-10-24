extends CharacterBody3D

@export var Bullet = preload("res://Bullet.tscn")

@export var max_speed = 50.0
@export var acceleration = 0.6
@export var pitch_speed = 1.5
@export var roll_speed = 1.9
@export var yaw_speed = 0.75
@export var input_response = 8.0

var _velocity = Vector3.ZERO
var _forward_speed = 0.0
var _pitch_input = 0.0
var _roll_input = 0.0
var _yaw_input = 0.0
var _can_shoot = true


func _ready():
	#Debug.stats.add_property(self, "_velocity", "length")
	$Executioner2.material_override = $Executioner2.get_active_material(0).duplicate()
#	$Executioner.set_surface_material(1, $Executioner.get_surface_material(1).duplicate())
	$ThrustLeft.emitting = true
	$ThrustRight.emitting = true

var is_throttle_up = false
var is_throttle_down = false

func get_input(delta):

	is_throttle_up = Input.is_action_pressed("throttle_up")
	is_throttle_down = Input.is_action_pressed("throttle_down")

	if is_throttle_down or is_throttle_up:
		var acceleration_weight = acceleration * delta
		if is_throttle_up:
			_forward_speed = lerp(_forward_speed, max_speed, acceleration_weight)
		if is_throttle_down:
			_forward_speed = lerp(_forward_speed, 0.0, acceleration_weight)

	var input_response_weight = float(input_response * delta)
	var pitch = float(Input.get_action_strength("pitch_up") - Input.get_action_strength("pitch_down"))
	var roll = float(Input.get_action_strength("roll_left") - Input.get_action_strength("roll_right"))
	var yaw = float(Input.get_action_strength("yaw_left") - Input.get_action_strength("yaw_right"))

	_pitch_input = lerp(_pitch_input, pitch, input_response_weight)
	_roll_input = lerp(_roll_input, roll, input_response_weight)
	_yaw_input = lerp(_yaw_input, yaw, input_response_weight)

	_yaw_input = _roll_input

	if Input.is_action_pressed("shoot") and _can_shoot:
		_can_shoot = false
		$Timer.start()
		AudioManager.play("res://assets/sfx_07b.ogg")
		for gun in $Guns.get_children():
			var b = Bullet.instantiate()
			owner.add_child(b)
			b.global_transform = gun.global_transform
			b.speed += _velocity.length()
			


func _physics_process(delta):
	get_input(delta)
	transform.basis = transform.basis.rotated(transform.basis.z, _roll_input * roll_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.x, _pitch_input * pitch_speed * delta)
	transform.basis = transform.basis.rotated(transform.basis.y, _yaw_input * yaw_speed * delta)
	transform.basis = transform.basis.orthonormalized()
	_velocity = -transform.basis.z * _forward_speed
	move_and_collide(_velocity * delta)


func _on_Timer_timeout():
	_can_shoot = true
