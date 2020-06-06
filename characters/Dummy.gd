extends Sprite


signal killed

func kill():
	emit_signal("killed")
