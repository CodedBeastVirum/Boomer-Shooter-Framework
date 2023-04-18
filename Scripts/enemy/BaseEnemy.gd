extends CharacterBody3D

var movement_speed: float = 10
var movement_target_position: Vector3 = Vector3(-3.0,-1.912,2.0)
@onready var movetarget = $"../Node3D"

var LastKnownPlayerLocation = Vector3.ZERO
var player_visible = false

@export var Debug = false

@export var DistanceToKeep = 10

@onready var navigation_agent: NavigationAgent3D = $navigation

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func MoveToFloorBelowPoint(Target):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(Target, Target + Vector3(0, -10000, 0))
	var result = space_state.intersect_ray(query)
	if !result.is_empty():
		movement_target_position = result.position
		set_movement_target(movement_target_position)

func MoveToPlayer():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(get_position(), get_tree().get_nodes_in_group("Player")[0].get_position())
	var result = space_state.intersect_ray(query)
	if !result.is_empty():
		movement_target_position = result.position
		var AwayDir = Vector3(result.normal.x, 0 , result.normal.z)
		movement_target_position += AwayDir * DistanceToKeep
	
		set_movement_target(movement_target_position)

func locatePlayer():
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(get_position(), get_tree().get_nodes_in_group("Player")[0].get_position())
	var result = space_state.intersect_ray(query)
	var DrawCol = Color.GREEN
	
	if !result.is_empty():
		if result.collider.is_in_group("Player"):
			print("Located_player")
			player_visible = true
			LastKnownPlayerLocation = result.position
			DrawCol = Color.GREEN
		else:
			player_visible = false
			print("player_out_of_sight")
			DrawCol = Color.RED
	
	if Debug:
		DebugDraw.draw_line(get_position(),get_tree().get_nodes_in_group("Player")[0].get_position(),DrawCol)
		DebugDraw.draw_sphere(LastKnownPlayerLocation,0.5,Color.YELLOW)

func _physics_process(delta):
	#if navigation_agent.is_navigation_finished():
		#locatePlayer()
		#set_movement_target(movetarget.get_position())
		
		#return
		
	locatePlayer()
	if !player_visible:
		MoveToFloorBelowPoint(LastKnownPlayerLocation)
	else:
		MoveToPlayer()
	#print(navigation_agent.is_target_reachable())
	#print(navigation_agent.get_next_path_position())
	
	var current_agent_position: Vector3 = global_transform.origin
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * movement_speed

	set_velocity(new_velocity)
	move_and_slide()
