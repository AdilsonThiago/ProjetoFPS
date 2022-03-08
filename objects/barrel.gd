extends RigidBody

var ExplosionNode = preload("res://effects/explosion.tscn")
var Life = 3

func Shooted(dmg):
	Life -= dmg
	if Life <= 0:
		var o = ExplosionNode.instance()
		o.translation = translation
		get_parent().add_child(o)
		queue_free()
	pass
