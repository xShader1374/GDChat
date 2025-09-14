extends Control

var is_server: bool = OS.get_cmdline_args().has("-s")

@onready var curr_accent_color: Color = DisplayServer.get_accent_color()
@onready var curr_base_color: Color = DisplayServer.get_base_color() if not Color.TRANSPARENT else curr_accent_color.lerp(Color(0.15, 0.15, 0.15, 1.0), 0.90)

var theme_updater_tween: Tween


func _ready() -> void:
	if DisplayServer.screen_get_orientation() == DisplayServer.ScreenOrientation.SCREEN_PORTRAIT:
		if DisplayServer.screen_get_size() < Vector2i(1080.0, 1920.0):
			get_window().content_scale_factor = 2.0
		elif DisplayServer.screen_get_size() < Vector2i(1440.0, 2560.0):
			get_window().content_scale_factor = 2.5
		elif DisplayServer.screen_get_size() < Vector2i(2160.0, 3840.0):
			get_window().content_scale_factor = 3.0
	
	RenderingServer.set_default_clear_color(curr_base_color)
	set_accent_theme_colors()
	DisplayServer.set_system_theme_change_callback(smooth_update_accent_theme_colors)
	
	if !is_server:
		%WebSocketServer.queue_free()
	else:
		%WebSocketClient.queue_free()
	
	CameraServer.monitoring_feeds = true
	%Label.text = str("There are: ", CameraServer.get_feed_count(), " cameras available")
	if CameraServer.get_feed_count() > 0:
		var first_camera_feed: CameraFeed = CameraServer.feeds().front()
		if first_camera_feed.set_format(0, first_camera_feed.formats.front()):
			first_camera_feed.feed_is_active = true
			%TextureRect.texture.camera_feed_id = first_camera_feed.get_id()
	#CameraServer.monitoring_feeds = false

func generate_cert() -> void:
	var crypto: Crypto = Crypto.new()
	
	# Genera una nuova chiave RSA.
	var key: CryptoKey = crypto.generate_rsa(4096)
	
	# Genera un nuovo certificato autofirmato con la chiave specificata.
	var cert: X509Certificate = crypto.generate_self_signed_certificate(key, "CN=mydomain.com,O=xShader1374_,C=IT")
	
	# Salva la chiave e il certificato nella cartella utente.
	key.save("res://certs/key.key")
	cert.save("res://certs/cert.crt")
	
	# Crittografia
	#var data = "Some data"
	#var encrypted: PackedByteArray = crypto.encrypt(key, data.to_utf8_buffer())
	
	# Decrittografia
	#var decrypted = crypto.decrypt(key, encrypted)
	
	# Firma
	#var signature = crypto.sign(HashingContext.HASH_SHA256, data.sha256_buffer(), key)
	
	# Verifica
	#var verified = crypto.verify(HashingContext.HASH_SHA256, data.sha256_buffer(), signature, key)
	
	# Controlli
	#assert(verified)
	#assert(data.to_utf8_buffer() == decrypted)

func set_accent_theme_colors() -> void:
	theme.set_color(&"bg_color", &"Panel", curr_base_color)
	theme.set_color(&"bg_color", &"PanelContainer", curr_base_color)
	#theme.get_stylebox(&"panel", &"PopupMenu").bg_color = curr_base_color
	
	theme.set_color(&"font_color", &"Label", curr_accent_color)
	
	theme.set_color(&"font_color", &"PopupMenu", curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.25))
	theme.set_color(&"font_disabled_color", &"PopupMenu", Color(curr_accent_color, 0.5))
	theme.set_color(&"font_hover_color", &"PopupMenu", curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.15))
	
	theme.set_color(&"font_color", &"Button", curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.25))
	theme.set_color(&"font_hover_color", &"Button", curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.15))
	theme.set_color(&"font_focus_color", &"Button", curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.15))
	theme.set_color(&"font_pressed_color", &"Button", curr_accent_color)
	theme.set_color(&"font_disabled_color", &"Button", Color(curr_accent_color, 0.5))
	theme.set_color(&"icon_normal_color", &"Button", curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.25))
	theme.set_color(&"icon_hover_color", &"Button", curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.15))
	theme.set_color(&"icon_focus_color", &"Button", curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.15))
	theme.set_color(&"icon_pressed_color", &"Button", curr_accent_color)
	theme.set_color(&"icon_disabled_color", &"Button", Color(curr_accent_color, 0.5))
	theme.get_stylebox(&"focus", &"Button").border_color = Color(curr_accent_color, 0.95)
	theme.get_stylebox(&"disabled", &"Button").bg_color = Color(curr_base_color * 0.5, 0.3)
	theme.get_stylebox(&"normal", &"Button").bg_color = Color(curr_base_color * 0.75, 0.6)
	theme.get_stylebox(&"hover", &"Button").bg_color = Color(curr_base_color * 0.85, 0.75)
	theme.get_stylebox(&"pressed", &"Button").bg_color = Color(curr_base_color * 1.25, 0.85)
	
	theme.set_color(&"font_color", &"ProgressBar", curr_accent_color)
	theme.set_color(&"font_outline_color", &"ProgressBar", Color(curr_base_color * 0.3, 0.3))
	theme.get_stylebox(&"background", &"ProgressBar").bg_color = Color(curr_base_color * 0.3, 0.3)
	theme.get_stylebox(&"background", &"ProgressBar").border_color = Color(curr_accent_color, 0.95)
	theme.get_stylebox(&"fill", &"ProgressBar").bg_color = Color(curr_accent_color, 0.25)
	theme.get_stylebox(&"fill", &"ProgressBar").border_color = Color(curr_accent_color, 0.95)
func smooth_update_accent_theme_colors() -> void:
	curr_accent_color = DisplayServer.get_accent_color()
	curr_base_color = DisplayServer.get_base_color() if not Color.TRANSPARENT else curr_accent_color.lerp(Color(0.15, 0.15, 0.15, 1.0), 0.90)
	
	if theme_updater_tween:
		theme_updater_tween.kill()
	theme_updater_tween = create_tween()
	
	theme_updater_tween.set_ease(Tween.EASE_IN_OUT)
	theme_updater_tween.set_trans(Tween.TRANS_SINE)
	theme_updater_tween.set_parallel()
	
	theme_updater_tween.tween_method(RenderingServer.set_default_clear_color, RenderingServer.get_default_clear_color(), curr_base_color, 0.5)
	theme_updater_tween.tween_method(func(new_color: Color) -> void: theme.set_color(&"bg_color", &"Panel", new_color), theme.get_color(&"bg_color", &"Panel"), curr_base_color, 0.5)
	theme_updater_tween.tween_method(func(new_color: Color) -> void: theme.set_color(&"bg_color", &"PanelContainer", new_color), theme.get_color(&"bg_color", &"PanelContainer"), curr_base_color, 0.5)
	
	theme_updater_tween.tween_method(func(new_color: Color) -> void: theme.set_color(&"font_color", &"Label", new_color), theme.get_color(&"font_color", &"Label"), curr_accent_color, 0.5)
	
	theme_updater_tween.tween_method(func(new_color: Color) -> void: theme.set_color(&"font_color", &"Button", new_color), theme.get_color(&"font_color", &"Button"), curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.25), 0.5)
	theme_updater_tween.tween_method(func(new_color: Color) -> void: theme.set_color(&"font_hover_color", &"Button", new_color), theme.get_color(&"font_hover_color", &"Button"), curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.15), 0.5)
	theme_updater_tween.tween_method(func(new_color: Color) -> void: theme.set_color(&"font_focus_color", &"Button", new_color), theme.get_color(&"font_focus_color", &"Button"), curr_accent_color.lerp(Color(0.262, 0.262, 0.262), 0.15), 0.5)
	theme_updater_tween.tween_method(func(new_color: Color) -> void: theme.set_color(&"font_pressed_color", &"Button", new_color), theme.get_color(&"font_pressed_color", &"Button"), curr_accent_color, 0.5)
	theme_updater_tween.tween_method(func(new_color: Color) -> void: theme.set_color(&"font_disabled_color", &"Button", new_color), theme.get_color(&"font_disabled_color", &"Button"), Color(curr_accent_color, 0.5), 0.5)
	theme_updater_tween.tween_property(theme.get_stylebox(&"focus", &"Button"), ^"border_color", Color(curr_accent_color, 0.95), 0.5)
	theme_updater_tween.tween_property(theme.get_stylebox(&"disabled", &"Button"), ^"bg_color", Color(curr_base_color * 0.5, 0.3), 0.5)
	theme_updater_tween.tween_property(theme.get_stylebox(&"normal", &"Button"), ^"bg_color", Color(curr_base_color * 0.75, 0.6), 0.5)
	theme_updater_tween.tween_property(theme.get_stylebox(&"hover", &"Button"), ^"bg_color", Color(curr_base_color * 0.85, 0.75), 0.5)
	theme_updater_tween.tween_property(theme.get_stylebox(&"pressed", &"Button"), ^"bg_color", Color(curr_base_color * 1.25, 0.85), 0.5)


func _on_web_socket_server_client_connected(peer: WebSocketPeer, id: int, protocol: String) -> void:
	print("Client ", str(id),  " connected with protocol: ", protocol)
	print("There are now: ", %WebSocketServer.get_clients().size(), " clients connected!")
func _on_web_socket_server_client_disconnected(peer: WebSocketPeer, id: int, was_clean_close: bool) -> void:
	print("Client ", str(id),  " disconnected, was it a clean close?: ", was_clean_close)
	print("There are now: ", %WebSocketServer.get_clients().size(), " clients connected!")

func _on_web_socket_server_data_received(peer: WebSocketPeer, id: int, message: Variant, is_string: bool) -> void:
	if is_string:
		%WebSocketServer.send_text(message.get_string_from_utf8())
		#print("Message from: ", peer.get_connected_host(), " message: ", message.get_string_from_utf8())
		
		var new_label: RichTextLabel = RichTextLabel.new()
		new_label.fit_content = true
		new_label.threaded = true
		new_label.append_text(message.get_string_from_utf8())
		%VBoxContainer.add_child(new_label)
	else:
		%WebSocketServer.send(message)
		#print("Data Message from: ", peer.get_connected_host(), " data message: ", message)
		
		var loaded_image: CompressedTexture2D = bytes_to_var_with_objects(message)
		var new_texture_rect: TextureRect = TextureRect.new()
		new_texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		new_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
		
		new_texture_rect.texture = loaded_image
		%VBoxContainer.add_child(new_texture_rect)
	await get_tree().create_timer(0.0, true, false, true).timeout
	%ScrollContainer.set_deferred(&"scroll_vertical", %ScrollContainer.get_v_scroll_bar().max_value)
func _on_web_socket_client_data_received(peer: WebSocketPeer, message: Variant, is_string: bool) -> void:
	if is_string:
		var new_label: RichTextLabel = RichTextLabel.new()
		new_label.fit_content = true
		new_label.threaded = true
		new_label.append_text(message.get_string_from_utf8())
		%VBoxContainer.add_child(new_label)
	else:
		var loaded_image: CompressedTexture2D = bytes_to_var_with_objects(message)
		var new_texture_rect: TextureRect = TextureRect.new()
		new_texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		new_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP
		
		new_texture_rect.texture = loaded_image
		%VBoxContainer.add_child(new_texture_rect)
	await get_tree().create_timer(0.0, true, false, true).timeout
	%ScrollContainer.set_deferred(&"scroll_vertical", %ScrollContainer.get_v_scroll_bar().max_value)

func send_message_text(text: String) -> void:
	if text:
		if !is_server:
			%WebSocketClient.send_text(text)
		else:
			%WebSocketServer.send_text(text)
		%InputTextEditor.clear()
		#DisplayServer.virtual_keyboard_hide()
func _on_media_send_button_pressed() -> void:
	var loaded_image: CompressedTexture2D = load("res://icon.svg")
	
	#loaded_image.get_image().data
	
	if !is_server:
		%WebSocketClient.send(var_to_bytes_with_objects(loaded_image))
	else:
		%WebSocketServer.send(var_to_bytes_with_objects(loaded_image))
func _on_record_audio_button_pressed() -> void:
	pass # Replace with function body.
func _on_message_send_button_pressed() -> void:
	send_message_text(%InputTextEditor.text)

func resize_keyboard() -> void:
	size.y = get_parent_area_size().y + DisplayServer.virtual_keyboard_get_height()
func reset_size_from_keyboard() -> void:
	size.y = get_parent_area_size().y

func _on_line_edit_focus_entered() -> void:
	#await get_tree().create_timer(0.1, true, false, true).timeout
	resize_keyboard()
func _on_line_edit_focus_exited() -> void:
	#await get_tree().create_timer(0.1, true, false, true).timeout
	reset_size_from_keyboard()


func _on_web_socket_client_tree_exiting() -> void:
	if is_instance_valid(%WebSocketClient):
		%WebSocketClient.disconnect_from_host(1000, "Program Terminated")


func _on_web_socket_server_tree_exiting() -> void:
	if is_instance_valid(%WebSocketServer):
		%WebSocketServer.stop()
