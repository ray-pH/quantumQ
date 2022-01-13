extends Node2D

const GateClass  = preload("res://Gate.tscn")
const GateType   = preload("res://gateEnum.gd").Typ
const QCircuit   = preload("res://quantumCircuit.gd")
const comp       = preload("res://complexNumber.gd")
const popupTexts = preload("res://popupText.gd").texts

var imgScale = 0.4
var imgSize  = 128 * imgScale

var circuit = null
var resultDispAll : bool = false
var nQubit        : int = 1
var columnLength  : int = 12
var level  = null
var target = null

static func to_bin(x,n : int) -> String:
	var binStr : String = ""
	for i in n:
		binStr = ("1" if 1 & (x >> i) else "0") + binStr
	return binStr

func parse_target(output) -> Array:
	var targ = []
	targ.resize(len(output))
	for i in len(output):
		targ[i] = comp.Cx.new(output[i].x, output[i].y)
	return targ

const tolerance = 0.00001
func display_state(state : Array):
	var resultText : RichTextLabel = $"Result/resultText"
	resultText.clear()
	for eig in len(state):
		var coef : comp.Cx = state[eig]
		var probability = comp.sqabs(coef)
		var st = "%s [i]|%s⟩[/i] : %7.2f%%\n" % [
			coef.to_string(), 
			to_bin(eig,nQubit),
			probability*100
		]
		if probability > tolerance :
			var _x = resultText.append_bbcode(st)
		elif self.resultDispAll :
			var _x = resultText.append_bbcode("[color=#888]%s[/color]" % st)

func check_result():
	var success : bool = comp.eqlist_abs(self.target,self.circuit.result) \
		if self.level.prob else comp.eqlist(self.target,self.circuit.result)
	if success :
		var nextLevelID = GlobalVar.levelList[level.id + 1].id
		GlobalVar.unlockedLevel[nextLevelID] = true
		GlobalVar.save_level()
		$CanvasLayer/SuccessDialog.popup_centered()

func evaluate_circuit():
	var gates = self.compile_gate()
	var result = self.circuit.evaluate(
		gates, level.input,
		null if level.input != null else level.istate,
		null if level.input != null else level.nQ
	)
	display_state(result)
	check_result()

func compile_gate():
	var gateBoard : GridContainer = $gateBoard
	var gates = []
	for _col in range(self.columnLength):
		var row = []
		row.resize(nQubit)
		gates.append(row)
	for i in gateBoard.get_child_count():
		var gate = gateBoard.get_child(i).get_child(0)
		gates[i%columnLength][i/columnLength] = gate.typ
	return gates

func setup_qin(inp):
	for i in self.nQubit:
		var panel = Panel.new()
		var qTexture  = TextureRect.new()
		qTexture.rect_scale = Vector2(imgScale,imgScale)
		if inp == null:
			qTexture.texture = load("res://sprites/bitPsi.png")
		elif inp[i] == 0:
			qTexture.texture = load("res://sprites/bit0.png")
		else:
			qTexture.texture = load("res://sprites/bit1.png")
		panel.rect_min_size = Vector2(imgSize,imgSize)
		panel.add_child(qTexture)
		($QIn as GridContainer).add_child(panel)
		if inp == null : break
		
func result_display_set(toggled):
	self.resultDispAll = not toggled
	var last_result = self.circuit.result
	if last_result != null:
		display_state(last_result)
	
func show_help_popup():
	$CanvasLayer/InitialDialog.popup_centered()
	
func setup_result():
	var _x = ($"Result/ResultButton" as Button).connect("toggled",self,"result_display_set")
	
func setup_task(text: String):
	($Task/TaskPanel/TaskText as RichTextLabel).clear()
	var _x = ($Task/TaskPanel/TaskText as RichTextLabel).append_bbcode(text)

func setup_popup(texts : Array):
	# Success Popup
	var _c1 = $CanvasLayer/SuccessDialog/NextButton.connect("pressed",self,"go_next_level")
	var _c2 = $CanvasLayer/SuccessDialog/CloseButton.connect("pressed",$CanvasLayer/SuccessDialog,"hide")
	
	# Return Popup
	var _c3 = $CanvasLayer/returnDialog/OkButton.connect("pressed",self,"go_back_to_menu")
	var _c4 = $CanvasLayer/returnDialog/CancelButton.connect("pressed",$CanvasLayer/returnDialog,"hide")
	
	if(len(texts) == 0):
		$Dimmer.clear()
		$Task/HelpButton.disabled = true
		return
	var textLabel : RichTextLabel = $CanvasLayer/InitialDialog/Text
	for text in texts:
		if text.begins_with("res://"):
			textLabel.add_image(load(text) as Texture, 64, 64)
		else :
			var _e = textLabel.append_bbcode(text)
	show_help_popup()
	

func go_next_level():
	GlobalVar.selectedLevel = GlobalVar.levelList[level.id + 1]
	if GlobalVar.onMobile :
		var _scene = get_tree().change_scene("res://BoardMobile.tscn")
	else :
		var _scene = get_tree().change_scene("res://Board.tscn")

func go_back_to_menu():
	var _scene = get_tree().change_scene("res://LevelSelect.tscn")
	
func confirm_return():
	$CanvasLayer/returnDialog.popup_centered()

func add_locked_gate(gates):
	var gateBoard : GridContainer = $gateBoard
	for lock in gates:
		var row = lock[0]
		var col = lock[1]
		var typ = lock[2]
		var gate = gateBoard.get_child(row*columnLength + col).get_child(0)
		gate.set_type(typ)
		gate.disable()

const staticGate = [
	GateType.H, 
	GateType.X, GateType.Y, GateType.Z,
	GateType.S,
]

static func contain_static_gate(column : Array) -> bool :
	for typ in column: if staticGate.has(typ): return true
	return false

func check_ctrl_line():
	var gates = compile_gate()
	var lineBoard : GridContainer = $controlLineBoard
	for col in len(gates):
		# check if there is ControlGate in column
		if gates[col].has(GateType.Ctrl) and contain_static_gate(gates[col]):
			for row in nQubit-1:
				lineBoard.get_child(columnLength*row + col).get_child(0).hide()
			var minim = null
			var maxim = null
			for row in len(gates[col]):
				if gates[col][row] != GateType.Empty :
					if minim == null : minim = row
					maxim = row
			for row in range(minim,maxim):
				lineBoard.get_child(columnLength*row + col).get_child(0).show()
		else:
			for row in nQubit-1:
				lineBoard.get_child(columnLength*row + col).get_child(0).hide()
				

func setup_ctrl_line():
	var lineBoard : GridContainer = $controlLineBoard
	for _row in nQubit-1:
		for _col in columnLength:
			var panel = Panel.new()
			var img : TextureRect = TextureRect.new()
			img.set_scale(Vector2(imgScale,imgScale))
			img.texture = load("res://sprites/lineCtrl.png")
			panel.rect_min_size = Vector2(imgSize,imgSize)
			panel.add_child(img)
			lineBoard.add_child(panel)
			img.hide()

const originalSize = Vector2(1024,600)
func center_on_screen():
	var viewportSize : Vector2 = get_viewport_rect().size
	var dx = viewportSize.x - originalSize.x
	if dx > 0:
		var boardNode : Node2D = get_tree().root.get_child(1)
		boardNode.translate(Vector2(dx/2,0))
	
func scale_ui():
	var viewportSize : Vector2 = get_viewport_rect().size
	var dx = viewportSize.x - originalSize.x
	# Eval Button
	$EvalButton.rect_position += Vector2(dx,0)
	# PaletteBack
	$paletteBack.rect_size += Vector2(dx,0)
	# Dialog
	$CanvasLayer/InitialDialog.rect_size += Vector2(dx,0)
	$CanvasLayer/InitialDialog/Text.rect_size += Vector2(dx,0)
	# Result
	$Result.rect_position += Vector2(dx,0)
	# Task
	$Task/TaskPanel.rect_size += Vector2(dx,0)
	$Task/TaskPanel/TaskText.rect_size += Vector2(dx,0)
	# ghostLine
	$ghostLine.rect_size += Vector2(
		128*dx/64,
		(self.nQubit-1)*128
	)
	# dy
	if self.nQubit < 4 :
		var dy = 50
		$Result.rect_position += Vector2(0,-64)
		$Result/resultText.rect_size += Vector2(0,dy)
		$Task.rect_position += Vector2(0,-64)
		$Task/TaskPanel.rect_size += Vector2(0,dy)
		$Task/TaskPanel/TaskText.rect_size += Vector2(0,dy)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		# Pressing back button
		if ($CanvasLayer/returnDialog as WindowDialog).visible:
			self.go_back_to_menu()
		else:
			self.confirm_return()

func _ready():
	get_tree().set_quit_on_go_back(false)
	if GlobalVar.onMobile:
		self.imgScale = 0.5
		self.imgSize  = 128 * imgScale
		$gatePalette.imgScale = self.imgScale
		$gatePalette.imgSize  = self.imgSize
		$gatePalette.rescale()
	self.circuit = QCircuit.new()
	self.add_child(self.circuit)
	var gateBoard : GridContainer = $gateBoard
	self.level  = GlobalVar.selectedLevel
	self.nQubit = len(level.input) if level.input != null else level.nQ
	self.target = parse_target(level.output)
	scale_ui()
	($gatePalette as GridContainer).set_palette(level.gates)
	var styleTrans : StyleBoxFlat = StyleBoxFlat.new()
	styleTrans.bg_color = Color(0,0,0,0)
	for _row in nQubit:
		for _col in columnLength:
			var panel = Panel.new()
			var gate  = GateClass.instance()
			gate.palette = $gatePalette
			gate.board   = self
			gate.set_scale(Vector2(imgScale,imgScale))
			panel.rect_min_size = Vector2(imgSize,imgSize)
			panel.add_stylebox_override("panel",styleTrans)
			panel.add_child(gate)
			gateBoard.add_child(panel)
	add_locked_gate(level.locked)
	setup_qin(level.input)
	setup_result()
	setup_task(level.task)
	setup_popup(popupTexts[level.id])
	setup_ctrl_line()
	check_ctrl_line()
	$Dimmer.show()
	var _c1 = $EvalButton.connect("pressed", self, "evaluate_circuit")
	var _c2 = $MenuButton.connect("pressed", self, "confirm_return")
	var _c3 = $Task/HelpButton.connect("pressed", self, "show_help_popup")
	var _d1 = $CanvasLayer/InitialDialog.connect(
		"visibility_changed",$Dimmer,"check_visible", [$CanvasLayer/InitialDialog])
	var _d2 = $CanvasLayer/returnDialog.connect(
		"visibility_changed",$Dimmer,"check_visible", [$CanvasLayer/returnDialog])
	var _d3 = $CanvasLayer/SuccessDialog.connect(
		"visibility_changed",$Dimmer,"check_visible", [$CanvasLayer/SuccessDialog])
