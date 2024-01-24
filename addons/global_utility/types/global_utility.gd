@tool
extends Node



func _ready() -> void:
	# Configurable variables should be updated whenever the project settings change.
	if not ProjectSettings.settings_changed.is_connected(on_config_changed):
		ProjectSettings.settings_changed.connect(on_config_changed, CONNECT_DEFERRED)
	
	on_config_changed()



## Called when the game config is updated.
func on_config_changed() -> void:
	var time_elapsed: int = Time.get_ticks_usec()
	
	# Change simple properties
	for pair in _get_config_value_pairs():
		if "setting" in pair and "property" in pair:
			var setting_name: String = _get_config_property_name(pair.setting)
			var property_name: StringName = pair.property
			
			if not _config_has_value(setting_name):
				print('%s failed to find ProjectSetting: "%s"' % [ _get_config_category(), pair.setting ])
			elif not property_name in self:
				print('%s failed to find property: "%s"' % [ _get_config_category(), pair.property ])
			else:
				var value: Variant = _get_config_value(setting_name)
				if typeof(value) == typeof(get(property_name)):
					set(property_name, value)
	
	# Change complex properties
	_on_config_changed()
	
	time_elapsed = Time.get_ticks_usec() - time_elapsed


func get_config_category() -> String:
	return _get_config_category()


func get_config_value(property_name: String) -> Variant:
	property_name = _get_config_property_name(property_name)
	return _get_config_value(property_name)


## Virtual.
## Used to create the full ProjectSettings property key.
func _get_config_category() -> String:
	return ""


## Virtual.
## Used to update the externally-defined variables.
func _on_config_changed() -> void:
	pass


## Virtual.
## Used to get fixed pairs of properties.
## This is easier than using _on_config_changed to manually set variables.
## Each entry should contain "setting" and "property" values.
## "setting" is the config setting, while "property" is the script variable.
func _get_config_value_pairs() -> Array[Dictionary]:
	return []


## Sealed.
## Returns a value from the project settings.
func _get_config_value(property_name: String) -> Variant:
	if ProjectSettings.has_setting(property_name):
		return ProjectSettings.get_setting_with_override(property_name)
	else:
		return null


func _config_has_value(property_name: String) -> bool:
	return ProjectSettings.has_setting(property_name)


func _get_config_property_name(incomplete_name: String) -> String:
	return (_get_config_category() + "/" + incomplete_name)
