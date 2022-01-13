extends Control

const GateType = preload("res://gateEnum.gd").Typ
const gateData = {
	GateType.H : {
		name    = "Hadamard",
		sprite  = "res://sprites/gateH.png",
		zeroto  = "( |0⟩ + |1⟩ )/sqrt2",
		oneoto  = "( |0⟩ – |1⟩ )/sqrt2",
	},
	GateType.X : {
		name    = "Pauli-X",
		sprite  = "res://sprites/gateX.png",
		zeroto  = "|1⟩",
		oneoto  = "|0⟩",
	},
	GateType.Y : {
		name    = "Pauli-Y",
		sprite  = "res://sprites/gateY.png",
		zeroto  = "[/i]i[i]|1⟩",
		oneoto  = "–[/i]i[i]|0⟩",
	},
	GateType.Z : {
		name    = "Pauli-Z",
		sprite  = "res://sprites/gateZ.png",
		zeroto  = "|0⟩",
		oneoto  = "-|1⟩",
	},
	GateType.S : {
		name    = "Phase",
		sprite  = "res://sprites/gateS.png",
		zeroto  = "|0⟩",
		oneoto  = "[/i]i[i]|1⟩",
	},
}

static func gen_table(zeroto, oneto) -> Array:
	var l1 = "[table=1][cell][i]|0⟩ → %s [/i][/cell]" % zeroto
	var l2 = "[cell][i]|1⟩ → %s [/i][/cell][/table]"  % oneto
	return l1+l2

func prepare_gate_popup():
	var label : RichTextLabel = $"../CanvasLayer/GatesDialog/GatesLabel"
	var _xm = label.append_bbcode("[table=3]")
	for st in ["Gate","Symbol","Input/Output"]:
		var _x1 = label.append_bbcode("[cell][b]%s[/b][/cell]" % st)
	for st in ["             ","           ","                               "]:
		var _x1 = label.append_bbcode("[cell][code]%s[/code][/cell]" % st)
	for i in gateData:
		var gate = gateData[i]
		for st in [
			gate.name,
			"[img=64x64]%s[/img]" % gate.sprite,
			gen_table(gate.zeroto, gate.oneoto),
		] :
			var _x1 = label.append_bbcode("[cell]%s[/cell]" % st)
	var _xn = label.append_bbcode("[/table]")
		
func _on_xnot_button_pressed():
	var xbutton : Button = $"../CanvasLayer/OptionDialog/Xbutton"
	GlobalVar.useNotSymbol = xbutton.pressed
	GlobalVar.save_opti()

func prepare_option_popup():
	var xbutton : Button = $"../CanvasLayer/OptionDialog/Xbutton"
	xbutton.pressed = GlobalVar.useNotSymbol
	var _c1 =  xbutton.connect("pressed",self,"_on_xnot_button_pressed")
	#var levelGrid : GridContainer = $"../LevelContainer/VBoxContainer/LevelGrid"
	var _c11 = $"../CanvasLayer/OptionDialog/UnlockButton".connect("pressed",GlobalVar,"unlock_all_level")
	#var _c2 = $"../CanvasLayer/OptionDialog/UnlockButton".connect("pressed",levelGrid,"regenerate_level_buttons")
	#var _c3 = $"../CanvasLayer/OptionDialog/ResetButton".connect("pressed",GlobalVar,"reset_progress")
	#var _c4 = $"../CanvasLayer/OptionDialog/ResetButton".connect("pressed",levelGrid,"regenerate_level_buttons")
	
func show_gate_popup():
	$"../CanvasLayer/GatesDialog".popup_centered()
	
func show_option_popup():
	$"../CanvasLayer/OptionDialog".popup()
	
func show_about_popup():
	$"../CanvasLayer/AboutDialog".popup()

const originalSize = Vector2(1024,600)
func center_on_screen():
	var viewportSize : Vector2 = get_viewport_rect().size
	var dx = viewportSize.x - originalSize.x
	if dx > 0:
		var boardNode : Node2D = get_tree().root.get_child(1)
		boardNode.translate(Vector2(dx/2,0))
		$"../CanvasLayer/OptionDialog".rect_position += Vector2(dx/2,0)
		$"../CanvasLayer/AboutDialog".rect_position += Vector2(dx/2,0)
		($"../LevelContainer" as ScrollContainer).rect_size += Vector2(dx/2,0)

func _ready():
	center_on_screen()
	prepare_gate_popup()
	prepare_option_popup()
	var _c1 = $GateButton.connect("pressed",self,"show_gate_popup")
	var _c2 = $OptionButton.connect("pressed",self,"show_option_popup")
	var _c4 = $AboutButton.connect("pressed",self,"show_about_popup")
