#Made By Blake McCullough
#Discord - Spoiled_Kitten#4911
#Github - https://github.com/Blake-McCullough/
#Email - privblakemccullough@protonmail.com

extends KinematicBody
#sets the damage that player can do
var damage = 20
#sets the max health for the player
var max_health = 100
#sets player_alive variable to true
var player_alive = true
#sets regen time per fram (e.g if 60fps then it regen*60 per second increase)
var regen = 0.1
#sets player health to 100
var health = 100
#sets underattack variable to zero
var underattack = 0
#sets players starting speed
var initial_speed
#sets players sprint speed
var sprint_speed = 14
#current time for sprinting
var sprint_time = 3
#max time player can sprint before needing to slow down
var max_sprint_time = 3
#sets notsprinting variable to true
var notsprinting = true
#sets player movement speed
var speed = 7
#sets how quickly player increases speed
var acceleration = 10
#sets gravity for game
var gravity = 0.09
#sets height player can jump
var jump = 10
#sets the attack cooldown timer to 0
var attack_cooldown = 0
#sets the cooldown time for attacks
var  attack_break = 1
#sets how sensitive mouse is
var mouse_sensitivity = 0.03
#sets direction to vector 3
var direction = Vector3()
#sets velocity to vector 3
var velocity = Vector3()
#sets fall to vector 3
var fall = Vector3() 
#how many jumps the player has
var jumps = 2
#declares walls aren't able to be run
var w_runnable = false
#prepares for getting the jumps allowed at start
var initial_jumps
#wall normal
var wall_normal
#sets payer head to correct node
onready var head = $Head
#sets the aimcast variable to aimcast
onready var aimcast = $Head/Camera/AimCast
#gets timer node
onready var timer = $Timer


func regen_player():
	#checks if health is below max health
	if health < max_health:
		#adds regen ammount to health
		health = health + regen
	

func _ready():
	initial_jumps = jumps
	#makes initial speed correct
	initial_speed = speed
	#when starts makes the mouse hidden in game
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	#gets mouse movement
	if event is InputEventMouseMotion:
		#rotates on y axis
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity)) 
		#rotates on x axis
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity)) 
		#locks how far can move on x axis
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

	
func _process(delta):
	#increases cooldown for players attack
	attack_cooldown += delta
	#checks if health is at or below 0
	if health <= 0:
		#sets player variable to be dead
		player_alive = false
		#quits game
		get_tree().quit()

		#checks if been 4 or more seconds since player was last attacked
	if underattack > 4:
		#runs script to increase health for player
		regen_player()
	else:
		#increases health by adding the break between each frame (gives accurate timing)
		underattack += delta
	#runs wall run script
	wall_run()
	#checks if not sprinting
	if notsprinting:
		#checks if sprint time is under the max time allowed to sprint
		while sprint_time < max_sprint_time:
			#delays sprint regen
			yield(get_tree().create_timer(0.5), "timeout")
			#adds value to sprint
			sprint_time += 0.1
	else:
		#removes time from sprint time
		sprint_time -= delta



func attack():
	#checks if player is able to hit anything
	if aimcast.is_colliding():
		#if colliding with anything identifys what group it is in and sets to variable
		var target = aimcast.get_collider()
		#If colliding with an object in group Enemy continues
		if target.is_in_group("Enemy") and attack_cooldown > attack_break:
			#Removes health from that Enemy
			target.health -= damage
			#changes cooldown so player has to break between attacks
			attack_cooldown = 0

func wall_run():
	#checks if allowed to run on walls
	if w_runnable:		
		#checks if jump action key is pressed
		if Input.is_action_pressed("jump"):
			#checks if also pressing move forward key
			if Input.is_action_pressed("move_forward"):
				#checks if is on wall
				if is_on_wall():
					#wall is normalised to help staying on
					wall_normal = get_slide_collision(0)
					#delays how long until it grabs onto wall
					yield(get_tree().create_timer(0.2), "timeout")
					#makes gravity to zero
					fall.y = 0
					#sets direction to go the direction of the wall
					direction = -wall_normal.normal * speed
 
func _physics_process(delta):
	#checks is sprint is active and if has ability to sprint
	if Input.is_action_pressed("sprint") and sprint_time > 0.1:
		#changes speed to sprinting speed
		speed = sprint_speed
		#changes variable for not sprinting to false
		notsprinting = false
	else:
		#sets speed back when not sprinting
		speed = initial_speed
		#sets not sprinting variable to sprinting
		notsprinting = true
#Gets input from input map and if player presses fire action
	if Input.is_action_pressed("fire"): 
		#runs attack function
		attack()
	#sets movement for falling down
	move_and_slide(fall, Vector3.UP)
#sets gravity for player
	if not is_on_floor():
		#if player not on floor will make them fall to rate of gravity
		fall.y -= gravity
	else:
		#if on floor doesnt allow to climb walls
		w_runnable = false
		#sets jumps back to beginning
		jumps = initial_jumps
#Gets Input from input map and if player presses action for jumping, moves player up.
	if Input.is_action_just_pressed("jump") and jumps > 0:
		#changes direction of fall
		fall.y = jump
		#allows wall running
		w_runnable = true
		#starts timer until will fall off wall
		timer.start()
		#removes one jump from jumps allowed
		jumps -= 1

#Gets Input from input map and if player presses action for move forwards, moves player forwards.
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
#Gets Input from input map and if player presses action for move backwards, moves player backwards.
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
#Gets Input from input map and if player presses action for move left, moves player left.
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
#Gets Input from input map and if player presses action for move right, moves player right.
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
			
	#sets direction variables
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta) 
	velocity = move_and_slide(velocity, Vector3.UP) 



func _on_Timer_timeout():
	#after timer runs out sets walls allowed to be climbed to false 
	w_runnable = false
