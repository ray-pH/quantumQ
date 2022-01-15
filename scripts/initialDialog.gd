extends WindowDialog

var tw = null

func _on_about_to_show():
	tw.interpolate_property(self, "modulate:a", 0.0, 1.0, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	self.rect_pivot_offset = self.rect_size/2.0
	tw.interpolate_property(self, "rect_scale", Vector2(0.0,0.0), Vector2(1.0,1.0), 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tw.start()

func _ready():
	self.tw = Tween.new()
	self.add_child(self.tw)
	var _c1 = self.connect("about_to_show",self,"_on_about_to_show")
