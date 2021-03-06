extends CenterContainer

# -------------------------------------------------------------------------
# Signals
# -------------------------------------------------------------------------
signal game_over()


# -------------------------------------------------------------------------
# Handler Methods
# -------------------------------------------------------------------------

func _on_show_ui(ui_name : String) -> void:
	visible = ui_name == name


func _on_BTN_Done_pressed():
	emit_signal("game_over")
