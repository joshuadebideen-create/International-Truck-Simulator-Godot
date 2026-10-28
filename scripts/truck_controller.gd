
extends CharacterBody3D

@export var acceleration: float = 13.0
@export var reverse_acceleration: float = 7.0
@export var max_speed: float = 32.0
@export var steering_speed: float = 1.35
@export var braking_strength: float = 24.0
@export var rolling_resistance: float = 2.2

var throttle_input: float = 0.0
var steering_input: float = 0.0
var brake_input: float = 0.0
var forward_speed: float = 0.0

func _physics_process(delta: float) -> void:
    var drive_accel: float = acceleration
    if throttle_input < 0.0:
        drive_accel = reverse_acceleration

    forward_speed += throttle_input * drive_accel * delta

    if brake_input > 0.0:
        forward_speed = move_toward(
            forward_speed,
            0.0,
            braking_strength * brake_input * delta
        )

    if absf(throttle_input) < 0.05 and brake_input < 0.05:
        forward_speed = move_toward(
            forward_speed,
            0.0,
            rolling_resistance * delta
        )

    forward_speed = clampf(
        forward_speed,
        -max_speed * 0.35,
        max_speed
    )

    var steer_factor: float = clampf(
        absf(forward_speed) / 7.0,
        0.0,
        1.0
    )

    rotate_y(
        -steering_input * steering_speed * steer_factor * delta
    )

    var forward: Vector3 = -global_transform.basis.z
    velocity.x = forward.x * forward_speed
    velocity.z = forward.z * forward_speed
    velocity.y -= 24.0 * delta

    move_and_slide()

    if is_on_floor():
        velocity.y = 0.0

func set_controls(
    throttle: float,
    steering: float,
    brake: float
) -> void:
    throttle_input = clampf(throttle, -1.0, 1.0)
    steering_input = clampf(steering, -1.0, 1.0)
    brake_input = clampf(brake, 0.0, 1.0)
