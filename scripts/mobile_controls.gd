
extends Control

signal controls_changed(throttle: float, steering: float, brake: float)

var gas_pressed: bool = false
var brake_pressed: bool = false
var left_pressed: bool = false
var right_pressed: bool = false

func _ready() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    _make_button("LEFT", Vector2(28, -112), Vector2(88, 76), "left")
    _make_button("RIGHT", Vector2(124, -112), Vector2(88, 76), "right")
    _make_button("BRAKE", Vector2(-218, -112), Vector2(88, 76), "brake")
    _make_button("GAS", Vector2(-116, -112), Vector2(88, 76), "gas")

func _make_button(
    caption: String,
    offset: Vector2,
    button_size: Vector2,
    action: String
) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = button_size
    button.size = button_size
    button.anchor_left = 0.0
    button.anchor_right = 0.0
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0

    if action == "gas" or action == "brake":
        button.anchor_left = 1.0
        button.anchor_right = 1.0

    button.offset_left = offset.x
    button.offset_right = offset.x + button_size.x
    button.offset_top = offset.y
    button.offset_bottom = offset.y + button_size.y

    add_child(button)

    button.button_down.connect(_press.bind(action))
    button.button_up.connect(_release.bind(action))

func _press(action: String) -> void:
    match action:
        "gas":
            gas_pressed = true
        "brake":
            brake_pressed = true
        "left":
            left_pressed = true
        "right":
            right_pressed = true
    _send_controls()

func _release(action: String) -> void:
    match action:
        "gas":
            gas_pressed = false
        "brake":
            brake_pressed = false
        "left":
            left_pressed = false
        "right":
            right_pressed = false
    _send_controls()

func _send_controls() -> void:
    var throttle := 1.0 if gas_pressed else 0.0
    var brake := 1.0 if brake_pressed else 0.0
    var steering := 0.0

    if left_pressed:
        steering -= 1.0
    if right_pressed:
        steering += 1.0

    controls_changed.emit(throttle, steering, brake)
