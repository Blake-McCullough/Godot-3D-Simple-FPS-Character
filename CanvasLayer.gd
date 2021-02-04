#By Blake McCullough
#https://github.com/Blake-McCullough
extends CanvasLayer

#sets the bar variable to the nod ProgressBar
onready var bar = $ProgressBar




func _process(delta):
	#sets health variable to current health of players
	var health = int(get_node("../../FPS").health)
	#changes variable of bar showing health to the player health
	bar.value = health
