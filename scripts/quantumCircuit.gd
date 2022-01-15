extends Node

const GateType = preload("res://scripts/gateEnum.gd").Typ
const comp = preload("res://scripts/complexNumber.gd")

var result = null

var gateCoeffs  = {
	GateType.Empty : [
		[comp.cast(1), comp.cast(0)],
		[comp.cast(0), comp.cast(1)],
	],
	GateType.H : [ 
		[comp.cast(1/sqrt(2)), comp.cast(1/sqrt(2))],
		[comp.cast(1/sqrt(2)), comp.cast(-1/sqrt(2))],
	],
	GateType.X : [ 
		[comp.cast(0), comp.cast(1)],
		[comp.cast(1), comp.cast(0)],
	],
	GateType.Y : [ 
		[comp.cast(0), comp.Cx.new(0,-1)],
		[comp.Cx.new(0,1), comp.cast(0)],
	],
	GateType.Z : [ 
		[comp.cast(1), comp.cast(0)],
		[comp.cast(0), comp.cast(-1)],
	],
	GateType.Ctrl : [],
	GateType.S : [ 
		[comp.cast(1), comp.cast(0)],
		[comp.cast(0), comp.Cx.new(0,1)],
	],
}
const staticGate = [
	GateType.H, 
	GateType.X, GateType.Y, GateType.Z,
	GateType.S,
]

static func parseInput(inp : Array) -> Array:
	# parse input into state : [0,0] -> [1,0,0,0] (|00>)
	var initState : int = 0
	var state     : Array = []
	state.resize(pow(2,len(inp)) as int)
	# convert into numeric (decimal)
	for i in len(inp)   : initState += pow(2,i) * inp[-i-1]
	# set all to 0
	for i in len(state) : state[i] = comp.cast(0)
	# set initstate into 1
	state[initState] = comp.cast(1)
	return state
	
static func parse_state_input(inp : Array) -> Array:
	var state = []
	for i in inp:
		state.append(comp.Cx.new(i.x, i.y))
	return state

func evaluate(gates, inp, istate = null, inQ = null) -> Array:
	var state  : Array
	var nState : int
	var nQ     : int
	if inp != null:
		state  = parseInput(inp)
		nState = len(state)
		nQ     = len(inp)
	else:
		state  = parse_state_input(istate)
		nState = len(state)
		nQ     = inQ
	for col in len(gates):
		# check if there is ControlGate in column
		if gates[col].has(GateType.Ctrl):
			# there is Ctrl gate
			var controlMask : int = 0
			for i in nQ: if gates[col][-i-1] == GateType.Ctrl :
				controlMask += pow(2,i) as int
			for i in nQ:
				var newstate : Array = []
				newstate.resize(nState)
				for j in len(newstate): newstate[j] = comp.cast(0)
				var typ = gates[col][-i-1]
				if staticGate.has(typ):
					for eig in len(state):
						# loop over eigenstate
						var coeff : comp.Cx = state[eig] # coeff of eig
						# eig if i-th index changed to 0 or 1
						var eig0  : int = eig & ~(1 << i)
						var eig1  : int = eig |  (1 << i)
						# current value in i-th index of eig
						var eigi  : int = (1 & (eig >> i))
						var typC = typ if (eig & controlMask) == controlMask else GateType.Empty
						newstate[eig0] = comp.add(
							newstate[eig0],
							comp.mul(gateCoeffs[typC][0][eigi],coeff)
						)
						newstate[eig1] = comp.add(
							newstate[eig1],
							comp.mul(gateCoeffs[typC][1][eigi],coeff)
						)
					# update state
					state = newstate
		else :
			# no Ctrl gate
			for i in nQ:
				var newstate : Array = []
				newstate.resize(nState)
				for j in len(newstate): newstate[j] = comp.cast(0)
				var typ = gates[col][-i-1]
				if staticGate.has(typ):
					for eig in len(state):
						# loop over eigenstate
						var coeff : comp.Cx = state[eig] # coeff of eig
						# eig if i-th index changed to 0 or 1
						var eig0  : int = eig & ~(1 << i)
						var eig1  : int = eig |  (1 << i)
						# current value in i-th index of eig
						var eigi  : int = (1 & (eig >> i))
						newstate[eig0] = comp.add(
							newstate[eig0],
							comp.mul(gateCoeffs[typ][0][eigi],coeff)
						)
						newstate[eig1] = comp.add(
							newstate[eig1],
							comp.mul(gateCoeffs[typ][1][eigi],coeff)
						)
					# update state
					state = newstate
	self.result = state
	return state

func _ready():
	pass
