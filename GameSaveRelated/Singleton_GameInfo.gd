extends Reference


const GAME_VERSION__MAJOR : int = 1
const GAME_VERSION__MINOR : int = 0
const GAME_VERSION__PATCH : int = 0
const GAME_VERSION__REVISION : int = 0

const IS_GAME_DEMO : bool = false

static func get_game_version_as_text():
	return "%s.%s.%s.%s" % [GAME_VERSION__MAJOR, GAME_VERSION__MINOR, GAME_VERSION__PATCH, GAME_VERSION__REVISION]
