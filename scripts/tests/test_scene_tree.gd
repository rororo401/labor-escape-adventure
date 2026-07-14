class_name TestSceneTree
extends SceneTree

var _test_failed := false


func fail_test(exit_code: int = 1) -> void:
	_test_failed = true
	super.quit(exit_code if exit_code != 0 else 1)


func finish_test() -> void:
	super.quit(1 if _test_failed else 0)
