extends MarginContainer
class_name VirtualKeyboardMarginContainer

@onready var margin_bottom_default: int = get_tree().current_scene.theme.get_constant(&"margin_bottom", &"MarginContainer")

var new_margin: int
var final_value: int

func _ready() -> void:
	if !DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		set_script(null)

func _process(_delta: float) -> void:
	new_margin = DisplayServer.virtual_keyboard_get_height()
	new_margin /= int(DisplayServer.screen_get_scale())
	new_margin -= int(get_viewport_rect().end.y - get_global_rect().end.y)
	
	final_value = roundi((margin_bottom_default + new_margin) / get_window().content_scale_factor)
	add_theme_constant_override(&"margin_bottom", clampi( final_value, margin_bottom_default, final_value ))
