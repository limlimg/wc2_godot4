extends Control

## In the original game code, GUIElements are, as its name suggests, components
## of the graphical user interface. They are organized in a tree structure, with
## GUIManager::Instance() always being the root. They communicate with each
## other via OnEvent method. Inputs trigger this method and spread to the
## children of an element if not handled by its OnEvent method. Elements can
## also create events which spread along its ancestors. This kind of events
## usually reach the GUIManager which then send them to the current active state.
##
## In this projects, use Control instead whenever possible. Inputs should be
## received via engine callbacks. Create events as signals that the actual
## receiver connects.
