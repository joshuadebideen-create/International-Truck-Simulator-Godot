
extends Node3D

const TRUCK_SCENE = preload("res://scenes/truck.tscn")
const MOBILE_CONTROLS = preload("res://scripts/mobile_controls.gd")

var truck: CharacterBody3D
var camera: Camera3D
var speed_label: Label

func _ready() -> void:
    _create_environment()
    _create_ground()
    _create_road()
    _create_truck()
    _create_camera()
    _create_ui()

func _process(delta: float) -> void:
    if truck == null or camera == null:
        return

    var target_position = truck.global_position + Vector3(0, 5.0, 10.0)
    camera.global_position = camera.global_position.lerp(
        target_position,
        minf(delta * 3.0, 1.0)
    )
    camera.look_at(truck.global_position + Vector3(0, 1.0, 0))

    if speed_label != null:
        var speed_kmh = int(absf(truck.forward_speed) * 3.6)
        speed_label.text = "SPEED  %d km/h" % speed_kmh

func _create_environment() -> void:
    var world_environment := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.55, 0.72, 0.86)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.75, 0.78, 0.82)
    environment.ambient_light_energy = 0.8
    world_environment.environment = environment
    add_child(world_environment)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -30, 0)
    sun.light_energy = 1.2
    add_child(sun)

func _create_ground() -> void:
    var ground := StaticBody3D.new()
    ground.name = "Ground"
    add_child(ground)

    var mesh_instance := MeshInstance3D.new()
    var ground_mesh := BoxMesh.new()
    ground_mesh.size = Vector3(500, 1, 500)
    mesh_instance.mesh = ground_mesh
    mesh_instance.position.y = -0.5

    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.24, 0.42, 0.22)
    mesh_instance.material_override = material
    ground.add_child(mesh_instance)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(500, 1, 500)
    collision.shape = shape
    collision.position.y = -0.5
    ground.add_child(collision)

func _create_road() -> void:
    var road_material := StandardMaterial3D.new()
    road_material.albedo_color = Color(0.16, 0.17, 0.18)

    _add_box(
        self,
        "Road",
        Vector3(12, 0.12, 400),
        Vector3(0, 0.04, -150),
        road_material
    )

    var line_material := StandardMaterial3D.new()
    line_material.albedo_color = Color(0.95, 0.82, 0.18)

    for i in range(40):
        _add_box(
            self,
            "CentreLine",
            Vector3(0.16, 0.025, 3.0),
            Vector3(0, 0.115, -i * 8.0),
            line_material
        )

func _create_truck() -> void:
    truck = TRUCK_SCENE.instantiate() as CharacterBody3D
    truck.position = Vector3(0, 0.05, 0)
    truck.name = "Truck"
    add_child(truck)

    var red := _material(Color(0.65, 0.035, 0.025))
    var dark := _material(Color(0.08, 0.09, 0.10))
    var glass := _material(Color(0.12, 0.25, 0.32))
    var silver := _material(Color(0.55, 0.57, 0.59))

    _add_box(truck, "Chassis", Vector3(1.5, 0.45, 3.8),
        Vector3(0, 0.55, 0.1), dark)

    _add_box(truck, "Cab", Vector3(1.75, 1.55, 1.65),
        Vector3(0, 1.35, -1.15), red)

    _add_box(truck, "Windscreen", Vector3(1.38, 0.62, 0.06),
        Vector3(0, 1.68, -2.0), glass)

    _add_box(truck, "FrontBumper", Vector3(1.9, 0.22, 0.18),
        Vector3(0, 0.58, -2.08), silver)

    _add_box(truck, "TrailerPlatform", Vector3(1.55, 0.12, 2.1),
        Vector3(0, 0.92, 1.45), silver)

    for side in [-1.0, 1.0]:
        for axle_z in [-1.45, 1.25, 1.8]:
            var wheel := MeshInstance3D.new()
            wheel.name = "Wheel"
            var wheel_mesh := CylinderMesh.new()
            wheel_mesh.top_radius = 0.43
            wheel_mesh.bottom_radius = 0.43
            wheel_mesh.height = 0.24
            wheel.mesh = wheel_mesh
            wheel.rotation_degrees.z = 90
            wheel.position = Vector3(side * 0.88, 0.43, axle_z)
            wheel.material_override = dark
            truck.add_child(wheel)

func _create_camera() -> void:
    camera = Camera3D.new()
    camera.name = "ChaseCamera"
    camera.position = Vector3(0, 5, 10)
    camera.current = true
    camera.fov = 72
    add_child(camera)
    camera.look_at(Vector3(0, 1, 0))

func _create_ui() -> void:
    var canvas := CanvasLayer.new()
    add_child(canvas)

    var controls := MOBILE_CONTROLS.new()
    canvas.add_child(controls)
    controls.controls_changed.connect(_on_controls_changed)

    speed_label = Label.new()
    speed_label.text = "SPEED  0 km/h"
    speed_label.position = Vector2(24, 24)
    speed_label.add_theme_font_size_override("font_size", 28)
    speed_label.add_theme_color_override("font_color", Color.WHITE)
    canvas.add_child(speed_label)

func _on_controls_changed(
    throttle: float,
    steering: float,
    brake: float
) -> void:
    if truck != null:
        truck.set_controls(throttle, steering, brake)

func _material(color: Color) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.7
    return material

func _add_box(
    parent: Node3D,
    object_name: String,
    dimensions: Vector3,
    location: Vector3,
    material: Material
) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = object_name

    var box := BoxMesh.new()
    box.size = dimensions
    mesh_instance.mesh = box
    mesh_instance.position = location
    mesh_instance.material_override = material
    parent.add_child(mesh_instance)

    return mesh_instance
