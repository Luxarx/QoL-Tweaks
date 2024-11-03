_G.QolTweaks = _G.QolTweaks or {}

QolTweaks.modPath = ModPath
QolTweaks.savePath = SavePath .. "qol_tweaks.txt"
QolTweaks.optionsPath = ModPath .. "menu/options.txt"

QolTweaks.settings = {
    crimenet_buyjob_toggle = false,
    crimenet_buybet_toggle = false,
    briefing_buyasset_toggle = false,
    briefing_buyall_toggle = false,
    weapons_buy_toggle = false,
    weapons_buyslot_toggle = false,
    weapons_mod_toggle = false,
    weapons_cosmetics_toggle = false,
    masks_buy_toggle = false,
    masks_buyslot_toggle = false,
    masks_craft_toggle = false,
    cleaner_toggle = false,
    cleaner_show_time = false,
    cleaner_time_limit = 60
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
    log("---------------loaded-----------------")
    Utils.PrintTable(self.settings)
    log("--------------------------------------")
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

function QolTweaks:getCleanerTime()
    return self.settings["cleaner_time_limit"]
end

log(QolTweaks.settings["cleaner_toggle"])
log(QolTweaks.settings["cleaner_time_limit"])
QolTweaks:Load()
log(QolTweaks.settings["cleaner_toggle"])
log(QolTweaks.settings["cleaner_time_limit"])

MenuHelper:LoadFromJsonFile(QolTweaks.optionsPath, QolTweaks, QolTweaks.settings)

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
            log("Settings saved")
        end

        MenuCallbackHandler.QolTweaks_on_toggle = function(self, item)
            log(item:value())
            local status = item:value() == "on"
            log(status)
            QolTweaks.settings[item:name()] = status
            QolTweaks:Save()
            Utils.PrintTable(QolTweaks.settings, 3)
        end

        MenuCallbackHandler.QolTweaks_on_slider = function(self, item)
            log(QolTweaks.cleaner_time_limit)
            log(tonumber(QolTweaks.cleaner_time_limit))
            if item:value() and tonumber(item:value()) then
                log(math.ceil(tonumber(item:value())))
                log(item:value())
                log(tonumber(item:value()))
                QolTweaks.settings[item:name()] = math.ceil(item:value())
                QolTweaks:Save()
            end
            Utils.PrintTable(QolTweaks.settings)
        end
    end)

    local function expect_yes(self, params)
        params.yes_func()
    end

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

    local function skip_weapons_mod(value)
        if value then
            MenuManager.show_confirm_blackmarket_mod = expect_yes
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





    --Crime.net
    local crimenet_buyjob = QolTweaks.settings["crimenet_buyjob_toggle"]
    local crimenet_buybet = QolTweaks.settings["crimenet_buybet_toggle"]

    skip_crimenet_buyjob(crimenet_buyjob)
    skip_crimenet_buybet(crimenet_buybet)

    --Briefing
    local briefing_buyasset = QolTweaks.settings["briefing_buyasset_toggle"]
    local briefing_buyall = QolTweaks.settings["briefing_buyall_toggle"]

    skip_briefing_buyasset(briefing_buyasset)
    skip_briefing_buyall(briefing_buyall)

    --Preplanning

    --Masks and Weapons Inventory
    local weapons_buy = QolTweaks.settings["weapons_buy_toggle"]
    local weapons_buyslot = QolTweaks.settings["weapons_buyslot_toggle"]
    local weapons_mod = QolTweaks.settings["weapons_mod_toggle"]
    local weapons_cosmetics = QolTweaks.settings["weapons_cosmetics_toggle"]
    local masks_buy = QolTweaks.settings["masks_buy_toggle"]
    local masks_buyslot = QolTweaks.settings["masks_buyslot_toggle"]
    local masks_craft = QolTweaks.settings["masks_craft_toggle"]

    skip_weapons_buy(weapons_buy)
    skip_weapons_buyslot(weapons_buyslot)
    skip_weapons_mod(weapons_mod)
    skip_weapons_cosmetics(weapons_cosmetics)

    skip_masks_buy(masks_buy)
    skip_masks_buyslot(masks_buyslot)
    skip_masks_craft(masks_craft)
end

if RequiredScript == "lib/managers/enemymanager" then
    local time_limit = QolTweaks.settings["cleaner_time_limit"]
    local update = QolTweaks.settings["cleaner_toggle"]
    log()
    log("in script")
    log(time_limit)
    log(update)

    Hooks:PostHook(EnemyManager, "init", "EnemyManagerUpdateQolTweaks", function(self, t)
        log("post hook\n")
        log(time_limit)
        log(update)
        log(self._shield_disposal_lifetime)
        if update then
            self._shield_disposal_lifetime = time_limit
            log("new lifetime")
            log(update)
        end
        log(update)
        log(self._shield_disposal_lifetime)
        log("End of hook\n")
        -- Utils:PrintTable(QolTweaks.settings)
    end)

    -- function EnemyManager:set_shield_lifetime(time)
    --     self._shield_disposal_lifetime = time
    --     log("aaaaaaaaaaaaaaaaaaaaa")
    -- end

    --EnemyManager:set_shield_lifetime(QolTweaks.cleaner_time_limit)
end
