-- 《Don't Starve Together》世界生成覆盖（Caves）
--
-- 仅在世界生成时生效，不会改变已生成的世界；修改后需删除对应存档才会重新生成。
--
-- 下面列出了全部可配置项：发行版修改的项默认生效，其余项已注释（游戏默认值）。
-- 需要时去掉行首的 -- 即可启用。
-- 注意：部分项（task_set、start_location 等）的默认值按世界而定，
-- 直接启用注释里的值可能不适用于当前世界。
--
-- 发行版默认修改：
--   loop                     = "never"
--   prefabswaps_start        = "classic"
--   grassgekkos              = "never"
--   twiggytrees_regrowth     = "never"

return {
	override_enabled = true,
	worldgen_preset = "DST_CAVE",
	settings_preset = "DST_CAVE",
	overrides = {

		-- WORLDGEN / MISC
		-- task_set = "default", -- cave_default
		-- start_location = "default", -- caves
		-- world_size = "default", -- default, medium, large
		-- branching = "default", -- never, least, default, most, random
		loop = "never", -- never, default, always
		-- touchstone = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- boons = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- cavelight = "default", -- never, veryslow, slow, default, fast, veryfast
		prefabswaps_start = "classic", -- classic, default, highly random

		-- WORLDGEN / RESOURCES
		-- banana = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- berrybush = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- cave_ponds = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- fern = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- flint = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- flower_cave = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- grass = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- lichen = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- marshbush = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- mushroom = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- mushtree = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- reeds = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- rock = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- sapling = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- tree_rock = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- trees = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- wormlights = "default", -- never, rare, uncommon, default, often, mostly, always, insane

		-- WORLDGEN / ANIMALS
		-- bunnymen = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- monkey = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- rocky = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- slurper = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- slurtles = "default", -- never, rare, uncommon, default, often, mostly, always, insane

		-- WORLDGEN / MONSTERS
		-- bats = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- cave_spiders = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- chess = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- fissure = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- spiders = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- tentacles = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- worms = "default", -- never, rare, uncommon, default, often, mostly, always, insane

		-- SETTINGS / MISC
		-- acidrain_enabled = "always", -- none, always
		-- atriumgate = "default", -- veryslow, slow, default, fast, veryfast
		-- earthquakes = "default", -- never, rare, default, often, always
		-- rifts_enabled_cave = "default", -- never, default, always
		-- rifts_frequency_cave = "default", -- never, rare, default, often, always
		-- weather = "default", -- never, rare, default, often, always
		-- wormattacks = "default", -- never, rare, default, often, always
		-- wormattacks_boss = "default", -- never, rare, default, often, always

		-- SETTINGS / RESOURCES
		-- regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- evergreen_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- flower_cave_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- lightflier_flower_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- mushtree_moon_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- mushtree_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- reeds_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- tree_rock_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		twiggytrees_regrowth = "never", -- never, veryslow, slow, default, fast, veryfast

		-- SETTINGS / ANIMALS
		-- bunnymen_setting = "default", -- never, rare, default, often, always
		-- dustmoths = "default", -- never, rare, default, often, always
		grassgekkos = "never", -- never, rare, default, often, always
		-- lightfliers = "default", -- never, rare, default, often, always
		-- moles_setting = "default", -- never, rare, default, often, always
		-- monkey_setting = "default", -- never, rare, default, often, always
		-- mushgnome = "default", -- never, rare, default, often, always
		-- pigs_setting = "default", -- never, rare, default, often, always
		-- rocky_setting = "default", -- never, rare, default, often, always
		-- slurtles_setting = "default", -- never, rare, default, often, always
		-- snurtles = "default", -- never, rare, default, often, always

		-- SETTINGS / MONSTERS
		-- bats_setting = "default", -- never, rare, default, often, always
		-- chest_mimics = "default", -- never, rare, default, often, always
		-- itemmimics = "default", -- never, rare, default, often, always
		-- merms = "default", -- never, rare, default, often, always
		-- molebats = "default", -- never, rare, default, often, always
		-- nightmarecreatures = "default", -- never, rare, default, often, always
		-- spider_dropper = "default", -- never, rare, default, often, always
		-- spider_hider = "default", -- never, rare, default, often, always
		-- spider_spitter = "default", -- never, rare, default, often, always
		-- spider_warriors = "default", -- never, default
		-- spiders_setting = "default", -- never, rare, default, often, always

		-- SETTINGS / GIANTS
		-- daywalker = "default", -- never, rare, default, often, always
		-- fruitfly = "default", -- never, rare, default, often, always
		-- liefs = "default", -- never, rare, default, often, always
		-- spiderqueen = "default", -- never, rare, default, often, always
		-- toadstool = "default", -- never, rare, default, often, always

		-- SETTINGS / LUNAR_MUTATIONS
		-- moon_spider = "default", -- never, rare, default, often, always
		-- mutated_birds = "default", -- never, default
		-- mutated_merm = "default", -- never, default
		-- mutated_spiderqueen = "default", -- never, default
	},
}
