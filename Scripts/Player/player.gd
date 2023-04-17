extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

@export var CamTiltStrength = 100
@export var CamSensitivity = 100

@export var GroundFriction = 1.1
@export var AirFriction = 1.05

@onready var campivot = $CamPivot
@onready var cam = $"CamPivot/Player Cam"

var LookMoveVec: Vector2



# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _unhandled_input(event):
	if event.is_action("Fire"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action("UnlockMouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.is_class("InputEventMouseMotion"):
			LookMoveVec = event.relative
			

func HandleCamera():
	rotate_y(-LookMoveVec.x / CamSensitivity) #Horizontal Movement of the camera
	cam.rotate_x(-LookMoveVec.y / CamSensitivity) #Vertical Movement of the camera
	campivot.rotation.z = -(transform.basis.x.dot(velocity.normalized()) * velocity.length() / CamTiltStrength)
	
	#print(cam.rotation.x)
	
	cam.rotation.x = clamp(cam.rotation.x,deg_to_rad(-90),deg_to_rad(90))
	
	LookMoveVec = Vector2(0,0) # reset the movement vector afterwards

func HandleMoveInAlignmentWithCamera():
	var InputDir = Vector3()
	
	if Input.is_action_pressed("Forward"):
		InputDir += -global_transform.basis.z
	if Input.is_action_pressed("Back"):
		InputDir += global_transform.basis.z
	if Input.is_action_pressed("Left"):
		InputDir += -global_transform.basis.x
	if Input.is_action_pressed("Right"):
		InputDir += global_transform.basis.x
		
	#InputDir = InputDir.normalized()
	return InputDir

func _physics_process(delta):
	
	
	HandleCamera()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	velocity += HandleMoveInAlignmentWithCamera()
	
	if is_on_floor():
		velocity = velocity/ GroundFriction
	if !is_on_floor():
		velocity.x = velocity.x/AirFriction
		velocity.z = velocity.z/AirFriction
	
	
	move_and_slide()
