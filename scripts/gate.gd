extends Node2D

const GateType = preload("res://scripts/gateEnum.gd").Typ
var typ = GateType.Empty
var palette : GridContainer = null
var board   : Node2D = null

func disable():
	($TextureButton as TextureButton).disabled = true
	$Grey.show()

func set_type(gate):
	self.typ = gate
	self.refresh_texture()
		
func set_type_palette():
	if self.palette != null:
		self.set_type(self.palette.selectedGate)
		board.check_ctrl_line()

func set_scale(scale):
	($TextureButton as TextureButton).rect_scale = scale
	$Grey.rect_min_size = Vector2(128,128)*scale

func refresh_texture():
	$TextureButton.texture_hover = load("res://sprites/gateHover.png")
	match self.typ:
		GateType.Empty:
			$TextureButton.texture_normal = load("res://sprites/gateEmpty.png")
			$TextureButton.texture_hover = load("res://sprites/gateEmptyhover.png")
		GateType.H:
			$TextureButton.texture_normal = load("res://sprites/gateH.png")
			$TextureButton.texture_hover  = load("res://sprites/gateHhover.png")
		GateType.X:
			if GlobalVar.useNotSymbol:
				$TextureButton.texture_normal = load("res://sprites/gateNOT.png")
				$TextureButton.texture_hover  = load("res://sprites/gateNOThover.png")
			else:
				$TextureButton.texture_normal = load("res://sprites/gateX.png")
				$TextureButton.texture_hover  = load("res://sprites/gateXhover.png")
		GateType.Y:
			$TextureButton.texture_normal = load("res://sprites/gateY.png")
			$TextureButton.texture_hover  = load("res://sprites/gateYhover.png")
		GateType.Z:
			$TextureButton.texture_normal = load("res://sprites/gateZ.png")
			$TextureButton.texture_hover  = load("res://sprites/gateZhover.png")
		GateType.Ctrl:
			$TextureButton.texture_normal = load("res://sprites/gateCtrl.png")
			$TextureButton.texture_hover = load("res://sprites/gateCtrlhover.png")
		GateType.S:
			$TextureButton.texture_normal = load("res://sprites/gateS.png")
			$TextureButton.texture_hover  = load("res://sprites/gateShover.png")

func _ready():		
	var _c = $TextureButton.connect("pressed", self, "set_type_palette")
	refresh_texture()
