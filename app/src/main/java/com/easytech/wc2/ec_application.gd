extends "res://core/java/android/app/application.gd"

## In Android, Application class is the "main" class of an App and is the first
## to be instantiated when the App is launched. android_manifest.xml specify one
## of Application class or its subclasses to be used by the App.
##
## The original game code does subclass Application as ecApplication but it does
## nothing.
## 
## In this Godot port, because Activity is not treated as the main scene, this
## class is instantiated in "res://app/src/main/android_manifest.tscn" which in
## turn is set as an Autoload.
