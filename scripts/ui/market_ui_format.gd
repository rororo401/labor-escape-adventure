extends RefCounted


static func format_won(value: int) -> String:
	var sign := "-" if value < 0 else ""
	var text := str(abs(value))
	var result := ""
	for index in text.length():
		var from_back := text.length() - index
		result += text[index]
		if from_back > 1 and from_back % 3 == 1:
			result += ","
	return "%s%s원" % [sign, result]


static func format_pct(value: float) -> String:
	if absf(value) < 0.005:
		return "0.00%"
	return "%+.2f%%" % value


static func stock_change_color(value: float) -> Color:
	if value > 0.005:
		return Color("#c95750")
	if value < -0.005:
		return Color("#426da3")
	return Color("#5f514c")
