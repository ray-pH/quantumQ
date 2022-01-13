extends ColorRect

var tw = null

func clear():
	#var tw = Tween.new()
	#add_child(tw)
	tw.interpolate_property(self, "modulate:a", 1.0, 0.0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tw.start()

func dim():
	#var tw = Tween.new()
	#add_child(tw)
	tw.interpolate_property(self, "modulate:a", 0.0, 1.0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tw.start()
	
func check_visible(obj):
	if obj.visible : self.dim()
	else : self.clear()

func _ready():
	self.tw = Tween.new()
	self.add_child(tw)
