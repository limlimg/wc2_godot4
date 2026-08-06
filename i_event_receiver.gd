class_name IEventReceiver
extends Node

signal faded_out(cause: int)
signal faded_in(cause: int)

func emit_faded_out(cause: int) -> void:
	faded_out.emit(cause)


func emit_faded_in(cause: int) -> void:
	faded_in.emit(cause)
