class_name IEventReceiver
extends Node

signal motion_finished(index: int)
signal faded_in(cause: int)
signal faded_out(cause: int)

func emit_motion_finished(index: int) -> void:
	motion_finished.emit(index)


func emit_faded_in(cause: int) -> void:
	faded_in.emit(cause)


func emit_faded_out(cause: int) -> void:
	faded_out.emit(cause)
