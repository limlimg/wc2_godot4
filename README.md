### Before you start

extract the `assets` folder from the original apk package and put it under the project root, merging with the folder with the same name.

You will see "Error importing 'res://assets/carddef.xml'" which is because the original carddef.xml does include a syntax error (missing a quote on line 12). Please fix it.

===============================================================================

### Project structure

The root folder contains scenes and scripts corresponding to classed in the original code. Lifecycle management mirrors the api of ios ApplicationDelegate and is implemented in ec_2d_app_delegate.gd. Updating and rendering are handled by node callbacks so there is no single entry point.

`assets` folder contains resource metadata for assets that are not uploaded to the repo and need to be added from an original apk package.

`addons` folder contains an add on `assets_tools`. It includes resource importers which convert assets from `assets` folder to Godot internal formats that can be loaded faster at runtime.

`resources/imported` folder contains scripts that define the output of aforementioned importers.

`resources/assets` folder contains resources and scripts that pack different versions of an asset (e.g. mainbg.webp, mainbg_iPad.webp, mainbg-640h.webp and mainbg-568h.webp) into a single resource that can be used in the editor.

`gui` contain scenes that are used as components of ui but do not correspond to original classes.

### Current status

[-] Game visual and ui
[-] Moving armies and using cards
[] Fight army (class: CFight)
[] AI player (class: CActionAI, CActionAssist)
[] Multiplayer? (class: CPlayerManager, CPlayer, CMatchState, uis)
