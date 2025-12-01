### Before you start

extract the assets folder from the original apk package and put it under app/src/main/

===============================================================================

### Project structure

`core/` contains code that mimic android APIs

`app/src/main/java/` contains code that corresponds to the java code in classes.dex in the original game.

Those two folders probably don't need further work.

Code that corresponds to the native code in libworld-conqueror-2.so in the original game is placed directly under `app/src/main/cpp/`. `native-lib.gd` contains global functions including Java_* functions which are entry points to the native code. API classes ecGraphics, ecSoundBox and ecFile have been implemented, so the rest of the project should be able to be done by merely translating the original native code.

Beyond that, currently this repo contains many efforts to fit the implementation to the mechanism of Godot engine. These may need to be refactored if doing the rest of the project by translating the original native code:
- CLogoState -> main scene
- CMenuState, CLoadState, CGameState -> scene to switch to
- GUIElement -> Control Node
- transition/animation handled by Update/OnUpdate -> Tween
- rendering -> Sprite/TextureRect nodes
- input handling -> Godot input handling
- GUIElement sending Event to its parent -> signal

This also leads to the other folders in this repo:

`addons/assets_tools/` contains ResourceImporters that parse the assets files in the editor so that they are converted to Godot Resource format in the exported game which can be loaded faster.

`app/src/main/cpp/imported_containers/` defines the Resource classes that are the result of said import.

`app/src/main/cpp/scene_system_resource/` contains code and resources that handles the GUI layout and the loading of textures, images and fonts that are dependent on the size (aspect ratio actually) of the screen/window.