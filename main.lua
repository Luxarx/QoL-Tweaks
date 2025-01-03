_G.QolTweaks = _G.QolTweaks or {}

QolTweaks.modPath = ModPath
QolTweaks.savePath = SavePath .. "qol_tweaks.txt"
QolTweaks.optionsPath = ModPath .. "menu/options.txt"
QolTweaks.skipsPath = ModPath .. "menu/confirm_skip.json"
QolTweaks.timersPath = ModPath .. "menu/timers.json"
QolTweaks.shieldsPath = ModPath .. "menu/shield_tweaks.json"

QolTweaks.settings = {
    crimenet_buyjob_toggle = false,
    crimenet_buybet_toggle = false,
    briefing_buyasset_toggle = false,
    briefing_buyall_toggle = false,
    preplanning_rebuy_toggle = false,
    weapons_buy_toggle = false,
    weapons_buyslot_toggle = false,
    weapons_mod_toggle = false,
    weapons_buymod_toggle = false,
    weapons_cosmetics_toggle = false,
    masks_buy_toggle = false,
    masks_buyslot_toggle = false,
    masks_craft_toggle = false,
    shield_limit_toggle = false,
    shield_limit = 8,
    cleaner_toggle = false,
    cleaner_show_time = false,
    cleaner_time_limit = 60,
    protector_toggle = false,
    protector_show_time = false,
    protector_time_limit = 60,
    fuse_timer_toggle = false,
    fuse_timer_value = 2,
    skip_title_toggle = false,
    shield_push_toggle = false,
    shield_push_force_min = 0,
    shield_push_force_max = 0,
    shield_push_spread = 0,
    shield_push_mass_factor = 1
}

function QolTweaks:Load()
    local file = io.open(self.savePath, "r")
    local file_opt
    local data

    if not file then
        file_opt = io.open(self.optionsPath, "r")
        if not file_opt then
            return false
        else
            data = json.decode(file_opt:read("*all"))
            file_opt:close()
        end
    else
        data = json.decode(file:read("*all"))
        file:close()
    end

    if data then
        for k, v in pairs(data) do
            self.settings[k] = v
        end
    end
end

function QolTweaks:Save()
    local file = io.open(self.savePath, "w")
    if file then
        file:write(json.encode(self.settings))
        file:close()
    end
end

function QolTweaks:getSettings()
    return self.settings
end

function QolTweaks:getShieldLimitState()
    return self.settings["shield_limit_toggle"]
end

function QolTweaks:getShieldLimit()
    return self.settings["shield_limit"]
end

function QolTweaks:getCleaner()
    return self.settings["cleaner_toggle"]
end

function QolTweaks:getProtector()
    return self.settings["protector_toggle"]
end

function QolTweaks:getCleanerTime()
    return self.settings["cleaner_time_limit"]
end

function QolTweaks:getProtectorTime()
    return self.settings["protector_time_limit"]
end

function QolTweaks:getSkipTitle()
    return self.settings["skip_title_toggle"]
end

function QolTweaks:getShieldPush()
    return self.settings["shield_push_toggle"]
end

function QolTweaks:getShieldForceMin()
    return self.settings["shield_push_force_min"]
end

function QolTweaks:getShieldForceMax()
    return self.settings["shield_push_force_max"]
end

function QolTweaks:getShieldMassFactor()
    return self.settings["shield_push_mass_factor"]
end

function QolTweaks:getShieldSpread()
    return self.settings["shield_push_spread"]
end

QolTweaks:Load()
MenuHelper:LoadFromJsonFile(QolTweaks.optionsPath, QolTweaks, QolTweaks.settings)
MenuHelper:LoadFromJsonFile(QolTweaks.timersPath, QolTweaks, QolTweaks.settings)
MenuHelper:LoadFromJsonFile(QolTweaks.skipsPath, QolTweaks, QolTweaks.settings)
MenuHelper:LoadFromJsonFile(QolTweaks.shieldsPath, QolTweaks, QolTweaks.settings)

if RequiredScript == "lib/managers/menumanager" then
    Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitQolTweaks", function(loc)
        for __, filename in pairs(file.GetFiles(QolTweaks.modPath .. "loc/")) do
            local str = filename:match('^(.*).txt$')
            if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
                loc:load_localization_file(QolTweaks.modPath .. "loc/" .. filename)
                break
            end
        end
        loc:load_localization_file(QolTweaks.modPath .. "loc/english.txt", false)
    end)

    Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_QolTweaks", function(menu_manager)
        MenuCallbackHandler.QolTweaks_save = function(self, item)
            QolTweaks:Save()
        end

        MenuCallbackHandler.QolTweaks_on_toggle = function(self, item)
            QolTweaks.settings[item:name()] = item:value() == "on"
            QolTweaks:Save()
        end

        MenuCallbackHandler.QolTweaks_slider = function(self, item)
            if item:value() and tonumber(item:value()) then
                local new_value = math.round_with_precision(item:value(), item._decimal_count)

                QolTweaks.settings[item:name()] = new_value
                QolTweaks:Save()
            end
        end

        MenuCallbackHandler.QolTweaks_shield_purge = function(self)
            if managers.enemy then
                local total = managers.enemy:purge_shields()
            end
        end
    end)

    local function expect_yes(self, params)
        params.yes_func()
    end

    ------------------------------------------------------------------------------------
    --Crime.NET--
    ------------------------------------------------------------------------------------

    local function skip_crimenet_buyjob(value)
        if value then
            MenuManager.show_confirm_buy_premium_contract = expect_yes
        end
    end

    local function skip_crimenet_buybet(value)
        if value then
            MenuManager.show_confirm_pay_casino_fee = expect_yes
        end
    end

    local crimenet_buyjob = QolTweaks.settings["crimenet_buyjob_toggle"]
    local crimenet_buybet = QolTweaks.settings["crimenet_buybet_toggle"]

    skip_crimenet_buyjob(crimenet_buyjob)
    skip_crimenet_buybet(crimenet_buybet)

    ------------------------------------------------------------------------------------
    --Briefing--
    ------------------------------------------------------------------------------------

    local function skip_briefing_buyasset(value)
        if value then
            MenuManager.show_confirm_mission_asset_buy = expect_yes
        end
    end

    local function skip_briefing_buyall(value)
        if value then
            MenuManager.show_confirm_mission_asset_buy_all = expect_yes
        end
    end

    local briefing_buyasset = QolTweaks.settings["briefing_buyasset_toggle"]
    local briefing_buyall = QolTweaks.settings["briefing_buyall_toggle"]

    skip_briefing_buyasset(briefing_buyasset)
    skip_briefing_buyall(briefing_buyall)

    ------------------------------------------------------------------------------------
    --Preplanning--
    ------------------------------------------------------------------------------------
    local function skip_preplanning_rebuy(value)
        MenuManager.show_confirm_preplanning_rebuy = expect_yes
    end

    local preplanning_rebuy = QolTweaks.settings["preplanning_rebuy_toggle"]

    skip_preplanning_rebuy(preplanning_rebuy)

    ------------------------------------------------------------------------------------
    --Masks and Weapons Inventory--
    ------------------------------------------------------------------------------------
    local function skip_weapons_buy(value)
        if value then
            MenuManager.show_confirm_blackmarket_buy = expect_yes
        end
    end

    local function skip_weapons_buyslot(value)
        if value then
            MenuManager.show_confirm_blackmarket_buy_weapon_slot = expect_yes
        end
    end

    local function skip_weapons_sell(value)
        if value then
            MenuManager.show_confirm_blackmarket_sell = expect_yes
        end
    end

    local function skip_weapons_mod(value)
        if value then
            MenuManager.show_confirm_blackmarket_mod = expect_yes
        end
    end

    local function skip_weapons_buymod(value)
        if value then
            MenuManager.show_confirm_blackmarket_weapon_mod_purchase = expect_yes
        end
    end

    local function skip_weapons_cosmetics(value)
        if value then
            MenuManager.show_confirm_weapon_cosmetics = expect_yes
        end
    end

    local function skip_masks_buy(value)
        if value then
            MenuManager.show_confirm_blackmarket_buy = expect_yes
        end
    end

    local function skip_masks_buyslot(value)
        if value then
            MenuManager.show_confirm_blackmarket_buy_mask_slot = expect_yes
        end
    end

    local function skip_masks_craft(value)
        if value then
            MenuManager.show_confirm_blackmarket_finalize = expect_yes
        end
    end

    local weapons_buy = QolTweaks.settings["weapons_buy_toggle"]
    local weapons_buyslot = QolTweaks.settings["weapons_buyslot_toggle"]
    local weapons_sell = QolTweaks.settings["weapons_sell_toggle"]
    local weapons_mod = QolTweaks.settings["weapons_mod_toggle"]
    local weapons_buymod = QolTweaks.settings["weapons_buymod_toggle"]
    local weapons_cosmetics = QolTweaks.settings["weapons_cosmetics_toggle"]
    local masks_buy = QolTweaks.settings["masks_buy_toggle"]
    local masks_buyslot = QolTweaks.settings["masks_buyslot_toggle"]
    local masks_craft = QolTweaks.settings["masks_craft_toggle"]

    skip_weapons_buy(weapons_buy)
    skip_weapons_buyslot(weapons_buyslot)
    skip_weapons_sell(weapons_sell)
    skip_weapons_mod(weapons_mod)
    skip_weapons_buymod(weapons_buymod)
    skip_weapons_cosmetics(weapons_cosmetics)

    skip_masks_buy(masks_buy)
    skip_masks_buyslot(masks_buyslot)
    skip_masks_craft(masks_craft)
end



if RequiredScript == "lib/states/menutitlescreenstate" then
    Hooks:PreHook(MenuTitlescreenState, "get_start_pressed_controller_index", "MenuTitlescreenStatePressQol", function()
        if not _G.IS_VR and QolTweaks:getSkipTitle() then
            return 1
        end
    end)
end

if RequiredScript == "lib/managers/enemymanager" then
    local default_time = 60
    local default_total = 8

    function EnemyManager:purge_shields()
        if not self._enemy_data then
            return -1
        end

        local enemy_data = self._enemy_data
        local shields = enemy_data.shields
        local purge_count = enemy_data.nr_shields

        for key, data in pairs(shields) do
            self:unregister_shield(data.unit)
            data.unit:set_slot(0)
            shields[key] = nil
        end

        return purge_count
    end

    function EnemyManager:find_dynamic_body(unit)
        local body = unit:body(0)
        if body and body:enabled() and body:dynamic() then
            return body
        end

        local closest_body = nil
        local closest_distance_sq = math.huge
        local nr_bodies = unit:num_bodies()
        local original_com = unit:position()

        for i = 0, nr_bodies - 1 do
            local test_body = unit:body(i)
            if test_body:enabled() and test_body:dynamic() then
                local distance_sq = mvector3.distance_sq(test_body:center_of_mass(), original_com)
                if distance_sq < closest_distance_sq then
                    closest_distance_sq = distance_sq
                    closest_body = test_body
                end
            end
        end

        return closest_body
    end

    function EnemyManager:push_shield(shield_unit, min_force, max_force, mass_factor)
        if alive(shield_unit) then
            local shield_body = self:find_dynamic_body(shield_unit)
            if shield_body then
                local random_direction = Vector3(
                    math.rand(-1, 1),
                    math.rand(-1, 1),
                    math.rand(-0.5, 1)
                )
                mvector3.normalize(random_direction)

                local shield_spread = QolTweaks:getShieldSpread()
                random_direction = random_direction:spread(shield_spread)

                local force_magnitude = math.random(min_force, max_force)
                mvector3.set_length(random_direction, force_magnitude)

                local push_position = shield_body:center_of_mass() +
                    Vector3(math.rand(-10, 10), math.rand(-10, 10), math.rand(20, 30))

                shield_body:push_at(shield_body:mass() * mass_factor, random_direction, push_position)
            end
        end
    end

    Hooks:PostHook(EnemyManager, "init", "EnemyManagerInitQol", function(self)
        local total_shields = default_total
        local time_limit = default_time

        QolTweaks:Load()
        local cleaner = QolTweaks:getCleaner()
        local cleaner_time = QolTweaks:getCleanerTime()
        local protector = QolTweaks:getProtector()
        local protector_time = QolTweaks:getProtectorTime()

        if QolTweaks:getShieldLimitState() then
            total_shields = QolTweaks:getShieldLimit()
        end

        if cleaner and not protector then
            time_limit = cleaner_time
        elseif not cleaner and protector then
            time_limit = protector_time
        end

        self._shield_disposal_lifetime = time_limit
        self._MAX_NR_SHIELDS = total_shields
    end)

    Hooks:PreHook(EnemyManager, "register_shield", "EnemyManagerRegisterQol", function(self)
        local total_shields = default_total
        local time_limit = default_time
        if QolTweaks:getShieldLimitState() then
            total_shields = QolTweaks:getShieldLimit()
        end
        if QolTweaks:getCleaner() and not QolTweaks:getProtector() then
            time_limit = QolTweaks:getCleanerTime()
        elseif not QolTweaks:getCleaner() and QolTweaks:getProtector() then
            time_limit = QolTweaks:getProtectorTime()
        end

        self._shield_disposal_lifetime = time_limit
        self._MAX_NR_SHIELDS = total_shields
    end)




    Hooks:PostHook(EnemyManager, "register_shield", "EnemyManagerPushQol", function(self, shield_unit)
        if QolTweaks:getShieldPush() then
            local min_force = QolTweaks:getShieldForceMin()
            local max_force = QolTweaks:getShieldForceMax()
            local mass_factor = QolTweaks:getShieldMassFactor()
            if min_force > max_force then
                max_force = min_force
            end

            self:push_shield(shield_unit, min_force, max_force, mass_factor)
        end
    end)




    Hooks:PreHook(EnemyManager, "unregister_shield", "EnemyManagerPreUnregisterQol", function(self)
        local total_shields = default_total
        local time_limit = default_time
        if QolTweaks:getShieldLimitState() then
            total_shields = QolTweaks:getShieldLimit()
        end

        if QolTweaks:getShieldLimitState() then
            total_shields = QolTweaks:getShieldLimit()
        end
        if QolTweaks:getCleaner() and not QolTweaks:getProtector() then
            time_limit = QolTweaks:getCleanerTime()
        elseif not QolTweaks:getCleaner() and QolTweaks:getProtector() then
            time_limit = QolTweaks:getProtectorTime()
        end

        self._MAX_NR_SHIELDS = total_shields
        self._shield_disposal_lifetime = time_limit
    end)
end
if RequiredScript == "lib/units/weapons/grenades/concussiongrenade" then
    local update = QolTweaks.settings["fuse_timer_toggle"]
    if update then
        Hooks:PostHook(ConcussionGrenade, "_setup_from_tweak_data", "ConcussionGrenadeQol", function(self, t)
            self._init_timer = QolTweaks.settings["fuse_timer_value"]
        end)
    end
end
