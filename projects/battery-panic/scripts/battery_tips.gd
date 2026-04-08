extends Node

# Battery Tips Database - Real-world knowledge
# Organized by category for easy expansion

# Note: class_name removed to avoid conflicts - this is a standalone database

const TIPS_BY_CATEGORY = {
	"browser": [
		{
			"title": "关闭不用的标签页",
			"description": "Chrome每个标签页消耗5-15%电量",
			"impact": "高",
			"saving_percent": 30
		},
		{
			"title": "使用Edge效率模式",
			"description": "Edge浏览器的效率模式可延长电池25%",
			"impact": "高",
			"saving_percent": 25
		},
		{
			"title": "禁用自动播放视频",
			"description": "后台视频是电量杀手",
			"impact": "中",
			"saving_percent": 15
		}
	],
	"display": [
		{
			"title": "降低屏幕亮度到40%",
			"description": "屏幕是最大耗电组件，占20-40%",
			"impact": "极高",
			"saving_percent": 40
		},
		{
			"title": "缩短屏幕关闭时间",
			"description": "1分钟无操作就关闭屏幕",
			"impact": "高",
			"saving_percent": 20
		},
		{
			"title": "使用深色模式",
			"description": "OLED屏幕可节省30-40%，LCD效果较小",
			"impact": "中",
			"saving_percent": 30
		}
	],
	"system": [
		{
			"title": "开启省电模式",
			"description": "系统会限制后台活动和性能",
			"impact": "极高",
			"saving_percent": 50
		},
		{
			"title": "关闭后台应用",
			"description": "Windows/Mac后台应用每小时耗10-15%",
			"impact": "高",
			"saving_percent": 25
		},
		{
			"title": "断开USB设备",
			"description": "移动硬盘、U盘会从电脑取电",
			"impact": "中",
			"saving_percent": 10
		},
		{
			"title": "关闭蓝牙和WiFi",
			"description": "搜索信号会持续耗电",
			"impact": "低",
			"saving_percent": 5
		}
	],
	"hardware": [
		{
			"title": "清理散热口",
			"description": "过热导致风扇高速运转，耗电增加",
			"impact": "中",
			"saving_percent": 15
		},
		{
			"title": "降低刷新率到60Hz",
			"description": "144Hz比60Hz多耗电30%",
			"impact": "中",
			"saving_percent": 30
		},
		{
			"title": "关闭键盘背光",
			"description": "RGB背光键盘耗电可观",
			"impact": "低",
			"saving_percent": 8
		}
	]
}

# Get random tip for tips screen
static func get_random_tip() -> Dictionary:
	var categories = TIPS_BY_CATEGORY.keys()
	var random_category = categories[randi() % categories.size()]
	var tips = TIPS_BY_CATEGORY[random_category]
	return tips[randi() % tips.size()]

# Get tips by impact level
static func get_tips_by_impact(impact: String) -> Array:
	var result = []
	for category in TIPS_BY_CATEGORY.values():
		for tip in category:
			if tip["impact"] == impact:
				result.append(tip)
	return result

# Calculate total potential savings
static func get_total_savings() -> int:
	var total = 0
	for category in TIPS_BY_CATEGORY.values():
		for tip in category:
			total += tip["saving_percent"]
	return total

# Get tips for specific game level
static func get_tips_for_level(level: int) -> Array:
	match level:
		1:  # Home office
			return TIPS_BY_CATEGORY["browser"] + TIPS_BY_CATEGORY["display"][:2]
		2:  # Coffee shop
			return TIPS_BY_CATEGORY["system"][:2] + TIPS_BY_CATEGORY["hardware"][:1]
		3:  # Library (quiet mode)
			return TIPS_BY_CATEGORY["display"] + TIPS_BY_CATEGORY["hardware"]
		_:
			return [get_random_tip()]

# Fun facts about batteries
const BATTERY_FACTS = [
	"锂电池在20%-80%之间循环寿命最长",
	"高温是电池杀手，40°C以上会永久损伤电池",
	"完全放电再充电是镍氢电池的习惯，锂电池不需要",
	"快充会发热，长期快充可能缩短电池寿命",
	"电池健康度80%以下建议更换",
	"长期插电使用建议限制充电到80%",
	"寒冷的天气会暂时降低电池容量",
	"原装充电器通常比第三方更保护电池"
]

static func get_random_fact() -> String:
	return BATTERY_FACTS[randi() % BATTERY_FACTS.size()]
