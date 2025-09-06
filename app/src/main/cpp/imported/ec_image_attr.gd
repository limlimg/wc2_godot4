class_name ecImageAttr
extends Resource

## In the original game code, this struct holds a reference to the texture. In
## this port, it contains the path of the texture instead. This allows the
## content of an ecTextureRes to be queried without loading the texture.

@export
var texture_path: String

@export
var scale: float

@export
var x: float

@export
var y: float

@export
var w: float

@export
var h: float

@export
var refx: float

@export
var refy: float
