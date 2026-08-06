extends Node2D

func update(delta: float) -> void:
	if visible:
		var a := maxf($Medal.modulate.a - 0.5 * delta, 0.0)
		$Medal.modulate.a = a
		$Medal.position.y -= 30.0 * delta
		if a <= 0.0:
			visible = false
