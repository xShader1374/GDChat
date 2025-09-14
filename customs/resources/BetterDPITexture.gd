@tool

extends DPITexture
class_name BetterDPITexture

@export_multiline var source: String = "<svg></svg>": set = set_new_source
func set_new_source(new_source: String) -> void:
	source = new_source
	set_source(new_source)
