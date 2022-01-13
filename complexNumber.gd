extends Node

# class to represent complex number

class Cx:
	var re : float
	var im : float
	
	func _init(real,imag):
		self.re = real
		self.im = imag
	
	func _to_string():
		if self.im >= 0:
			return "%7.4f + %6.4fi" % [self.re,self.im]
		else :
			return "%7.4f - %6.4fi" % [self.re,abs(self.im)]
		
static func add(a, b : Cx) -> Cx:
	return Cx.new(a.re + b.re, a.im + b.im)
	
static func mul(a, b : Cx) -> Cx:
	var real = a.re*b.re - a.im*b.im
	var imag = a.re*b.im + a.im*b.re
	return Cx.new(real,imag)

static func conjugate(z : Cx) -> Cx:
	return Cx.new(z.re, -z.im)
	
static func sqabs(z : Cx) -> float:
	return z.re*z.re + z.im*z.im

static func cast(x) -> Cx:
	return Cx.new(x,0)
	
const tresh = 0.0001
static func eq(a, b : Cx) -> bool:
	return abs(a.re - b.re) < tresh and abs(a.im - b.im) < tresh
	
static func eq_abs(a, b : Cx) -> bool:
	return abs(sqabs(a) - sqabs(b)) < tresh
	
static func eqlist(a_list, b_list) -> bool:
	if len(a_list) != len(b_list) : return false
	for i in len(a_list):
		if not eq(a_list[i],b_list[i]):
			return false
	return true
	
static func eqlist_abs(a_list, b_list) -> bool:
	if len(a_list) != len(b_list) : return false
	for i in len(a_list):
		if not eq_abs(a_list[i],b_list[i]):
			return false
	return true
