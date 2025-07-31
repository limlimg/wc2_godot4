extends Node

## CBaseState is the base class of states which are the primary controllers of
## the game's behavour.
##
## This class extends Node instead of Node2D because it tends to have a 
## GUIManager as a child. If this class extended Node2D the GUIManager wouldn't
## fill the viewport automatically.
