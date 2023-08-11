
#const AttackSprite = preload("res://MiscRelated/AttackSpriteRelated/AttackSprite.gd")
#const ExpandingAttackSprite = preload("res://MiscRelated/AttackSpriteRelated/ExpandingAttackSprite.gd")

enum TemplateIDs {
	COMMON_UPWARD_DECELERATING_PARTICLE = 1,
	
}

static func configure_properties_of_attk_sprite(attk_sprite, template_id : int):
	if template_id == TemplateIDs.COMMON_UPWARD_DECELERATING_PARTICLE:
		attk_sprite.has_lifetime = true
		attk_sprite.lifetime = 0.5
		attk_sprite.frames_based_on_lifetime = true
		attk_sprite.y_displacement_per_sec = -40
		attk_sprite.inc_in_y_displacement_per_sec = 70
		attk_sprite.lifetime_to_start_transparency = 0.3
		attk_sprite.transparency_per_sec = 2


# for circular attk sprites
static func configure_scale_and_expansion_of_expanding_attk_sprite(attk_sprite, initial_radius : float, final_radius : float):
	var radius = attk_sprite.get_sprite_size().y / 2
	radius = attk_sprite.scale * radius
	
	# set attk sprite scale
	attk_sprite.scale.x = initial_radius / radius.x
	attk_sprite.scale.y = initial_radius / radius.y
	
	# set attk sprite scale of scale
	attk_sprite.scale_of_scale = (final_radius - initial_radius) / (attk_sprite.lifetime * radius.x)
	

