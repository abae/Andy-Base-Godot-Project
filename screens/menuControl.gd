extends VBoxContainer

@export var items_container_path: NodePath
var items_container: VBoxContainer =
var current_selection_index: int = 0

func _ready():
	# Get the VBoxContainer reference
	items_container = get_node(items_container_path)
	
	# Ensure there are children to focus on
	if items_container.get_child_count() > 0:
		# Initial focus
		items_container.get_child(current_selection_index).grab_focus()

func _unhandled_input(event):
	var child_count = items_container.get_child_count()
	if child_count == 0:
		return

	var previous_index = current_selection_index

	if event.is_action_pressed("ui_down"):
		current_selection_index = (current_selection_index + 1) % child_count
		accept_event() # Mark event as handled so others ignore it
	elif event.is_action_pressed("ui_up"):
		current_selection_index = (current_selection_index - 1 + child_count) % child_count
		accept_event()
	elif event.is_action_pressed("ui_accept"):
		# Trigger the action of the currently focused item (e.g., a button press)
		var current_item = items_container.get_child(current_selection_index)
		if current_item is Button:
			current_item.emit_signal("pressed")
			accept_event()

	# Change focus if index changed
	if previous_index != current_selection_index:
		items_container.get_child(current_selection_index).grab_focus()
