-- 《Don't Starve Together》世界生成覆盖（Master / forest）
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
--   mutated_buzzard_gestalt  = "never"
--   grassgekkos              = "never"
--   twiggytrees_regrowth     = "never"
--   healthpenalty            = "none"

return {
	override_enabled = true,
	worldgen_preset = "SURVIVAL_TOGETHER",
	settings_preset = "SURVIVAL_TOGETHER",
	overrides = {

		-- WORLDGEN / GLOBAL
		-- season_start = "default", -- default, winter, spring, summer, autumn|spring, winter|summer, autumn|winter|spring|summer

		-- WORLDGEN / MISC
		-- task_set = "default", -- default, classic
		-- start_location = "default", -- default, plus, darkness
		-- world_size = "default", -- default, medium, large
		-- branching = "default", -- never, least, default, most, random
		loop = "never", -- never, default, always
		-- roads = "default", -- never, default
		-- touchstone = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- boons = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		prefabswaps_start = "classic", -- classic, default, highly random
		-- balatro = "default", -- never, default
		-- junkyard = "default", -- never, default
		-- moon_fissure = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- stageplays = "default", -- never, default
		-- terrariumchest = "default", -- never, default

		-- WORLDGEN / RESOURCES
		-- berrybush = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- cactus = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- carrot = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- flint = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- flowers = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- grass = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- marshbush = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- meteorspawner = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_berrybush = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_bullkelp = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_hotspring = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_rock = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_sapling = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_starfish = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_tree = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- mushroom = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- ocean_bullkelp = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- ocean_seastack = "ocean_default", -- ocean_never, ocean_rare, ocean_uncommon, ocean_default, ocean_often, ocean_mostly, ocean_always, ocean_insane
		-- palmconetree = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- ponds = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- reeds = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- rock = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- rock_ice = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- sapling = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- trees = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- tumbleweed = "default", -- never, rare, uncommon, default, often, mostly, always, insane

		-- WORLDGEN / ANIMALS
		-- beefalo = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- bees = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- buzzard = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- catcoon = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- lightninggoat = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moles = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_carrot = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_fruitdragon = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- ocean_otterdens = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- ocean_shoal = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- ocean_wobsterden = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- pigs = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- rabbits = "default", -- never, rare, uncommon, default, often, mostly, always, insane

		-- WORLDGEN / MONSTERS
		-- angrybees = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- chess = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- houndmound = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- merm = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- moon_spiders = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- ocean_waterplant = "ocean_default", -- ocean_never, ocean_rare, ocean_uncommon, ocean_default, ocean_often, ocean_mostly, ocean_always, ocean_insane
		-- spiders = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- tallbirds = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- tentacles = "default", -- never, rare, uncommon, default, often, mostly, always, insane
		-- walrus = "default", -- never, rare, uncommon, default, often, mostly, always, insane

		-- SETTINGS / GLOBAL
		-- specialevent = "default", -- none, default
		-- autumn = "default", -- noseason, veryshortseason, shortseason, default, longseason, verylongseason, random
		-- winter = "default", -- noseason, veryshortseason, shortseason, default, longseason, verylongseason, random
		-- spring = "default", -- noseason, veryshortseason, shortseason, default, longseason, verylongseason, random
		-- summer = "default", -- noseason, veryshortseason, shortseason, default, longseason, verylongseason, random
		-- day = "default", -- default, longday, longdusk, longnight, noday, nodusk, nonight, onlyday, onlydusk, onlynight
		-- spawnmode = "fixed", -- fixed, scatter
		-- ghostenabled = "always", -- none, always
		-- portalresurection = "none", -- none, always
		-- ghostsanitydrain = "always", -- none, always
		-- resettime = "default", -- none, slow, default, fast, always
		-- beefaloheat = "default", -- never, rare, default, often, always
		-- krampus = "default", -- never, rare, default, often, always

		-- SETTINGS / EVENTS
		-- crow_carnival = "default", -- default, enabled
		-- hallowed_nights = "default", -- default, enabled
		-- winters_feast = "default", -- default, enabled
		-- year_of_the_gobbler = "default", -- default, enabled
		-- year_of_the_varg = "default", -- default, enabled
		-- year_of_the_pig = "default", -- default, enabled
		-- year_of_the_carrat = "default", -- default, enabled
		-- year_of_the_beefalo = "default", -- default, enabled
		-- year_of_the_catcoon = "default", -- default, enabled
		-- year_of_the_bunnyman = "default", -- default, enabled
		-- year_of_the_dragonfly = "default", -- default, enabled
		-- year_of_the_snake = "default", -- default, enabled
		-- year_of_the_knight = "default", -- default, enabled

		-- SETTINGS / SURVIVORS
		-- extrastartingitems = "default", -- 0, 5, default, 15, 20, none
		-- seasonalstartingitems = "default", -- never, default
		-- spawnprotection = "default", -- never, default, always
		-- dropeverythingondespawn = "default", -- default, always
		healthpenalty = "none", -- none, always
		-- temperaturedamage = "default", -- nonlethal, default
		-- hunger = "default", -- nonlethal, default
		-- darkness = "default", -- nonlethal, default
		-- shadowcreatures = "default", -- never, rare, default, often, always
		-- brightmarecreatures = "default", -- never, rare, default, often, always

		-- SETTINGS / MISC
		-- hounds = "default", -- never, rare, default, often, always
		-- winterhounds = "default", -- never, default
		-- summerhounds = "default", -- never, default
		-- alternatehunt = "default", -- never, rare, default, often, always
		-- frograin = "default", -- never, rare, default, often, always
		-- hunt = "default", -- never, rare, default, often, always
		-- lightning = "default", -- never, rare, default, often, always
		-- lunarhail_frequency = "default", -- never, rare, default, often, always
		-- meteorshowers = "default", -- never, rare, default, often, always
		-- petrification = "default", -- none, few, default, many, max
		-- rifts_enabled = "default", -- never, default, always
		-- rifts_frequency = "default", -- never, rare, default, often, always
		-- wanderingtrader_enabled = "always", -- none, always
		-- weather = "default", -- never, rare, default, often, always
		-- wildfires = "default", -- never, rare, default, often, always

		-- SETTINGS / RESOURCES
		-- regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- basicresource_regrowth = "none", -- none, always
		-- cactus_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- carrots_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- deciduoustree_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- evergreen_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- flowers_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- moon_tree_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- palmconetree_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- reeds_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		-- saltstack_regrowth = "default", -- never, veryslow, slow, default, fast, veryfast
		twiggytrees_regrowth = "never", -- never, veryslow, slow, default, fast, veryfast

		-- SETTINGS / PORTAL_RESOURCES
		-- bananabush_portalrate = "default", -- never, rare, default, often, always
		-- lightcrab_portalrate = "default", -- never, rare, default, often, always
		-- monkeytail_portalrate = "default", -- never, rare, default, often, always
		-- palmcone_seed_portalrate = "default", -- never, rare, default, often, always
		-- portal_spawnrate = "default", -- never, rare, default, often, always
		-- powder_monkey_portalrate = "default", -- never, rare, default, often, always

		-- SETTINGS / ANIMALS
		-- bees_setting = "default", -- never, rare, default, often, always
		-- birds = "default", -- never, rare, default, often, always
		-- bunnymen_setting = "default", -- never, rare, default, often, always
		-- butterfly = "default", -- never, rare, default, often, always
		-- catcoons = "default", -- never, rare, default, often, always
		-- fishschools = "default", -- never, rare, default, often, always
		-- gnarwail = "default", -- never, rare, default, often, always
		grassgekkos = "never", -- never, rare, default, often, always
		-- moles_setting = "default", -- never, rare, default, often, always
		-- otters_setting = "default", -- never, rare, default, often, always
		-- penguins = "default", -- never, rare, default, often, always
		-- perd = "default", -- never, rare, default, often, always
		-- pigs_setting = "default", -- never, rare, default, often, always
		-- rabbits_setting = "default", -- never, rare, default, often, always
		-- wobsters = "default", -- never, rare, default, often, always

		-- SETTINGS / MONSTERS
		-- bats_setting = "default", -- never, rare, default, often, always
		-- cookiecutters = "default", -- never, rare, default, often, always
		-- frogs = "default", -- never, rare, default, often, always
		-- hound_mounds = "default", -- never, rare, default, often, always
		-- lureplants = "default", -- never, rare, default, often, always
		-- merms = "default", -- never, rare, default, often, always
		-- mosquitos = "default", -- never, rare, default, often, always
		-- pirateraids = "default", -- never, rare, default, often, always
		-- sharks = "default", -- never, rare, default, often, always
		-- spider_warriors = "default", -- never, default
		-- spiders_setting = "default", -- never, rare, default, often, always
		-- squid = "default", -- never, rare, default, often, always
		-- walrus_setting = "default", -- never, rare, default, often, always
		-- wasps = "default", -- never, rare, default, often, always

		-- SETTINGS / GIANTS
		-- antliontribute = "default", -- never, rare, default, often, always
		-- bearger = "default", -- never, rare, default, often, always
		-- beequeen = "default", -- never, rare, default, often, always
		-- crabking = "default", -- never, rare, default, often, always
		-- deciduousmonster = "default", -- never, rare, default, often, always
		-- deerclops = "default", -- never, rare, default, often, always
		-- dragonfly = "default", -- never, rare, default, often, always
		-- eyeofterror = "default", -- never, rare, default, often, always
		-- fruitfly = "default", -- never, rare, default, often, always
		-- goosemoose = "default", -- never, rare, default, often, always
		-- klaus = "default", -- never, rare, default, often, always
		-- liefs = "default", -- never, rare, default, often, always
		-- malbatross = "default", -- never, rare, default, often, always
		-- sharkboi = "default", -- never, rare, default, often, always
		-- spiderqueen = "default", -- never, rare, default, often, always

		-- SETTINGS / LUNAR_MUTATIONS
		-- moon_spider = "default", -- never, rare, default, often, always
		-- mutated_bearger = "default", -- never, default
		-- mutated_bird_gestalt = "default", -- never, default
		-- mutated_birds = "default", -- never, default
		mutated_buzzard_gestalt = "never", -- never, default
		-- mutated_deerclops = "default", -- never, default
		-- mutated_hounds = "default", -- never, default
		-- mutated_merm = "default", -- never, default
		-- mutated_spiderqueen = "default", -- never, default
		-- mutated_warg = "default", -- never, default
		-- penguins_moon = "default", -- never, default
	},
}
