extends Node3D


@onready var animator = $AnimationPlayer
@onready var hitray = $RootNode/HitRay



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("Fire"):
		animator.play("Pistol/Fire")
		print(hitray.get_collider())
		
		get_tree().call_group("NavTarget","MoveTo", hitray.get_collision_point())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
