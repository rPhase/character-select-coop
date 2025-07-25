-- name: Character Select
-- description:\\#ffff33\\-- Character Select Coop v1.16 --\n\n\\#dcdcdc\\A Library / API made to make adding and using Custom Characters as simple as possible!\nUse\\#ffff33\\ /char-select\\#dcdcdc\\ to get started!\n\nCreated by:\\#008800\\ Squishy6094\n\n\\#AAAAFF\\Updates can be found on\nCharacter Select's Github:\n\\#6666FF\\Squishy6094/character-select-coop
-- pausable: false
-- category: cs

if incompatibleClient then return 0 end

---@param hookEventType LuaHookedEventType
local function create_hook_wrapper(hookEventType)
    local callbacks = {}

    hook_event(hookEventType, function(...)
        for _, func in pairs(callbacks) do
            func(...)
        end
    end)

    return function(func)
        table.insert(callbacks, func)
    end
end

cs_hook_mario_update = create_hook_wrapper(HOOK_MARIO_UPDATE)

-- localize functions to improve performance - main.lua
local mod_storage_load,tonumber,mod_storage_save,djui_popup_create,tostring,djui_chat_message_create,is_game_paused,obj_get_first_with_behavior_id,djui_hud_is_pause_menu_created,camera_freeze,hud_hide,vec3f_copy,set_mario_action,set_character_animation,camera_unfreeze,hud_show,type,get_id_from_behavior,obj_has_behavior_id,network_local_index_from_global,obj_has_model_extended,obj_set_model_extended,nearest_player_to_object,math_random,djui_hud_set_resolution,djui_hud_set_font,djui_hud_get_screen_width,maxf,djui_hud_set_color,djui_hud_render_rect,djui_hud_measure_text,djui_hud_print_text,min,math_min,math_ceil,math_abs,math_sin,minf,djui_hud_set_rotation,table_insert,djui_hud_print_text_interpolated,math_max,play_sound,play_character_sound,string_lower = mod_storage_load,tonumber,mod_storage_save,djui_popup_create,tostring,djui_chat_message_create,is_game_paused,obj_get_first_with_behavior_id,djui_hud_is_pause_menu_created,camera_freeze,hud_hide,vec3f_copy,set_mario_action,set_character_animation,camera_unfreeze,hud_show,type,get_id_from_behavior,obj_has_behavior_id,network_local_index_from_global,obj_has_model_extended,obj_set_model_extended,nearest_player_to_object,math.random,djui_hud_set_resolution,djui_hud_set_font,djui_hud_get_screen_width,maxf,djui_hud_set_color,djui_hud_render_rect,djui_hud_measure_text,djui_hud_print_text,min,math.min,math.ceil,math.abs,math.sin,minf,djui_hud_set_rotation,table.insert,djui_hud_print_text_interpolated,math.max,play_sound,play_character_sound,string.lower

menu = false
menuAndTransition = false
gridMenu = false
options = false
local credits = false
local creditsAndTransition = false
currChar = 1
local prevChar = 1
currCharRender = 1
currCategory = 1
local currOption = 1
local creditScroll = 0
local prevCreditScroll = creditScroll
local creditScrollRange = 0

local menuCrossFade = 7
local menuCrossFadeCap = menuCrossFade
local menuCrossFadeMath = 255 / menuCrossFade

local creditsCrossFade = 7
local creditsCrossFadeCap = creditsCrossFade
local creditsCrossFadeMath = 255 / creditsCrossFade

local TYPE_FUNCTION = "function"
local TYPE_BOOLEAN = "boolean"
local TYPE_STRING = "string"
local TYPE_INTEGER = "number"
local TYPE_TABLE = "table"

local TEX_HEADER = get_texture_info("char-select-text")
local TEX_WALL_LEFT = get_texture_info("char-select-wall-left")
local TEX_WALL_RIGHT = get_texture_info("char-select-wall-right")
local TEX_GRAFFITI_DEFAULT = get_texture_info("char-select-graffiti-default")
local TEX_BUTTON_SMALL = get_texture_info("char-select-button-small")
local TEX_OVERRIDE_HEADER = nil

local SOUND_CHAR_SELECT_THEME = audio_stream_load("char-select-menu-theme.ogg")
audio_stream_set_looping(SOUND_CHAR_SELECT_THEME, true)
audio_stream_set_loop_points(SOUND_CHAR_SELECT_THEME, 0, 93.659*22050)

---@param texture TextureInfo?
function header_set_texture(texture)
    TEX_OVERRIDE_HEADER = texture
end

CS_ANIM_MENU = CHAR_ANIM_MAX + 1

local TEXT_PREF_LOAD_NAME = "Default"
local TEXT_PREF_LOAD_ALT = 1

--[[
    Note: Do NOT add characters via the characterTable below,
    We highly recommend you create your own mod and use the
    API to add characters, this ensures your pack is easy
    to use for anyone and low on file space!
]]

characterTable = {
    [CT_MARIO] = {
        saveName = "Mario_Default",
        category = "All_CoopDX",
        ogNum = CT_MARIO,
        currAlt = 1,
        hasMoveset = false,
        locked = false,
        [1] = {
            name = "Mario",
            description = "The iconic Italian plumber himself! He's quite confident and brave, always prepared to jump into action to save the Mushroom Kingdom!",
            credit = "Nintendo / Coop Team",
            color = { r = 255, g = 50,  b = 50  },
            model = E_MODEL_MARIO,
            ogModel = E_MODEL_MARIO,
            baseChar = CT_MARIO,
            lifeIcon = gTextures.mario_head,
            starIcon = gTextures.star,
            camScale = 1.0,
        },
    },
    [CT_LUIGI] = {
        saveName = "Luigi_Default",
        category = "All_CoopDX",
        ogNum = CT_LUIGI,
        currAlt = 1,
        hasMoveset = false,
        locked = false,
        [1] = {
            name = "Luigi",
            description = "The other iconic Italian plumber! He's a bit shy and scares easily, but he's willing to follow his brother Mario through any battle that may come their way!",
            credit = "Nintendo / Coop Team",
            color = { r = 50,  g = 255, b = 50  },
            model = E_MODEL_LUIGI,
            ogModel = E_MODEL_LUIGI,
            baseChar = CT_LUIGI,
            lifeIcon = gTextures.luigi_head,
            starIcon = gTextures.star,
            camScale = 1.0,
            healthTexture = {
                label = {
                    left = get_texture_info("char-select-luigi-meter-left"),
                    right = get_texture_info("char-select-luigi-meter-right"),
                }
            }
        },
    },
    [CT_TOAD] = {
        saveName = "Toad_Default",
        category = "All_CoopDX",
        ogNum = CT_TOAD,
        currAlt = 1,
        hasMoveset = false,
        locked = false,
        [1] = {
            name = "Toad",
            description = "Princess Peach's little attendant! He's an energetic little mushroom that's never afraid to follow Mario and Luigi on their adventures!",
            credit = "Nintendo / Coop Team",
            color = { r = 50,  g = 50,  b = 255 },
            model = E_MODEL_TOAD_PLAYER,
            ogModel = E_MODEL_TOAD_PLAYER,
            baseChar = CT_TOAD,
            lifeIcon = gTextures.toad_head,
            starIcon = gTextures.star,
            camScale = 0.8,
            healthTexture = {
                label = {
                    left = get_texture_info("char-select-toad-meter-left"),
                    right = get_texture_info("char-select-toad-meter-right"),
                }
            }
        },
    },
    [CT_WALUIGI] = {
        saveName = "Waluigi_Default",
        category = "All_CoopDX",
        ogNum = CT_WALUIGI,
        currAlt = 1,
        hasMoveset = false,
        locked = false,
        [1] = {
            name = "Waluigi",
            description = "The mischievous rival of Luigi! He's a narcissistic competitor that takes great taste in others getting pummeled from his success!",
            credit = "Nintendo / Coop Team",
            color = { r = 130, g = 25,  b = 130 },
            model = E_MODEL_WALUIGI,
            ogModel = E_MODEL_WALUIGI,
            baseChar = CT_WALUIGI,
            lifeIcon = gTextures.waluigi_head,
            starIcon = gTextures.star,
            camScale = 1.1,
            healthTexture = {
                label = {
                    left = get_texture_info("char-select-waluigi-meter-left"),
                    right = get_texture_info("char-select-waluigi-meter-right"),
                }
            }
        },
    },
    [CT_WARIO] = {
        saveName = "Wario_Default",
        category = "All_CoopDX",
        ogNum = CT_WARIO,
        currAlt = 1,
        hasMoveset = false,
        locked = false,
        [1] = {
            name = "Wario",
            description = "The mischievous rival of Mario! He's a greed-filled treasure hunter obsessed with money and gold coins. He's always ready for a brawl if his money is on the line!",
            credit = "Nintendo / Coop Team",
            color = { r = 255, g = 255, b = 50  },
            model = E_MODEL_WARIO,
            ogModel = E_MODEL_WARIO,
            baseChar = CT_WARIO,
            lifeIcon = gTextures.wario_head,
            starIcon = gTextures.star,
            camScale = 1.0,
            healthTexture = {
                label = {
                    left = get_texture_info("char-select-wario-meter-left"),
                    right = get_texture_info("char-select-wario-meter-right"),
                }
            }
        },
    },
}

function character_is_vanilla(charNum)
    if charNum == nil then charNum = currChar end
    return charNum < CT_MAX
end

characterCategories = {
    "All",
    "CoopDX",
    "Locked",
}

local characterTableRender = {}

local function update_character_render_table()
    local ogNum = currChar
    --currChar = 1
    currCharRender = 1
    local category = characterCategories[currCategory]
    if category == nil then return false end
    characterTableRender = {}
    for i = 0, #characterTable do
        local charCategories = string_split(characterTable[i].category, "_")
        if not characterTable[i].locked then
            for c = 1, #charCategories do
                if category == charCategories[c] then
                    table_insert(characterTableRender, characterTable[i])
                    if ogNum == i then
                        currChar = ogNum
                        currCharRender = #characterTableRender
                    end
                end
            end
        end
    end
    if #characterTableRender > 1 then
        currChar = (characterTableRender[currCharRender] and characterTableRender[currCharRender].ogNum or characterTableRender[1].ogNum)
        return true
    else
        return false
    end
end

function force_set_character(charNum, charAlt)
    if not charAlt then charAlt = 1 end
    currCategory = 1
    currChar = charNum
    characterTable[currChar].currAlt = charAlt
    currCharRender = charNum
    charBeingSet = true
    update_character_render_table()
end

characterCaps = {}
characterCelebrationStar = {}
characterColorPresets = {}
characterAnims = {
    [E_MODEL_MARIO] = {
        [CS_ANIM_MENU] = MARIO_ANIM_CS_MENU
    },
    [E_MODEL_LUIGI] = {
        [CS_ANIM_MENU] = LUIGI_ANIM_CS_MENU
    },
    [E_MODEL_TOAD_PLAYER] = {
        [CS_ANIM_MENU] = TOAD_PLAYER_ANIM_CS_MENU
    },
    [E_MODEL_WALUIGI] = {
        [CS_ANIM_MENU] = WALUIGI_ANIM_CS_MENU
    },
    [E_MODEL_WARIO] = {
        [CS_ANIM_MENU] = WARIO_ANIM_CS_MENU
    },
}
characterMovesets = {[1] = {}}
characterUnlock = {}
characterInstrumentals = {}

tableRefNum = 0
local function make_table_ref_num()
    tableRefNum = tableRefNum + 1
    return tableRefNum
end

optionTableRef = {
    -- Menu
    openInputs = make_table_ref_num(),
    notification = make_table_ref_num(),
    menuColor = make_table_ref_num(),
    anims = make_table_ref_num(),
    inputLatency = make_table_ref_num(),
    -- Characters
    localMoveset = make_table_ref_num(),
    localModels = make_table_ref_num(),
    localVoices = make_table_ref_num(),
    -- CS
    credits = make_table_ref_num(),
    debugInfo = make_table_ref_num(),
    resetSaveData = make_table_ref_num(),
    -- Moderation
    --restrictPalettes = make_table_ref_num(),
    restrictMovesets = make_table_ref_num(),
}

optionTable = {
    [optionTableRef.openInputs] = {
        name = "Menu Bind",
        toggle = tonumber(mod_storage_load("MenuInput")),
        toggleSaveName = "MenuInput",
        toggleDefault = 1,
        toggleMax = 2,
        toggleNames = {"None", "Z (Pause Menu)", ommActive and "D-pad Down + R" or "D-pad Down"},
        description = {"Sets a Bind to Open the Menu", "rather than using the command."}
    },
    [optionTableRef.notification] = {
        name = "Notifications",
        toggle = tonumber(mod_storage_load("notifs")),
        toggleSaveName = "notifs",
        toggleDefault = 1,
        toggleMax = 2,
        toggleNames = {"Off", "On", "Pop-ups Only"},
        description = {"Toggles whether Pop-ups and", "Chat Messages display"}
    },
    [optionTableRef.menuColor] = {
        name = "Menu Color",
        toggle = tonumber(mod_storage_load("MenuColor")),
        toggleSaveName = "MenuColor",
        toggleDefault = 0,
        toggleMax = 10,
        toggleNames = {"Auto", "Saved", "Red", "Orange", "Yellow", "Green", "Blue", "Pink", "Purple", "White", "Black"},
        description = {"Toggles the Menu Color"}
    },
    [optionTableRef.anims] = {
        name = "Menu Anims",
        toggle = tonumber(mod_storage_load("Anims")),
        toggleSaveName = "Anims",
        toggleDefault = 1,
        toggleMax = 1,
        toggleNames = {"Off", "On"},
        description = {"Toggles Animations In-Menu,", "Turning these off may", "Save Performance"}
    },
    [optionTableRef.inputLatency] = {
        name = "Scroll Speed",
        toggle = tonumber(mod_storage_load("Latency")),
        toggleSaveName = "Latency",
        toggleDefault = 1,
        toggleMax = 2,
        toggleNames = {"Slow", "Normal", "Fast"},
        description = {"Sets how fast you scroll", "throughout the Menu"}
    },
    [optionTableRef.localMoveset] = {
        name = "Character Moveset",
        toggle = tonumber(mod_storage_load("localMoveset")),
        toggleSaveName = "localMoveset",
        toggleDefault = 1,
        toggleMax = 1,
        description = {"Toggles if Custom Movesets", "are active on compatible", "characters"},
        lock = function ()
            if gGlobalSyncTable.charSelectRestrictMovesets ~= 0 then
                return "Forced Off"
            end
        end,
    },
    [optionTableRef.localModels] = {
        name = "Character Models",
        toggle = tonumber(mod_storage_load("localModels")),
        toggleSaveName = "localModels",
        toggleDefault = 1,
        toggleMax = 1,
        description = {"Toggles if Custom Models display", "on your client, practically", "disables Character Select if", "Toggled Off"}
    },
    [optionTableRef.localVoices] = {
        name = "Character Voices",
        toggle = tonumber(mod_storage_load("localVoices")),
        toggleSaveName = "localVoices",
        toggleDefault = 1,
        toggleMax = 1,
        description = {"Toggle if Custom Voicelines play", "for Characters who support it"}
    },
    [optionTableRef.credits] = {
        name = "Credits",
        toggle = 0,
        toggleDefault = 0,
        toggleMax = 1,
        toggleNames = {"", ""},
        description = {"Thank you for choosing", "Character Select!"}
    },
    [optionTableRef.debugInfo] = {
        name = "Developer Mode",
        toggle = tonumber(mod_storage_load("debuginfo")),
        toggleSaveName = "debuginfo",
        toggleDefault = 0,
        toggleMax = 1,
        description = {"Replaces the Character", "Description with Character", "Debugging Information,", "And shows hidden console logs."}
    },
    [optionTableRef.resetSaveData] = {
        name = "Reset Save Data",
        toggle = 0,
        toggleDefault = 0,
        toggleMax = 1,
        toggleNames = {"", ""},
        description = {"Resets Character Select's", "Save Data"}
    },
    [optionTableRef.restrictMovesets] = {
        name = "Restrict Movesets",
        toggle = 0,
        toggleDefault = 1,
        toggleMax = 1,
        description = {"Restricts turning on", "movesets", "(Host Only)"},
        lock = function ()
            if gGlobalSyncTable.charSelectRestrictMovesets < 2 then
                if not network_is_server() then
                    return "Host Only"
                end
            else
                return "API Only"
            end
        end,
    },
}

---@description A function that gets an option's status from the Character Select Options Menu
---@param tableNum integer The table position of the option
---@return number?
function get_options_status(tableNum)
    if type(tableNum) ~= TYPE_INTEGER then return nil end
    return optionTable[tableNum].toggle
end

function dev_mode_log_to_console(message, level)
    if get_options_status(optionTableRef.debugInfo) == 0 then return end
    log_to_console(message, level and level or CONSOLE_MESSAGE_WARNING)
end

creditTable = {
    {
        packName = "Character Select Coop",
        {creditTo = "Squishy6094",     creditFor = "Creator"},
        {creditTo = "Sprsn64",         creditFor = "Logo Design"},
        {creditTo = "JerThePear",      creditFor = "Menu Poses"},
        {creditTo = "Trashcam",        creditFor = "Menu Music"},
        {creditTo = "AngelicMiracles", creditFor = "Concepts / CoopDX"},
        {creditTo = "AgentX",          creditFor = "Contributer / CoopDX"},
        {creditTo = "xLuigiGamerx",    creditFor = "Contributer"},
        {creditTo = "Wibblus",         creditFor = "Contributer"},
        {creditTo = "SuperKirbyLover", creditFor = "Contributer"},
    }
}

local defaultOptionCount = #optionTable

local latencyValueTable = {12, 6, 3}

local menuColorTable = {
    { r = 255, g = 50,  b = 50  },
    { r = 255, g = 100, b = 50  },
    { r = 255, g = 255, b = 50  },
    { r = 50,  g = 255, b = 50  },
    { r = 50,  g = 50,  b = 255 },
    { r = 251, g = 148, b = 220 },
    { r = 130, g = 25,  b = 130 },
    { r = 255, g = 255, b = 255 },
    { r = 50,  g = 50,  b = 50  }
}

---@param m MarioState
local function nullify_inputs(m)
    local c = m.controller
    _G.charSelect.controller = {
        buttonDown = c.buttonDown,
        buttonPressed = c.buttonPressed & ~_G.charSelect.controller.buttonDown,
        extStickX = c.extStickX,
        extStickY = c.extStickY,
        rawStickX = c.rawStickX,
        rawStickY = c.rawStickY,
        stickMag = c.stickMag,
        stickX = c.stickX,
        stickY = c.stickY
    }
    c.buttonDown = 0
    c.buttonPressed = 0
    c.extStickX = 0
    c.extStickY = 0
    c.rawStickX = 0
    c.rawStickY = 0
    c.stickMag = 0
    c.stickX = 0
    c.stickY = 0
end

local prefCharColor = {r = 255, g = 50, b = 50}

local function load_preferred_char()
    local savedChar = mod_storage_load("PrefChar")
    local savedAlt = tonumber(mod_storage_load("PrefAlt"))
    local savedPalette = tonumber(mod_storage_load("PrefPalette"))
    if savedChar == nil or savedChar == "" then
        mod_storage_save("PrefChar", "Default")
        savedChar = "Default"
    end
    if savedAlt == nil then
        mod_storage_save("PrefAlt", "1")
        savedAlt = 1
    end
    if savedPalette == nil then
        local paletteSave = 1
        mod_storage_save("PrefAlt", tostring(paletteSave))
        savedPalette = paletteSave
    end
    if optionTable[optionTableRef.localModels].toggle == 1 then
        for i = CT_MAX, #characterTable do
            local char = characterTable[i]
            if char.saveName == savedChar and not char.locked then
                currChar = i
                currCharRender = i
                if savedAlt > 0 and savedAlt <= #char then
                    char.currAlt = savedAlt
                end
                savedAlt = math.clamp(savedAlt, 1, #characterTable[currChar])
                local model = characterTable[currChar][savedAlt].model
                if characterColorPresets[model] ~= nil then
                    gCSPlayers[0].presetPalette = savedPalette
                    characterColorPresets[model].currPalette = savedPalette
                end
                if optionTable[optionTableRef.notification].toggle > 0 then
                    djui_popup_create('Character Select:\nYour Preferred Character\n"' .. string_underscore_to_space(char[char.currAlt].name) .. '"\nwas applied successfully!', 4)
                end
                break
            end
        end
    end
    if savedChar == "Default" then
        currChar = gNetworkPlayers[0].modelIndex
        local model = characterTable[currChar][1].model
        gCSPlayers[0].presetPalette = savedPalette
        characterColorPresets[model].currPalette = savedPalette
    end

    local savedCharColors = mod_storage_load("PrefCharColor")
    if savedCharColors ~= nil and savedCharColors ~= "" then
        local savedCharColorsTable = string_split(savedCharColors, "_")
        prefCharColor = {
            r = tonumber(savedCharColorsTable[1]),
            g = tonumber(savedCharColorsTable[2]),
            b = tonumber(savedCharColorsTable[3])
        }
    else
        mod_storage_save("PrefCharColor", "255_50_50")
    end

    if #characterTable < CT_MAX then
        if optionTable[optionTableRef.notification].toggle > 0 then
            djui_popup_create("Character Select:\nNo Characters were Found", 2)
        end
    end
    TEXT_PREF_LOAD_NAME = savedChar
    TEXT_PREF_LOAD_ALT = savedAlt
    update_character_render_table()
end

local function mod_storage_save_pref_char(charTable)
    if character_is_vanilla(charTable.ogNum) then
        mod_storage_save("PrefChar", "Default")
    else
        mod_storage_save("PrefChar", charTable.saveName)
    end
    mod_storage_save("PrefAlt", tostring(charTable.currAlt))
    mod_storage_save("PrefPalette", tostring(gCSPlayers[0].presetPalette))
    mod_storage_save("PrefCharColor", tostring(charTable[charTable.currAlt].color.r) .. "_" .. tostring(charTable[charTable.currAlt].color.g) .. "_" .. tostring(charTable[charTable.currAlt].color.b))
    TEXT_PREF_LOAD_NAME = charTable.saveName
    TEXT_PREF_LOAD_ALT = charTable.currAlt
    prefCharColor = charTable[charTable.currAlt].color
end

function failsafe_options()
    for i = 1, #optionTable do
        if optionTable[i].toggle == nil or optionTable[i].toggle == "" then
            local load = optionTable[i].toggleSaveName and mod_storage_load(optionTable[i].toggleSaveName) or nil
            if load == "" then
                load = nil
            end
            optionTable[i].toggle = load and tonumber(load) or optionTable[i].toggleDefault
        end
        if optionTable[i].toggleNames == nil then
            optionTable[i].toggleNames = {"Off", "On"}
        end
    end
    if optionTable[optionTableRef.openInputs].toggle == 2 and ommActive then
        djui_popup_create('Character Select:\nYour Open bind has changed to:\nD-pad Down + R\nDue to OMM Rebirth being active!', 4)
    end
end

local promptedAreYouSure = false

local function reset_options(wasChatTriggered)
    if not promptedAreYouSure then
        djui_chat_message_create("\\#ffdcdc\\Are you sure you want to reset your Save Data for Character Select, including your Preferred Character\nand Settings?\n" .. (wasChatTriggered and "Type \\#ff3333\\/char-select reset\\#ffdcdc\\ to confirm." or "Press the \\#ff3333\\" .. optionTable[optionTableRef.resetSaveData].name .. "\\#ffdcdc\\ Option again to confirm." ))
        promptedAreYouSure = true
    else
        djui_chat_message_create("\\#ff3333\\Character Select Save Data Reset!")
        djui_chat_message_create("Note: If your issue has not been resolved, you may need to manually delete your save data via the directory below:\n\\#dcdcFF\\%appdata%/sm64coopdx/sav/character-select-coop.sav")
        for i = 1, #optionTable do
            optionTable[i].toggle = optionTable[i].toggleDefault
            if optionTable[i].toggleSaveName ~= nil then
                mod_storage_save(optionTable[i].toggleSaveName, tostring(optionTable[i].toggle))
            end
            if optionTable[i].toggleNames == nil then
                optionTable[i].toggleNames = { "Off", "On" }
            end
        end
        currChar = 1
        for i = 0, #characterTable do
            characterTable[i].currAlt = 1
        end
        mod_storage_save_pref_char(characterTable[1])
        promptedAreYouSure = false
    end
end

local function boot_note()
    if #characterTable >= CT_MAX then
        djui_chat_message_create("Character Select has " .. (#characterTable - 1) .. " character" .. (#characterTable > 2 and "s" or "") .." available!\nYou can use \\#ffff33\\/char-select \\#ffffff\\to open the menu!")
        if #characterTable > 32 and network_is_server() then
            djui_chat_message_create("\\#FFAAAA\\Warning: Having more than 32 Characters\nmay be unstable, For a better experience please\ndisable a few packs!")
        end
    else
        djui_chat_message_create("Character Select is active!\nYou can use \\#ffff33\\/char-select \\#ffffff\\to open the menu!")
    end
end

local function menu_is_allowed(m)
    if m == nil then m = gMarioStates[0] end
    -- API Check
    for _, func in pairs(allowMenu) do
        if not func() then
            return false
        end
    end

    -- C-up Failsafe (Camera Softlocks)
    if m.action == ACT_FIRST_PERSON or (m.prevAction == ACT_FIRST_PERSON and is_game_paused()) then
        return false
    elseif m.prevAction == ACT_FIRST_PERSON and not is_game_paused() then
        m.prevAction = ACT_WALKING
    end

    -- Cutscene Check
    if gNetworkPlayers[0].currActNum == 99 then return false end
    if m.action == ACT_INTRO_CUTSCENE then return false end
    if obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then return false end

    return true
end

hookTableOnCharacterChange = {
    [1] = function (prevChar, currChar)
        -- Check for Non-Vanilla Actions when switching Characters
        local m = gMarioStates[0]
        if is_mario_in_vanilla_action(m) or m.health < 256 then return end
        if m.action & ACT_FLAG_RIDING_SHELL ~= 0 then
            set_mario_action(m, ACT_RIDING_SHELL_FALL, 0)
        elseif m.action & ACT_FLAG_ALLOW_FIRST_PERSON ~= 0 then
            set_mario_action(m, ACT_IDLE, 0)
        elseif m.action & ACT_GROUP_MOVING ~= 0 or m.action & ACT_FLAG_MOVING ~= 0 then
            set_mario_action(m, ACT_WALKING, 0)
        elseif m.action & ACT_GROUP_SUBMERGED ~= 0 or m.action & ACT_FLAG_SWIMMING ~= 0 then
            -- Need to fix upwarping
            set_mario_action(m, ACT_WATER_IDLE, 0)
        else
            set_mario_action(m, ACT_FREEFALL, 0)
        end
    end
}

local function on_character_change(prevChar, currChar)
    for i = 1, #hookTableOnCharacterChange do
        hookTableOnCharacterChange[i](prevChar, currChar)
    end
end

-------------------
-- Model Handler --
-------------------

local stallFrame = 0
local stallComplete = 3

CUTSCENE_CS_MENU = 0xFA

local MATH_PI = math.pi

local prevBaseCharFrame = gNetworkPlayers[0].modelIndex
local camAngle = 0
local eyeState = MARIO_EYES_OPEN
local worldColor = {
    lighting = {r = 255, g = 255, b = 255},
    skybox = {r = 255, g = 255, b = 255},
    fog = {r = 255, g = 255, b = 255},
    vertex = {r = 255, g = 255, b = 255},
}
---@param m MarioState
local function mario_update(m)
    local np = gNetworkPlayers[m.playerIndex]
    local p = gCSPlayers[m.playerIndex]
    if stallFrame == 1 or queueStorageFailsafe then
        failsafe_options()
        if not queueStorageFailsafe then
            load_preferred_char()
            if optionTable[optionTableRef.notification].toggle == 1 then
                boot_note()
            end
        end
        queueStorageFailsafe = false
    end

    if network_is_server() and gGlobalSyncTable.charSelectRestrictMovesets < 2 then
        gGlobalSyncTable.charSelectRestrictMovesets = optionTable[optionTableRef.restrictMovesets].toggle
    end

    if stallFrame < stallComplete then
        stallFrame = stallFrame + 1
    end

    if m.playerIndex == 0 and stallFrame > 1 then
        if djui_hud_is_pause_menu_created() and prevBaseCharFrame ~= np.modelIndex then
            currChar = np.modelIndex
            p.presetPalette = 0
        end
        prevBaseCharFrame = np.modelIndex

        if optionTable[optionTableRef.localModels].toggle == 0 then
            currCategory = 1
            currChar = 1
            currCharRender = 1
        end

        local charTable = characterTable[currChar]
        p.saveName = charTable.saveName
        p.currAlt = charTable.currAlt
    
        p.modelId = charTable[charTable.currAlt].model
        if charTable[charTable.currAlt].baseChar ~= nil then
            p.baseChar = charTable[charTable.currAlt].baseChar
        end
        p.modelEditOffset = charTable[charTable.currAlt].model - charTable[charTable.currAlt].ogModel
        m.marioObj.hookRender = 1

        if menu and m.action == ACT_SLEEPING then
            set_mario_action(m, ACT_WAKING_UP, m.actionArg)
        end

        if menuAndTransition then
            audio_stream_play(SOUND_CHAR_SELECT_THEME, false, 1)
            for i = 0, #characterTable do
                if characterInstrumentals[i] ~= nil then
                    audio_stream_play(characterInstrumentals[i], false, 1)
                    audio_stream_set_volume(characterInstrumentals[i], i == currChar and 1 or 0)
                end
            end
            play_secondary_music(0, 0, 0, 50)
            camera_freeze()
            hud_hide()
            if m.area.camera.cutscene == 0 then
                m.area.camera.cutscene = CUTSCENE_CS_MENU
            end
            local camScale = charTable[charTable.currAlt].camScale
            djui_hud_set_resolution(RESOLUTION_N64)
            local widthScale = djui_hud_get_screen_width()/320
            local focusPos = {
                x = m.pos.x + sins(camAngle - 0x4000)*175*camScale*widthScale,
                y = m.pos.y + 120 * camScale,
                z = m.pos.z + coss(camAngle - 0x4000)*175*camScale*widthScale,
            }
            vec3f_copy(gLakituState.focus, focusPos)
            m.marioBodyState.eyeState = eyeState
            gLakituState.pos.x = m.pos.x + sins(camAngle) * 450 * camScale
            gLakituState.pos.y = m.pos.y + 10
            gLakituState.pos.z = m.pos.z + coss(camAngle) * 450 * camScale
            p.inMenu = true

            set_lighting_color(0, (menuColor.r*0.33 + 255*0.66) * worldColor.lighting.r/255)
            set_lighting_color(1, (menuColor.g*0.33 + 255*0.66) * worldColor.lighting.r/255)
            set_lighting_color(2, (menuColor.b*0.33 + 255*0.66) * worldColor.lighting.r/255)
            set_skybox_color(0, menuColor.r * worldColor.lighting.r/255)
            set_skybox_color(1, menuColor.g * worldColor.lighting.r/255)
            set_skybox_color(2, menuColor.b * worldColor.lighting.r/255)
            set_fog_color(0, menuColor.r * worldColor.lighting.r/255)
            set_fog_color(1, menuColor.g * worldColor.lighting.r/255)
            set_fog_color(2, menuColor.b * worldColor.lighting.r/255)
            set_vertex_color(0, menuColor.r * worldColor.lighting.r/255)
            set_vertex_color(1, menuColor.g * worldColor.lighting.r/255)
            set_vertex_color(2, menuColor.b * worldColor.lighting.r/255)
        else
            if p.inMenu then
                audio_stream_pause(SOUND_CHAR_SELECT_THEME)
                for i = 0, #characterTable do
                    if characterInstrumentals[i] ~= nil then
                        audio_stream_pause(characterInstrumentals[i])
                    end
                end
                stop_secondary_music(50)
                camera_unfreeze()
                hud_show()
                if m.area.camera.cutscene == CUTSCENE_CS_MENU then
                    m.area.camera.cutscene = CUTSCENE_STOP
                end
                set_lighting_color(0, worldColor.lighting.r)
                set_lighting_color(1, worldColor.lighting.g)
                set_lighting_color(2, worldColor.lighting.b)
                set_skybox_color(0, worldColor.skybox.r)
                set_skybox_color(1, worldColor.skybox.g)
                set_skybox_color(2, worldColor.skybox.b)
                set_fog_color(0, worldColor.fog.r)
                set_fog_color(1, worldColor.fog.g)
                set_fog_color(2, worldColor.fog.b)
                set_vertex_color(0, worldColor.vertex.r)
                set_vertex_color(1, worldColor.vertex.g)
                set_vertex_color(2, worldColor.vertex.b)
                p.inMenu = false
            end

            worldColor.lighting.r = get_lighting_color(0)
            worldColor.lighting.g = get_lighting_color(1)
            worldColor.lighting.b = get_lighting_color(2)
            worldColor.skybox.r = get_skybox_color(0)
            worldColor.skybox.g = get_skybox_color(1)
            worldColor.skybox.b = get_skybox_color(2)
            worldColor.fog.r = get_fog_color(0)
            worldColor.fog.g = get_fog_color(1)
            worldColor.fog.b = get_fog_color(2)
            worldColor.vertex.r = get_vertex_color(0)
            worldColor.vertex.g = get_vertex_color(1)
            worldColor.vertex.b = get_vertex_color(2)
        end

        -- Check for Locked Chars
        for i = CT_MAX, #characterTable do
            local char = characterTable[i]
            if char.locked then
                local unlock = characterUnlock[i].check
                local notif = characterUnlock[i].notif
                if type(unlock) == TYPE_FUNCTION then
                    if unlock() then
                        char.locked = false
                    end
                elseif type(unlock) == TYPE_BOOLEAN then
                    char.locked = unlock
                end
                if not char.locked then -- Character was unlocked
                    update_character_render_table()
                    if stallFrame == stallComplete and notif then
                        if optionTable[optionTableRef.notification].toggle > 0 then
                            djui_popup_create('Character Select:\nUnlocked '..tostring(char[1].name)..'\nas a Playable Character!', 3)
                        end
                    end
                end
            end
        end

        --Open Credits
        if optionTable[optionTableRef.credits].toggle > 0 then
            credits = true
            optionTable[optionTableRef.credits].toggle = 0
        end

        --Reset Save Data Check
        if optionTable[optionTableRef.resetSaveData].toggle > 0 then
            reset_options(false)
            optionTable[optionTableRef.resetSaveData].toggle = 0
        end
        charBeingSet = false
        for i = 1, #optionTable do
            optionTable[i].optionBeingSet = false
        end

        p.movesetToggle = optionTable[optionTableRef.localMoveset].toggle ~= 0
        if prevChar ~= currChar then
            on_character_change(prevChar, currChar)
            prevChar = currChar
        end
    end

    if p.inMenu and m.action & ACT_FLAG_ALLOW_FIRST_PERSON ~= 0 then
        m.action = ACT_IDLE
        m.actionArg = 0
        m.actionState = 0xFFFF

        -- reset menu anim on character change, starts them at frame 0 and prevents lua anim issues
        if p.prevModelId ~= p.modelId then
            p.prevModelId = p.modelId
            m.marioObj.header.gfx.animInfo.animID = -1
        end
        set_character_animation(m, (characterAnims[p.modelId] and characterAnims[p.modelId][CS_ANIM_MENU]) and CS_ANIM_MENU or CHAR_ANIM_FIRST_PERSON)

        m.marioObj.header.gfx.angle.y = m.faceAngle.y
    elseif m.actionState == 0xFFFF and m.action == ACT_IDLE then
        -- snap back to normal idle when out of the menu
        m.actionState = 0
    end

    np.overrideModelIndex = p.baseChar ~= nil and p.baseChar or CT_MARIO

    -- Character Animations
    if characterAnims[p.modelId] then
        local animID = characterAnims[p.modelId][m.marioObj.header.gfx.animInfo.animID]
        if animID then
            smlua_anim_util_set_animation(m.marioObj, animID)
        end
    end
end

local sCapBhvs = {
    [id_bhvWingCap] = true,
    [id_bhvVanishCap] = true,
    [id_bhvMetalCap] = true
}

---@param o Object
---@param model integer
local BowserKey = false
local function on_star_or_key_grab(m, o, type)
    if type == INTERACT_STAR_OR_KEY then
        if get_id_from_behavior(o.behavior) == id_bhvBowserKey then
            BowserKey = true
        else
            BowserKey = false
        end
    end
end

function set_model(o, model)
    if optionTable[optionTableRef.localModels].toggle == 0 then return end

    -- Player Models
    if obj_has_behavior_id(o, id_bhvMario) ~= 0 then
        local i = network_local_index_from_global(o.globalPlayerIndex)
        local prevModelData = obj_get_model_id_extended(o)
        local localModelData = nil
        for c = 0, #characterTable do
            if gCSPlayers[i].saveName == characterTable[c].saveName then
                if gCSPlayers[i].currAlt <= #characterTable[c] then
                    localModelData = characterTable[c][gCSPlayers[i].currAlt].ogModel + gCSPlayers[i].modelEditOffset
                    break
                end
            end
        end
        if localModelData ~= nil then
            if obj_has_model_extended(o, localModelData) == 0 then
                obj_set_model_extended(o, localModelData)
            end
        else
            -- Original/Backup
            if gCSPlayers[i].modelId ~= nil and obj_has_model_extended(o, gCSPlayers[i].modelId) == 0 then
                obj_set_model_extended(o, gCSPlayers[i].modelId)
            end
        end
        return
    end

    -- Star Models
    if obj_has_behavior_id(o, id_bhvCelebrationStar) ~= 0 and o.parentObj ~= nil then
        local i = network_local_index_from_global(o.parentObj.globalPlayerIndex)
        local starModel = characterCelebrationStar[gCSPlayers[i].modelId]
        if gCSPlayers[i].modelId ~= nil and starModel ~= nil and obj_has_model_extended(o, starModel) == 0 and not BowserKey then
            obj_set_model_extended(o, starModel)
        end
        return
    end

    if sCapBhvs[get_id_from_behavior(o.behavior)] then
        local playerToObj = nearest_player_to_object(o.parentObj)
        o.globalPlayerIndex = playerToObj and playerToObj.globalPlayerIndex or 0
    end
    local i = network_local_index_from_global(o.globalPlayerIndex)

    local c = gMarioStates[i].character
    if model == c.capModelId or
       model == c.capWingModelId or
       model == c.capMetalModelId or
       model == c.capMetalWingModelId then
        local capModels = characterCaps[gCSPlayers[i].modelId]
        if capModels ~= nil then
            local capModel = E_MODEL_NONE
            if model == c.capModelId then
                capModel = capModels.normal
            elseif model == c.capWingModelId then
                capModel = capModels.wing
            elseif model == c.capMetalModelId then
                capModel = capModels.metal
            elseif model == c.capMetalWingModelId then
                capModel = capModels.metalWing
            end
            if capModel ~= E_MODEL_NONE and capModel ~= E_MODEL_ERROR_MODEL and capModel ~= nil then
                obj_set_model_extended(o, capModel)
            end
        end
    end
end

--hook_event(HOOK_MARIO_UPDATE, mario_update)
cs_hook_mario_update(mario_update)
hook_event(HOOK_ON_INTERACT, on_star_or_key_grab)
hook_event(HOOK_OBJECT_SET_MODEL, set_model)

------------------
-- Menu Handler --
------------------

local TEX_CAUTION_TAPE = get_texture_info("char-select-caution-tape")
-- Renders caution tape from xy1 to xy2, tape extends based on dist (0 - 1)
local function djui_hud_render_caution_tape(x1, y1, x2, y2, dist, scale)
    if not scale then scale = 0.5 end
    local totalDist = math.sqrt((y2 - y1)^2 + (x2 - x1)^2) * dist
    local angle = angle_from_2d_points(x1, y1, x2, y2)
    djui_hud_set_rotation(angle, 0, 0.5)
    local texWidth = TEX_CAUTION_TAPE.width*scale
    local texHeight = TEX_CAUTION_TAPE.height*scale
    local tapeSegments = totalDist/texWidth
    local tapeRemainder = tapeSegments
    while tapeRemainder > 1 do
        tapeRemainder = tapeRemainder - 1
    end
    for i = 0, math.floor(tapeSegments) do
        local remainder = i == math.floor(tapeSegments) and tapeRemainder or 1
        djui_hud_render_texture_tile(TEX_CAUTION_TAPE,
        x1 + texWidth*coss(angle)*i,
        y1 - texWidth*sins(angle)*i,
        TEX_CAUTION_TAPE.height/TEX_CAUTION_TAPE.width*scale, 1*scale, 0, 0, TEX_CAUTION_TAPE.width*remainder, TEX_CAUTION_TAPE.height)
    end
    djui_hud_set_rotation(0, 0, 0)
end

local buttonAnimTimer = 0
local buttonScroll = 0
local buttonScrollCap = 30

local optionAnimTimer = -200
local optionAnimTimerCap = optionAnimTimer

local inputStallTimerButton = 0
local inputStallTimerDirectional = 0
local inputStallToDirectional = 12
local inputStallToButton = 10

--Basic Menu Text
local TEXT_OPTIONS_HEADER = "Menu Options"
local TEXT_OPTIONS_HEADER_API = "API Options"
local yearsOfCS = get_date_and_time().year - 123 -- Zero years as of 2023
local TEXT_VERSION = "Version: " .. MOD_VERSION_STRING .. " | sm64coopdx" .. (seasonalEvent == SEASON_EVENT_BIRTHDAY and (" | " .. tostring(yearsOfCS) .. " year" .. (yearsOfCS > 1 and "s" or "") .. " of Character Select!") or "")
local TEXT_RATIO_UNSUPPORTED = "Your Current Aspect-Ratio isn't Supported!"
local TEXT_DESCRIPTION = "Character Description:"
local TEXT_PREF_SAVE = "Preferred Char (A)"
local TEXT_PREF_PALETTE = "Toggle Palette (Y)"
local TEXT_MOVESET_INFO = "Moveset Info (Z)"
local TEXT_PAUSE_Z_OPEN = "Z Button - Character Select"
local TEXT_PAUSE_UNAVAILABLE = "Character Select is Unavailable"
local TEXT_PAUSE_CURR_CHAR = "Current Character: "
local TEXT_MOVESET_RESTRICTED = "Movesets are Restricted"
local TEXT_PALETTE_RESTRICTED = "Palettes are Restricted"
local TEXT_MOVESET_AND_PALETTE_RESTRICTED = "Moveset and Palettes are Restricted"
local TEXT_CHAR_LOCKED = "Locked"
-- Easter Egg if you get lucky loading the mod
-- Referencing the original sm64ex DynOS options by PeachyPeach >v<
if math_random(100) == 64 then
    TEXT_PAUSE_Z_OPEN = "Z - DynOS"
    TEXT_PAUSE_CURR_CHAR = "Model: "
end

--Debug Text
local TEXT_DEBUGGING = "Character Debug"
local TEXT_DESCRIPTION_SHORT = "Description:"
local TEXT_LIFE_ICON = "Life Icon:"
local TEXT_STAR_ICON = "Star Icon:"
local TEXT_FORCED_CHAR = "Base: "
local TEXT_TABLE_POS = "Table Position: "
local TEXT_PALETTE = "Palette: "
local baseCharStrings = {
    [CT_MARIO] = "CT_MARIO",
    [CT_LUIGI] = "CT_LUIGI",
    [CT_TOAD] = "CT_TOAD",
    [CT_WALUIGI] = "CT_WALUIGI",
    [CT_WARIO] = "CT_WARIO"
}

--Options Text
local TEXT_OPTIONS_OPEN = "Press START to open Options"
local TEXT_MENU_CLOSE = "Press B to Exit Menu"
local TEXT_OPTIONS_SELECT = "A - Select | B - Exit  "
local TEXT_LOCAL_MODEL_OFF = "Locally Display Models is Off"
local TEXT_LOCAL_MODEL_OFF_OPTIONS = "You can turn it back on in the Options Menu"
local TEXT_LOCAL_MODEL_ERROR = "Failed to find a Character Model"
local TEXT_LOCAL_MODEL_ERROR_FIX = "Please Verify the Integrity of the Pack!"

--Credit Text
local TEXT_CREDITS_HEADER = "Credits"

local MATH_DIVIDE_320 = 1/320
local MATH_DIVIDE_64 = 1/64
local MATH_DIVIDE_32 = 1/32
local MATH_DIVIDE_30 = 1/30
local MATH_DIVIDE_16 = 1/16

local targetMenuColor = {r = 0 , g = 0, b = 0}
menuColor = targetMenuColor
local menuColorHalf = menuColor
local transSpeed = 0.1
local prevBindText = ""
local bindText = 1
local bindTextTimerLoop = 150
local bindTextTimer = 0
local bindTextOpacity = -255
function update_menu_color()
    if optionTable[optionTableRef.menuColor].toggle == nil then return end
    if optionTable[optionTableRef.localModels].toggle == 1 then
        if optionTable[optionTableRef.menuColor].toggle > 1 then
            targetMenuColor = menuColorTable[optionTable[optionTableRef.menuColor].toggle - 1]
        elseif optionTable[optionTableRef.menuColor].toggle == 1 then
            optionTable[optionTableRef.menuColor].toggleNames[2] = string_underscore_to_space(TEXT_PREF_LOAD_NAME) .. ((TEXT_PREF_LOAD_ALT ~= 1 and currChar ~= 1) and " ("..TEXT_PREF_LOAD_ALT..")" or "") .. " (Pref)"
            targetMenuColor = prefCharColor
        elseif characterTable[currChar] ~= nil then
            local char = characterTable[currChar]
            targetMenuColor = char[char.currAlt].color
        end
    else
        targetMenuColor = menuColorTable[9]
    end
    if optionTable[optionTableRef.anims].toggle > 0 then
        menuColor.r = math.lerp(menuColor.r, targetMenuColor.r, transSpeed)
        menuColor.g = math.lerp(menuColor.g, targetMenuColor.g, transSpeed)
        menuColor.b = math.lerp(menuColor.b, targetMenuColor.b, transSpeed)
    else
        menuColor.r = targetMenuColor.r
        menuColor.g = targetMenuColor.g
        menuColor.b = targetMenuColor.b
    end
    menuColorHalf = {
        r = menuColor.r * 0.5 + 127,
        g = menuColor.g * 0.5 + 127,
        b = menuColor.b * 0.5 + 127
    }
    return menuColor
end

local TEX_TRIANGLE = get_texture_info("char-select-triangle")
local function djui_hud_render_triangle(x, y, width, height)
    djui_hud_render_texture(TEX_TRIANGLE, x, y, width*MATH_DIVIDE_64, height*MATH_DIVIDE_32)
end

local buttonAltAnim = 0
local menuOpacity = 245
local gridButtonsPerRow = 5
local gridYOffset = 0
local menuText = {}
local function on_hud_render()
    local FONT_USER = djui_menu_get_font()
    djui_hud_set_font(FONT_ALIASED)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local djuiWidth = djui_hud_get_screen_width()
    local djuiHeight = djui_hud_get_screen_height()
    djui_hud_set_resolution(RESOLUTION_N64)
    local width = djuiWidth * (240/djuiHeight) -- Get accurate, unrounded width
    local height = 240
    local widthHalf = width * 0.5
    local heightHalf = height * 0.5
    local widthScale = maxf(width, 320) * MATH_DIVIDE_320

    if stallFrame == stallComplete then
        update_menu_color()
        if not menu_is_allowed() then
            menu = false
        end
    end

    if menuAndTransition then

        if optionTable[optionTableRef.localModels].toggle == 0 then
            djui_hud_set_color(0, 0, 0, 200)
            djui_hud_render_rect(0, 0, width, height)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text(TEXT_LOCAL_MODEL_OFF, widthHalf - djui_hud_measure_text(TEXT_LOCAL_MODEL_OFF) * 0.15 * widthScale, heightHalf, 0.3 * widthScale)
            djui_hud_print_text(TEXT_LOCAL_MODEL_OFF_OPTIONS, widthHalf - djui_hud_measure_text(TEXT_LOCAL_MODEL_OFF_OPTIONS) * 0.1 * widthScale, heightHalf + 10 * widthScale, 0.2 * widthScale)
        end

        if characterTable[currChar][characterTable[currChar].currAlt].model == E_MODEL_ARMATURE then
            djui_hud_set_color(0, 0, 0, 200)
            djui_hud_render_rect(0, 0, width, height)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text(TEXT_LOCAL_MODEL_ERROR, widthHalf - djui_hud_measure_text(TEXT_LOCAL_MODEL_ERROR) * 0.15 * widthScale, heightHalf, 0.3 * widthScale)
            djui_hud_print_text(TEXT_LOCAL_MODEL_ERROR_FIX, widthHalf - djui_hud_measure_text(TEXT_LOCAL_MODEL_ERROR_FIX) * 0.1 * widthScale, heightHalf + 10 * widthScale, 0.2 * widthScale)
        end

        local x = 135 * widthScale * 0.8

        --[[
        -- Render All Black Squares Behind Below API
        djui_hud_set_color(menuColorHalf.r * 0.1, menuColorHalf.g * 0.1, menuColorHalf.b * 0.1, menuOpacity)
        -- Description
        djui_hud_render_rect(width - x + 2, 2 + 46, x - 4, height - 4 - 46)
        -- Buttons
        djui_hud_render_rect(2, 2 + 46, x - 4, height - 4 - 46)
        -- Header
        djui_hud_render_rect(2, 2, width - 4, 46)
        ]]

        -- API Rendering (Below Text)
        if #hookTableRenderInMenu.back > 0 then
            for i = 1, #hookTableRenderInMenu.back do
                hookTableRenderInMenu.back[i]()
            end
        end

        --[[
        --Character Description
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_render_rect(width - x, 50, 2, height - 50)
        djui_hud_render_rect(width - x, height - 2, x, 2)
        djui_hud_render_rect(width - 2, 50, 2, height - 50)
        djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
        djui_hud_set_font(FONT_ALIASED)
        local character = characterTable[currChar]
        local TEXT_SAVE_NAME = "Save Name: " .. character.saveName
        local TEXT_MOVESET = "Has Moveset: "..(character.hasMoveset and "Yes" or "No")
        local TEXT_ALT = "Alt: " .. character.currAlt .. "/" .. #character
        character = characterTable[currChar][character.currAlt]
        local paletteCount = characterColorPresets[gCSPlayers[0].modelId] ~= nil and #characterColorPresets[gCSPlayers[0].modelId] or 0
        local currPaletteTable = characterColorPresets[gCSPlayers[0].modelId] and characterColorPresets[gCSPlayers[0].modelId] or {currPalette = 0}
        if optionTable[optionTableRef.debugInfo].toggle == 0 then
            -- Actual Description --
            local TEXT_NAME = string_underscore_to_space(character.name)
            local TEXT_CREDIT = "Credit: " .. character.credit
            local TEXT_DESCRIPTION_TABLE = character.description
            local TEXT_PREF_LOAD_NAME = string_underscore_to_space(TEXT_PREF_LOAD_NAME) .. ((TEXT_PREF_LOAD_ALT ~= 1 and TEXT_PREF_LOAD_NAME ~= "Default" and currChar ~= 1) and " ("..TEXT_PREF_LOAD_ALT..")" or "")

            local textX = x * 0.5
            djui_hud_print_text(TEXT_NAME, width - textX - djui_hud_measure_text(TEXT_NAME) * 0.3, 55, 0.6)
            djui_hud_set_font(FONT_TINY)
            local creditScale = 0.6 
            creditScale = math_min(creditScale, 100/djui_hud_measure_text(TEXT_CREDIT))
            djui_hud_print_text(TEXT_CREDIT, width - textX - djui_hud_measure_text(TEXT_CREDIT) * creditScale *0.5, 74, creditScale)
            djui_hud_set_font(FONT_ALIASED)
            djui_hud_print_text(TEXT_DESCRIPTION, width - textX - djui_hud_measure_text(TEXT_DESCRIPTION) * 0.2, 85, 0.4)
            if widthScale < 1.65 then
                for i = 1, #TEXT_DESCRIPTION_TABLE do
                    djui_hud_print_text(TEXT_DESCRIPTION_TABLE[i], width - textX - djui_hud_measure_text(TEXT_DESCRIPTION_TABLE[i]) * 0.15, 90 + i * 9, 0.3)
                end
            else
                for i = 1, math_ceil(#TEXT_DESCRIPTION_TABLE*0.5) do
                    local tablePos = (i * 2) - 1
                    if TEXT_DESCRIPTION_TABLE[tablePos] and TEXT_DESCRIPTION_TABLE[tablePos + 1] then
                        local TEXT_STRING = TEXT_DESCRIPTION_TABLE[tablePos] .. " " .. TEXT_DESCRIPTION_TABLE[tablePos + 1]
                        djui_hud_print_text(TEXT_STRING, width - textX - djui_hud_measure_text(TEXT_STRING) * 0.15, 90 + i * 9, 0.3)
                    elseif TEXT_DESCRIPTION_TABLE[tablePos] then
                        local TEXT_STRING = TEXT_DESCRIPTION_TABLE[tablePos]
                        djui_hud_print_text(TEXT_STRING, width - textX - djui_hud_measure_text(TEXT_STRING) * 0.15, 90 + i * 9, 0.3)
                    end
                end
            end

            menuText = {
                TEXT_PREF_SAVE .. " - " .. TEXT_PREF_LOAD_NAME
            }
            local modelId = gCSPlayers[0].modelId
            local TEXT_PRESET_TOGGLE = ((currPaletteTable[currPaletteTable.currPalette] ~= nil and currPaletteTable[currPaletteTable.currPalette].name ~= nil) and (currPaletteTable[currPaletteTable.currPalette].name .. " - ") or "") .. ((paletteCount > 1 and "("..currPaletteTable.currPalette.."/"..paletteCount..")" or (currPaletteTable.currPalette > 0 and "On" or "Off")) or "Off")
            if characterColorPresets[modelId] and gGlobalSyncTable.charSelectRestrictPalettes == 0 then
                table_insert(menuText, TEXT_PREF_PALETTE .. " - " .. TEXT_PRESET_TOGGLE)
            elseif gGlobalSyncTable.charSelectRestrictPalettes > 0 then
                table_insert(menuText, TEXT_PALETTE_RESTRICTED)
            end
            if #menuText > 1 then
                bindTextTimer = (bindTextTimer + 1)%(bindTextTimerLoop)
            end
            if bindTextTimer == 0 then
                bindText = bindText + 1
                bindTextOpacity = -254
            end
            if bindText > #menuText or not menuText[bindText] then
                bindText = 1
            end
            if menuText[bindText] ~= prevBindText and bindTextOpacity == -255 then
                bindTextOpacity = -254
            end
            if bindTextOpacity > -255 and bindTextOpacity < 255 then
                bindTextOpacity = math.min(bindTextOpacity + 25, 255)
                if bindTextOpacity == 255 then
                    bindTextOpacity = -255
                    prevBindText = menuText[bindText]
                end
            end
            --local bindTextOpacity = math.clamp(math.abs(math.sin(bindTextTimer*MATH_PI/bindTextTimerLoop)), 0, 0.2) * 5 * 255
            local fadeOut = math_abs(math.clamp(bindTextOpacity, -255, 0))
            local fadeIn = math_abs(math.clamp(bindTextOpacity, 0, 255))
            local bindTextScale = math.min((x - 10)/(djui_hud_measure_text(menuText[bindText]) * 0.3), 1)*0.3
            local prevBindTextScale = math.min((x - 10)/(djui_hud_measure_text(prevBindText) * 0.3), 1)*0.3
            djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, fadeOut)
            djui_hud_print_text(prevBindText, width - textX - djui_hud_measure_text(prevBindText) * prevBindTextScale*0.5, height - 15, prevBindTextScale)
            djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, fadeIn)
            djui_hud_print_text(menuText[bindText], width - textX - djui_hud_measure_text(menuText[bindText]) * bindTextScale*0.5, height - 15, bindTextScale)
            djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
        else
            -- Debugging Info --
            local TEXT_NAME = "Name: " .. character.name
            local TEXT_CREDIT = "Credit: " .. character.credit
            local TEXT_DESCRIPTION_TABLE = character.description
            local TEXT_COLOR = "Color: R-" .. character.color.r ..", G-" ..character.color.g ..", B-"..character.color.b
            local TEX_LIFE_ICON = character.lifeIcon
            local TEX_STAR_ICON = character.starIcon
            local TEXT_SCALE = "Camera Scale: " .. character.camScale
            local TEXT_PRESET = "Preset Palette: ("..currPaletteTable.currPalette.."/"..paletteCount..")"
            local TEXT_PREF = "Preferred: " .. TEXT_PREF_LOAD_NAME .. " ("..TEXT_PREF_LOAD_ALT..")"
            local TEXT_PREF_COLOR = "Pref Color: R-" .. prefCharColor.r .. ", G-" .. prefCharColor.g .. ", B-" .. prefCharColor.b

            local textX = x * 0.5
            djui_hud_print_text(TEXT_DEBUGGING, width - textX - djui_hud_measure_text(TEXT_DEBUGGING) * 0.3, 55, 0.6)
            djui_hud_set_font(FONT_TINY)
            local y = 72
            djui_hud_print_text(TEXT_NAME, width - x + 8, y, 0.5)
            y = y + 7
            djui_hud_print_text(TEXT_SAVE_NAME, width - x + 8, y, 0.5)
            y = y + 7
            djui_hud_print_text(TEXT_ALT, width - x + 8, y, 0.5)
            y = y + 7
            djui_hud_print_text(TEXT_CREDIT, width - x + 8, y, 0.5)
            y = y + 7
            if TEXT_DESCRIPTION_TABLE[1] ~= "No description has been provided" then
                djui_hud_print_text(TEXT_DESCRIPTION_SHORT, width - x + 8, y, 0.5)
                y = y + 2
                local removeLine = 0
                for i = 1, #TEXT_DESCRIPTION_TABLE do
                    if TEXT_DESCRIPTION_TABLE[i] ~= "" then
                        djui_hud_set_font(FONT_ALIASED)
                        local TEXT_DESCRIPTION_LINE = TEXT_DESCRIPTION_TABLE[i]
                        if (djui_hud_measure_text(TEXT_DESCRIPTION_TABLE[i]) * 0.3 > 100) then
                            TEXT_DESCRIPTION_LINE = "(!) " .. TEXT_DESCRIPTION_LINE
                        else
                            TEXT_DESCRIPTION_LINE = "    " .. TEXT_DESCRIPTION_LINE
                        end
                        djui_hud_set_font(FONT_TINY)
                        djui_hud_print_text(TEXT_DESCRIPTION_LINE, width - x + 5, y + (i-removeLine) * 5, 0.4)
                    else
                        removeLine = removeLine + 1
                    end
                end
                local descriptionOffset = (#TEXT_DESCRIPTION_TABLE - removeLine) * 5
                y = y + 5 + descriptionOffset
            end
            djui_hud_set_color(character.color.r, character.color.g, character.color.b, 255)
            djui_hud_print_text(TEXT_COLOR, width - x + 8, y, 0.5)
            djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
            y = y + 7
            if type(TEX_LIFE_ICON) ~= TYPE_STRING then
                djui_hud_print_text(TEXT_LIFE_ICON .. "    (" .. TEX_LIFE_ICON.width .. "x" .. TEX_LIFE_ICON.height .. ")", width - x + 8, y, 0.5)
                djui_hud_set_color(255, 255, 255, 255)
                djui_hud_render_texture(TEX_LIFE_ICON, width - x + 33, y + 1, 0.4 / (TEX_LIFE_ICON.width * MATH_DIVIDE_16), 0.4 / (TEX_LIFE_ICON.height * MATH_DIVIDE_16))
            else
                djui_hud_print_text(TEXT_LIFE_ICON .. "    (FONT_HUD)", width - x + 8, y, 0.5)
                djui_hud_set_font(FONT_HUD)
                djui_hud_set_color(255, 255, 255, 255)
                djui_hud_print_text(TEX_LIFE_ICON, width - x + 33, y + 1, 0.4)
                djui_hud_set_font(FONT_TINY)
            end
            y = y + 7
            djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
            djui_hud_print_text(TEXT_STAR_ICON .. "    (" .. TEX_STAR_ICON.width .. "x" .. TEX_STAR_ICON.height .. ")", width - x + 8, y, 0.5)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_texture(TEX_STAR_ICON, width - x + 35, y + 1, 0.4 / (TEX_STAR_ICON.width * MATH_DIVIDE_16), 0.4 / (TEX_STAR_ICON.height * MATH_DIVIDE_16))
            y = y + 7
            djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
            djui_hud_print_text(TEXT_FORCED_CHAR .. baseCharStrings[character.baseChar], width - x + 8, y, 0.5)
            y = y + 7
            djui_hud_print_text(TEXT_TABLE_POS .. currChar, width - x + 8, y, 0.5)
            y = y + 7
            djui_hud_print_text(TEXT_SCALE, width - x + 8, y, 0.5)
            local modelId = gCSPlayers[0].modelId
            y = y + 7
            if characterColorPresets[modelId] ~= nil then
                djui_hud_print_text(TEXT_PALETTE, width - x + 8, y, 0.5)
                local x = x - djui_hud_measure_text(TEXT_PALETTE)*0.5
                local currPalette = currPaletteTable.currPalette > 0 and currPaletteTable.currPalette or 1
                local paletteTable = currPaletteTable[currPalette]
                for i = 0, #paletteTable do
                    djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
                    djui_hud_render_rect(width - x + 6.5 + (6.5 * i), y + 1.5, 6, 6)
                    djui_hud_set_color(paletteTable[i].r, paletteTable[i].g, paletteTable[i].b, 255)
                    djui_hud_render_rect(width - x + 7 + (6.5 * i), y + 2, 5, 5)
                end
                y = y + 7
                djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
            end
            djui_hud_print_text(TEXT_MOVESET, width - x + 8, y, 0.5)
            y = y + 7
            djui_hud_print_text(TEXT_PRESET, width - x + 8, height - 29, 0.5)
            djui_hud_print_text(TEXT_PREF, width - x + 8, height - 22, 0.5)
            djui_hud_set_color(prefCharColor.r, prefCharColor.g, prefCharColor.b, 255)
            djui_hud_print_text(TEXT_PREF_COLOR, width - x + 8, height - 15, 0.5)
            djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
        end
        ]]

        --Character Buttons
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_render_rect(0, 50, 2, height - 50)
        djui_hud_render_rect(x - 2, 50, 2, height - 50)
        djui_hud_render_rect(0, height - 2, x, 2)
        
        local leftRightAnim = 0
        if optionTable[optionTableRef.anims].toggle > 0 then
            buttonAnimTimer = buttonAnimTimer + 1
            leftRightAnim = buttonAltAnim/inputStallToDirectional
            if buttonAltAnim ~= 0 then
                if buttonAltAnim > 0 then
                    buttonAltAnim = buttonAltAnim - 3
                else
                    buttonAltAnim = buttonAltAnim + 3
                end
            end
        end
        if optionTable[optionTableRef.anims].toggle == 0 then
            buttonScroll = 0
        elseif math_abs(buttonScroll) > 0.1 then
            buttonScroll = buttonScroll * 0.05 * inputStallToDirectional
        end

        local buttonColor = {}
        local buttonX = 20 * widthScale
        local buttonAnimX = buttonX + math_sin(buttonAnimTimer * 0.05) * 2.5 + 5
        local charNum = -1
        for i = -1, 4 do
            -- Hide Locked Characters based on Toggle
            charNum = currCharRender + i
            local char = characterTableRender[charNum]
            if char ~= nil then
                if not char.locked then
                    buttonColor = char[char.currAlt].color
                else
                    buttonColor = {r = char[char.currAlt].color.r*0.5, g = char[char.currAlt].color.g*0.5, b = char[char.currAlt].color.b*0.5}
                end
                djui_hud_set_color(buttonColor.r, buttonColor.g, buttonColor.b, 255)
                local x = buttonX
                local y = 104 + buttonScroll
                if i == 0 then
                    if optionTable[optionTableRef.anims].toggle > 0 then
                        x = buttonAnimX
                    else
                        x = buttonX + 5
                    end
                    if #char > 1 then
                        djui_hud_set_rotation(0x4000, 0, 0)
                        djui_hud_render_triangle(x - 6 + math_min(leftRightAnim, 0), y, 8, 4)
                        djui_hud_set_rotation(-0x4000, 0, 0)
                        djui_hud_render_triangle(x + 76 + math_max(leftRightAnim, 0), y - 8 - 1*MATH_DIVIDE_16, 8, 4)
                        djui_hud_set_rotation(0, 0, 0)
                    end
                end
                local y = (i + 3) * 30 + buttonScroll
                djui_hud_render_rect(x, y, 1, 20)
                djui_hud_render_rect(x, y, 70, 1)
                djui_hud_render_rect(x + 69, y, 1, 20)
                djui_hud_render_rect(x, y + 19, 70, 1)
                djui_hud_set_color(buttonColor.r * 0.1, buttonColor.g * 0.1, buttonColor.b * 0.1, menuOpacity)
                djui_hud_render_rect(x + 1, y + 1, 68, 18)
                djui_hud_set_font(FONT_TINY)
                djui_hud_set_color(buttonColor.r, buttonColor.g, buttonColor.b, 255)
                local charName = char[char.currAlt].name
                if char.locked then
                    charName = TEXT_CHAR_LOCKED
                end
                djui_hud_set_color(buttonColor.r * 0.5 + 127, buttonColor.g * 0.5 + 127, buttonColor.b * 0.5 + 127, 255)
                djui_hud_print_text(charName, x + 5, y + 5, 0.6)
            end
        end

        -- Scroll Bar
        local MATH_DIVIDE_CHARACTERS = 1/#characterTableRender
        local MATH_7_WIDTHSCALE = 7 * widthScale
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_render_rect(MATH_7_WIDTHSCALE, 55, 1, 170)
        djui_hud_render_rect(MATH_7_WIDTHSCALE, 55, 7, 1)
        djui_hud_render_rect(MATH_7_WIDTHSCALE + 6, 55, 1, 170)
        djui_hud_render_rect(MATH_7_WIDTHSCALE, 224, 7, 1)
        djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
        djui_hud_render_rect(MATH_7_WIDTHSCALE + 2, 57 + 166 * ((currCharRender - 1) * MATH_DIVIDE_CHARACTERS) - (buttonScroll * MATH_DIVIDE_30) * (166 * MATH_DIVIDE_CHARACTERS), 3, 166 * MATH_DIVIDE_CHARACTERS)
        djui_hud_set_font(FONT_TINY)
        local TEXT_CHAR_COUNT = currCharRender .. "/" .. #characterTableRender
        djui_hud_print_text(TEXT_CHAR_COUNT, (11 - djui_hud_measure_text(TEXT_CHAR_COUNT) * 0.2) * widthScale, height - 12, 0.4)
        djui_hud_print_text("- "..characterCategories[currCategory] .. " (L/R)", (11 + djui_hud_measure_text(TEXT_CHAR_COUNT) * 0.2) * widthScale, height - 12, 0.4)

        --[[
        --Character Select Header
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_render_rect(0, 0, width, 2)
        djui_hud_render_rect(0, 0, 2, 50)
        djui_hud_render_rect(0, 48, width, 2)
        djui_hud_render_rect(width - 2, 0, 2, 50)
        djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
        if TEX_OVERRIDE_HEADER ~= nil then -- Render Override Header
            djui_hud_render_texture(TEX_OVERRIDE_HEADER, widthHalf - 128, 10, 1 / (TEX_OVERRIDE_HEADER.height*MATH_DIVIDE_32), 1 / (TEX_OVERRIDE_HEADER.height*MATH_DIVIDE_32))
        else
            djui_hud_render_texture(TEX_HEADER, widthHalf - 128, 10, 1, 1)
        end
        djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
        djui_hud_set_font(FONT_TINY)
        djui_hud_print_text(optionTable[optionTableRef.debugInfo].toggle == 0 and TEXT_VERSION or MOD_VERSION_DEBUG, 5, 3, 0.5)
        ]]

        --Unsupported Res Warning
        if width < 319 or width > 575 then
            djui_hud_print_text(TEXT_RATIO_UNSUPPORTED, 5, 39, 0.5)
        end

        -- API Rendering (Above Text)
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        if #hookTableRenderInMenu.front > 0 then
            for i = 1, #hookTableRenderInMenu.front do
                hookTableRenderInMenu.front[i]()
            end
        end
        djui_hud_set_resolution(RESOLUTION_N64)

        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_render_rect(width * 0.5 - 50 * widthScale, height - 2, 100 * widthScale, 2)

        -- Make Random Elements based on Character Name
        math.randomseed(hash(characterTable[currChar][characterTable[currChar].currAlt].name))
    
        -- Render Background Wall
        local playerShirt = network_player_get_override_palette_color(gNetworkPlayers[0], SHIRT)
        local playerPants = network_player_get_override_palette_color(gNetworkPlayers[0], PANTS)
        --djui_hud_set_rotation(angle_from_2d_points(width*0.7, -10, width*0.7 - 25, height - 35) + 0x4000, 1, 0)
        local wallWidth = TEX_WALL_LEFT.width
        local wallHeight = TEX_WALL_LEFT.height
        local wallScale = 0.65 * widthScale
        djui_hud_set_color(playerShirt.r, playerShirt.g, playerShirt.b, 255)
        djui_hud_render_texture(TEX_WALL_LEFT, width*0.7 - 10 - wallWidth*wallScale, 40, wallScale, wallScale)
        djui_hud_set_color(playerPants.r, playerPants.g, playerPants.b, 255)
        djui_hud_render_texture(TEX_WALL_RIGHT, width*0.7 - 10 - wallWidth*wallScale, 40, wallScale, wallScale)
        djui_hud_set_rotation(math.random(0, 0x2000) - 0x1000, 0.5, 0.5)
        djui_hud_set_color(255, 255, 255, 150)
        djui_hud_render_texture(TEX_GRAFFITI_DEFAULT, width*0.35 - TEX_GRAFFITI_DEFAULT.width*0.5*0.4, height*0.5 - TEX_GRAFFITI_DEFAULT.height*0.5*0.4, 0.4, 0.4)
        djui_hud_set_rotation(0, 0, 0)

        if not gridMenu then

        else
            -- Render Character Grid
            local currRow = math.floor((currCharRender - 1)/gridButtonsPerRow)
            gridYOffset = lerp(gridYOffset, currRow*35, 0.1)
            for i = 1, #characterTableRender do
                local row = math.floor((i - 1)/gridButtonsPerRow)
                local column = (i - 1)%gridButtonsPerRow
                local charIcon = characterTableRender[i][characterTableRender[i].currAlt].lifeIcon
                local charColor = characterTableRender[i][characterTableRender[i].currAlt].color
                if i == currCharRender then
                    local blinkAnim = math.abs(math.sin(get_global_timer()*0.1))
                    djui_hud_set_color(255 + (charColor.r - 255)*blinkAnim, 255 + (charColor.g - 255)*blinkAnim, 255 + (charColor.b - 255)*blinkAnim, 255)
                else
                    djui_hud_set_color(charColor.r, charColor.g, charColor.b, 255)
                end
                local x = width*0.3 - gridButtonsPerRow*35*0.5 + 35*column - math.abs(row - gridYOffset/35)^2*3
                local y = height*0.5 - 35*0.5 + row*35 - gridYOffset
                djui_hud_render_texture(TEX_BUTTON_SMALL, x, y, 1, 1)
                x = x + 8
                y = y + 8
                djui_hud_set_color(255, 255, 255, 255)
                if type(charIcon) == TYPE_STRING then
                    djui_hud_set_font(FONT_RECOLOR_HUD)
                    djui_hud_set_color(charColor.r, charColor.g, charColor.b, 255)
                    djui_hud_print_text(charIcon, x, y, 1)
                else
                    djui_hud_render_texture(charIcon, x, y, 1 / (charIcon.width * MATH_DIVIDE_16), 1 / (charIcon.height * MATH_DIVIDE_16))
                end
            end
        end

        -- Render Background Top
        djui_hud_set_rotation(angle_from_2d_points(-10, 35, width*0.7 - 5, 50), 0, 1)
        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_render_rect(-10, -30, width*0.7 + 5, 70)
        djui_hud_set_rotation(0, 0, 0)

        -- Render Background Bottom
        djui_hud_set_rotation(angle_from_2d_points(-10, height - 50, width + 10, height - 35), 0, 0)
        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_render_rect(-10, height - 50, width*1.5, 100)
        djui_hud_set_rotation(0, 0, 0)

        -- Render Character Description
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        local credit = characterTable[currChar][characterTable[currChar].currAlt].credit
        local desc = characterTable[currChar][characterTable[currChar].currAlt].description
        local descRender = desc .. " - " .. desc
        while djui_hud_measure_text(descRender)*0.8 < width do
            descRender = descRender .. " - " .. desc
        end
        descRender = descRender .. " - " .. desc
        djui_hud_print_text("Creator: " .. credit, 5, height - 30, 0.8)
        djui_hud_print_text(descRender, 5 - get_global_timer()%djui_hud_measure_text(desc .. " - ")*0.8, height - 17, 0.8)

        -- Render Character Name
        djui_hud_set_font(FONT_MENU)
        local charName = characterTable[currChar][characterTable[currChar].currAlt].name
        local nameScale = math.min(80/djui_hud_measure_text(charName), 0.8)
        local nameScaleCapped = math.max(nameScale, 0.3)
        djui_hud_set_color(menuColor.r*0.5, menuColor.g*0.5, menuColor.b*0.5, 255)
        djui_hud_render_rect(width*0.7 - 5, 30 - 35*nameScaleCapped, width*0.5, 70*nameScaleCapped)
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_render_caution_tape(width*0.7 - 5, 27 - 32*nameScaleCapped + (math.random(0, 4) - 2), width + 5, 27 - 32*nameScaleCapped + (math.random(0, 4) - 2), 1, 0.4) -- Top Tape
        djui_hud_render_caution_tape(width*0.7 - 5, 27 + 32*nameScaleCapped + (math.random(0, 4) - 2), width + 5, 27 + 32*nameScaleCapped + (math.random(0, 4) - 2), 1, 0.4) -- Bottom Tape
        djui_hud_print_text(charName, width*0.85 - djui_hud_measure_text(charName)*0.5*nameScale - 2, 30 - 32*nameScale, nameScale)

        -- Render Header
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_set_rotation(angle_from_2d_points(-10, 35, width*0.7 - 5, 50), 0, 0)
        djui_hud_render_texture(TEX_HEADER, 5, -5, 0.4, 0.4)
        djui_hud_set_rotation(0, 0, 0)

        -- Render Tape
        djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
        djui_hud_render_caution_tape(-10, 35, width*0.7 - 5, 50, 1) -- Top Tape
        djui_hud_render_caution_tape(width*0.7 - 2, -10, width*0.7 - 15, height - 35, 1, 0.6) -- Side Tape
        djui_hud_render_caution_tape(-10, height - 50, width + 10, height - 35, 1) -- Bottom Tape


        --Options display
        local optionTableCount = #optionTable
        if options or optionAnimTimer > optionAnimTimerCap then
            djui_hud_set_color(menuColor.r * 0.25, menuColor.g * 0.25, menuColor.b * 0.25, 205 + maxf(-200, optionAnimTimer))
            djui_hud_render_rect(0, 0, width, height)
            djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
            djui_hud_render_rect(width * 0.5 - 50 * widthScale, minf(55 - optionAnimTimer, height - 25 * widthScale), 100 * widthScale, 200)
            djui_hud_set_color(menuColor.r * 0.1, menuColor.g * 0.1, menuColor.b * 0.1, menuOpacity)
            djui_hud_render_rect(width * 0.5 - 50 * widthScale + 2, minf(55 - optionAnimTimer + 2, height - 25 * widthScale + 2), 100 * widthScale - 4, 196)
            djui_hud_set_font(FONT_ALIASED)

            if not creditsAndTransition then
                local widthScaleLimited = minf(widthScale, 1.5)
                -- Up Arrow
                if currOption > 3 then
                    djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
                    djui_hud_render_triangle(widthHalf - 3.5*widthScaleLimited, 94 - optionAnimTimer, 6*widthScaleLimited, 3*widthScaleLimited)
                end

                -- Down Arrow
                if currOption < optionTableCount - 2 then
                    local yOffset = 90 - optionAnimTimer + 45 * widthScaleLimited
                    djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
                    djui_hud_set_rotation(0x8000, 0.5, 0.5)
                    djui_hud_render_triangle(widthHalf - 3.5*widthScaleLimited, yOffset + 10 + 3*widthScaleLimited, 6*widthScaleLimited, 3*widthScaleLimited)
                    djui_hud_set_rotation(0, 0, 0)
                end

                -- Options 
                for i = currOption - 2, currOption + 2 do
                    if not (i < 1 or i > optionTableCount) then
                        local toggleName = optionTable[i].name
                        local scale = 0.5
                        local yOffset = 100 - optionAnimTimer + (i - currOption + 2) * 9 * widthScaleLimited

                        local lockName = nil
                        if optionTable[i].lock ~= nil then
                            lockName = optionTable[i].lock()
                        end

                        if i == currOption then
                            djui_hud_set_font(FONT_ALIASED)
                            scale = 0.3
                            yOffset = yOffset - 1
                            local currToggleName = optionTable[i].toggleNames[optionTable[i].toggle + 1]
                            currToggleName = currToggleName and currToggleName or "???"
                            if lockName ~= nil then
                                currToggleName = lockName
                            end
                            if currToggleName ~= "" then
                                toggleName = toggleName .. " - " .. currToggleName
                            end
                        else
                            djui_hud_set_font(FONT_TINY)
                        end
                        djui_hud_set_color(menuColorHalf.r * (lockName ~= nil and 0.5 or 1), menuColorHalf.g * (lockName ~= nil and 0.5 or 1), menuColorHalf.b * (lockName ~= nil and 0.5 or 1), 255)
                        scale = scale * widthScaleLimited
                        djui_hud_print_text(toggleName, widthHalf - djui_hud_measure_text(toggleName) * scale * 0.5, yOffset, scale)
                    end
                end

                -- Description
                if optionTable[currOption].description ~= nil then
                    djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
                    for i = 1, #optionTable[currOption].description do
                        djui_hud_set_font(FONT_ALIASED)
                        local line = optionTable[currOption].description[i]
                        djui_hud_print_text(line, widthHalf - djui_hud_measure_text(line) * 0.15, 180 - optionAnimTimer + 15 * widthScaleLimited + 8 * i - 8 * #optionTable[currOption].description, 0.3)
                    end
                end
                -- Footer
                djui_hud_set_font(FONT_TINY)
                djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
                djui_hud_print_text(TEXT_OPTIONS_SELECT, widthHalf - djui_hud_measure_text(TEXT_OPTIONS_SELECT) * 0.3, height - 20 - optionAnimTimer, 0.6)
            else
                local renderList = {}
                for i = 1, #creditTable do
                    local credit = creditTable[i]
                    table_insert(renderList, {textLeft = credit.packName, font = FONT_ALIASED})
                    for i = 1, #credit do
                        local credit = credit[i]
                        table_insert(renderList, {textLeft = credit.creditTo, textRight = credit.creditFor, font = FONT_NORMAL})
                    end
                end

                local xLeft = widthHalf - 50 * widthScale + 8
                local xRight = widthHalf + 50 * widthScale - 8
                local y = 80 + 10*widthScale - optionAnimTimer - creditScroll
                local prevY = 80 + 10*widthScale - optionAnimTimer - prevCreditScroll
                for i = 1, #renderList do
                    local credit = renderList[i]
                    local header = (credit.font == FONT_ALIASED)
                    if y > 62 and y < height then 
                        djui_hud_set_font(credit.font)
                        if not header then
                            djui_hud_set_color(menuColorHalf.r, menuColorHalf.g, menuColorHalf.b, 255)
                        else
                            djui_hud_set_color(menuColor.r, menuColor.g, menuColor.b, 255)
                        end
                        local x = xLeft - (header and 3 or 0)
                        local scale = (header and 0.3 or 0.2)*widthScale
                        djui_hud_print_text_interpolated(credit.textLeft, x, prevY, scale, x, y, scale)
                        if credit.textRight then
                            local x = xRight - djui_hud_measure_text(credit.textRight)*scale
                            local scale = 0.2*widthScale
                            djui_hud_print_text_interpolated(credit.textRight, x, prevY, scale, x, y, scale)
                        end
                    end
                    y = y + (header and 9 or 6)*widthScale
                    prevY = prevY + (header and 9 or 6)*widthScale
                    if renderList[i + 1] ~= nil and renderList[i + 1].font == FONT_ALIASED then
                        y = y + 2
                        prevY = prevY + 2
                    end
                end
                creditScrollRange = math_max(((y + creditScroll)) - (height - 36), 0)
                prevCreditScroll = creditScroll

                for i = 1, 8 do
                    djui_hud_set_color(menuColor.r * 0.1, menuColor.g * 0.1, menuColor.b * 0.1, 100)
                    djui_hud_render_rect(widthHalf - 50 * widthScale + 2, 60 - optionAnimTimer, 100 * widthScale - 4, i*4)
                    djui_hud_render_rect(widthHalf - 50 * widthScale + 2, height - 2 - i*4, 96 * widthScale, i*4)
                end
            end

            -- Render Header
            djui_hud_set_font(FONT_ALIASED)
            djui_hud_set_color(menuColor.r * 0.5 + 127, menuColor.g * 0.5 + 127, menuColor.b * 0.5 + 127, 255)
            local text = TEXT_OPTIONS_HEADER
            if creditsAndTransition then
                text = TEXT_CREDITS_HEADER
            elseif currOption > defaultOptionCount then
                text = TEXT_OPTIONS_HEADER_API
            end
            djui_hud_print_text(text, widthHalf - djui_hud_measure_text(text) * 0.3 * minf(widthScale, 1.5), 65 + optionAnimTimer * -1, 0.6 * minf(widthScale, 1.5))

            -- Fade in/out of credits
            if optionTable[optionTableRef.anims].toggle == 1 then
                if credits and creditsCrossFade > -creditsCrossFadeCap then
                    creditsCrossFade = creditsCrossFade - 1
                    if creditsCrossFade == 0 then creditsCrossFade = creditsCrossFade - 1 end
                end
                if not credits and creditsCrossFade < creditsCrossFadeCap then
                    creditsCrossFade = creditsCrossFade + 1
                    if creditsCrossFade == 0 then creditsCrossFade = creditsCrossFade + 1 end
                end
                if creditsCrossFade < 0 then
                    creditsAndTransition = true
                else
                    creditsAndTransition = false
                end
            else
                if credits then
                    creditsCrossFade = -creditsCrossFadeCap
                else
                    creditsCrossFade = creditsCrossFadeCap
                end
                creditsAndTransition = credits
            end
            
            djui_hud_set_resolution(RESOLUTION_N64)
            djui_hud_set_color(0, 0, 0, (math_abs(creditsCrossFade)) * -creditsCrossFadeMath)
            djui_hud_render_rect(width * 0.5 - 50 * widthScale + 2, minf(55 - optionAnimTimer + 2, height - 25 * widthScale + 2), 100 * widthScale - 4, 196)
        else
            -- How to open options display
        end

        -- Anim logic
        if options then
            if optionTable[optionTableRef.anims].toggle > 0 then
                if optionAnimTimer < -1 then
                    optionAnimTimer = optionAnimTimer * 0.9
                end
            else
                optionAnimTimer = -1
            end
        else
            if optionTable[optionTableRef.anims].toggle > 0 then
                if optionAnimTimer > optionAnimTimerCap then
                    optionAnimTimer = optionAnimTimer * 1.3
                end
            else
                optionAnimTimer = optionAnimTimerCap
            end
        end
        optionAnimTimer = maxf(optionAnimTimer, -200)
    else
        options = false
        optionAnimTimer = optionAnimTimerCap
        credits = false
        creditsCrossFade = 0
        bindTextTimer = 0
    end

    -- Fade in/out of menu
    if optionTable[optionTableRef.anims].toggle == 1 then
        if menu and menuCrossFade > -menuCrossFadeCap then
            menuCrossFade = menuCrossFade - 1
            if menuCrossFade == 0 then menuCrossFade = menuCrossFade - 1 end
        end
        if not menu and menuCrossFade < menuCrossFadeCap then
            menuCrossFade = menuCrossFade + 1
            if menuCrossFade == 0 then menuCrossFade = menuCrossFade + 1 end
        end
        if menuCrossFade < 0 then
            menuAndTransition = true
        else
            menuAndTransition = false
        end
    else
        if menu then
            menuCrossFade = -menuCrossFadeCap
        else
            menuCrossFade = menuCrossFadeCap
        end
        menuAndTransition = menu
    end

    -- Info / Z Open Bind on Pause Menu
    if is_game_paused() and not djui_hud_is_pause_menu_created() and gMarioStates[0].action ~= ACT_EXIT_LAND_SAVE_DIALOG then
        local currCharY = 0
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_set_font(FONT_USER)
        if optionTable[optionTableRef.openInputs].toggle == 1 then
            currCharY = 27
            local text = menu_is_allowed() and TEXT_PAUSE_Z_OPEN or TEXT_PAUSE_UNAVAILABLE
            width = djui_hud_get_screen_width() - djui_hud_measure_text(text)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text(text, width - 20, 16, 1)
        end

        if optionTable[optionTableRef.localModels].toggle == 1 then
            local character = characterTable[currChar][characterTable[currChar].currAlt]
            local charName = string_underscore_to_space(character.name)
            local TEXT_PAUSE_CURR_CHAR_WITH_NAME = TEXT_PAUSE_CURR_CHAR .. charName
            width = djui_hud_get_screen_width() - djui_hud_measure_text(TEXT_PAUSE_CURR_CHAR_WITH_NAME)
            local charColor = character.color
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text(TEXT_PAUSE_CURR_CHAR, width - 20, 16 + currCharY, 1)
            djui_hud_set_color(charColor.r, charColor.g, charColor.b, 255)
            djui_hud_print_text(charName, djui_hud_get_screen_width() - djui_hud_measure_text(charName) - 20, 16 + currCharY, 1)
        else
            width = djui_hud_get_screen_width() - djui_hud_measure_text(TEXT_LOCAL_MODEL_OFF)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text(TEXT_LOCAL_MODEL_OFF, width - 20, 16 + currCharY, 1)
        end

        local text = nil
        if gGlobalSyncTable.charSelectRestrictMovesets > 0 and gGlobalSyncTable.charSelectRestrictPalettes > 0 then
            text = TEXT_MOVESET_AND_PALETTE_RESTRICTED
        elseif gGlobalSyncTable.charSelectRestrictMovesets > 0 then
            text = TEXT_MOVESET_RESTRICTED
        elseif gGlobalSyncTable.charSelectRestrictPalettes > 0 then
            text = TEXT_PALETTE_RESTRICTED
        end
        if text ~= nil then
            width = djui_hud_get_screen_width() - djui_hud_measure_text(text)
            djui_hud_set_color(255, 255, 255, 255)
            currCharY = currCharY + 27
            djui_hud_print_text(text, width - 20, 16 + currCharY, 1)
        end
    end

    -- Cross Fade to Menu
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_color(0, 0, 0, (math_abs(menuCrossFade)) * -menuCrossFadeMath)
    djui_hud_render_rect(0, 0, width, height)
end

local prevMouseScroll = 0
local mouseScroll = 0
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end
    local controller = m.controller
    if inputStallTimerButton > 0 then inputStallTimerButton = inputStallTimerButton - 1 end
    if inputStallTimerDirectional > 0 then inputStallTimerDirectional = inputStallTimerDirectional - 1 end

    if menu and inputStallToDirectional ~= latencyValueTable[optionTable[optionTableRef.inputLatency].toggle + 1] then
        inputStallToDirectional = latencyValueTable[optionTable[optionTableRef.inputLatency].toggle + 1]
    end

    -- Menu Inputs
    if is_game_paused() and m.action ~= ACT_EXIT_LAND_SAVE_DIALOG and (controller.buttonPressed & Z_TRIG) ~= 0 and optionTable[optionTableRef.openInputs].toggle == 1 then
        menu = true
    end
    if not menu and (controller.buttonDown & D_JPAD) ~= 0 and m.action ~= ACT_EXIT_LAND_SAVE_DIALOG and optionTable[optionTableRef.openInputs].toggle == 2 then
        if (controller.buttonDown & R_TRIG) ~= 0 or not ommActive then
            menu = true
        end
        inputStallTimerDirectional = inputStallToDirectional
    end

    if not menu_is_allowed(m) then
        menu = false
        return
    end

    mouseScroll = mouseScroll - djui_hud_get_mouse_scroll_y()

    local cameraToObject = m.marioObj.header.gfx.cameraToObject
    if menuAndTransition and not options then
        if (controller.buttonPressed & X_BUTTON) ~= 0 and inputStallTimerDirectional == 0 then
            inputStallTimerDirectional = inputStallToDirectional
            gridMenu = not gridMenu
            play_sound(SOUND_MENU_CLICK_CHANGE_VIEW, cameraToObject)
        end
        if menu and not gridMenu then
            if inputStallTimerDirectional == 0 and not charBeingSet then
                -- Alt switcher
                if #characterTable[currChar] > 1 then
                    local character = characterTable[currChar]
                    if (controller.buttonPressed & R_JPAD) ~= 0 or controller.stickX > 60 then
                        character.currAlt = character.currAlt + 1
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_CLICK_CHANGE_VIEW, cameraToObject)
                        buttonAltAnim = inputStallToDirectional
                    end
                    if (controller.buttonPressed & L_JPAD) ~= 0 or controller.stickX < -60 then
                        character.currAlt = character.currAlt ~= 0 and character.currAlt - 1 or #character
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_CLICK_CHANGE_VIEW, cameraToObject)
                        buttonAltAnim = -inputStallToDirectional
                    end
                    if character.currAlt > #character then character.currAlt = 1 end
                    if character.currAlt < 1 then character.currAlt = #character end
                end

                if optionTable[optionTableRef.localModels].toggle ~= 0 then    
                    if (controller.buttonPressed & D_JPAD) ~= 0 or (controller.buttonPressed & D_CBUTTONS) ~= 0 or controller.stickY < -60 or prevMouseScroll < mouseScroll then
                        currCharRender = currCharRender + 1
                        --[[
                        local character = characterTableRender[currCharRender]
                        if character ~= nil and character.locked then
                            currCharRender = get_next_unlocked_char()
                        end
                        ]]
                        if (controller.buttonPressed & D_CBUTTONS) == 0 then
                            inputStallTimerDirectional = inputStallToDirectional
                        else
                            inputStallTimerDirectional = 3 -- C-Scrolling
                        end
                        if currCharRender > #characterTableRender then
                            buttonScroll = -buttonScrollCap * #characterTableRender
                        else
                            buttonScroll = buttonScrollCap
                        end
                        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
                        if currCharRender > #characterTableRender then currCharRender = 1 end
                        currChar = characterTableRender[currCharRender].ogNum
                        if characterColorPresets[characterTable[currChar]] ~= nil then
                            characterColorPresets[characterTable[currChar]].currPalette = 0
                        end
                        prevMouseScroll = mouseScroll
                    end
                    if (controller.buttonPressed & U_JPAD) ~= 0 or (controller.buttonPressed & U_CBUTTONS) ~= 0 or controller.stickY > 60 or prevMouseScroll > mouseScroll then
                        currCharRender = currCharRender - 1
                        --[[
                        local character = characterTableRender[currCharRender]
                        if character ~= nil and character.locked then
                            currCharRender = get_last_unlocked_char()
                        end
                        ]]
                        if (controller.buttonPressed & U_CBUTTONS) == 0 then
                            inputStallTimerDirectional = inputStallToDirectional
                        else
                            inputStallTimerDirectional = 3 -- C-Scrolling
                        end
                        if currCharRender < 1 then
                            buttonScroll = buttonScrollCap * (#characterTableRender - 1)
                        else
                            buttonScroll = -buttonScrollCap
                        end
                        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
                        if currCharRender < 1 then currCharRender = #characterTableRender end
                        currChar = characterTableRender[currCharRender].ogNum
                        if characterColorPresets[characterTable[currChar]] ~= nil then
                            characterColorPresets[characterTable[currChar]].currPalette = 0
                        end
                        prevMouseScroll = mouseScroll
                    end

                    -- Tab Switcher
                    if (controller.buttonPressed & L_TRIG) ~= 0 then
                        local renderEmpty = true
                        while renderEmpty do
                            currCategory = currCategory - 1
                            if currCategory < 1 then currCategory = #characterCategories end
                            renderEmpty = not update_character_render_table()
                        end
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_CAMERA_TURN, cameraToObject)
                    end
                    if (controller.buttonPressed & R_TRIG) ~= 0 then
                        local renderEmpty = true
                        while renderEmpty do
                            currCategory = currCategory + 1
                            if currCategory > #characterCategories then currCategory = 1 end
                            renderEmpty = not update_character_render_table()
                        end
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_CAMERA_TURN, cameraToObject)
                    end
                end
            end

            if inputStallTimerButton == 0 then
                if (controller.buttonPressed & A_BUTTON) ~= 0 then
                    if characterTable[currChar] ~= nil then
                        mod_storage_save_pref_char(characterTable[currChar])
                        inputStallTimerButton = inputStallToButton
                        play_sound(SOUND_MENU_CLICK_FILE_SELECT, cameraToObject)
                    else
                        play_sound(SOUND_MENU_CAMERA_BUZZ, cameraToObject)
                    end
                    
                    -- Set bottom right text
                    bindText = 1
                    bindTextTimer = 1
                end
                if (controller.buttonPressed & B_BUTTON) ~= 0 then
                    menu = false
                end
                if (controller.buttonPressed & START_BUTTON) ~= 0 then
                    options = true
                end
                local modelId = gCSPlayers[0].modelId
                local paletteCount = characterColorPresets[gCSPlayers[0].modelId] ~= nil and #characterColorPresets[gCSPlayers[0].modelId] or 0
                local currPaletteTable = characterColorPresets[gCSPlayers[0].modelId] and characterColorPresets[gCSPlayers[0].modelId] or {currPalette = 0}

                if (controller.buttonPressed & Y_BUTTON) ~= 0 then
                    if characterColorPresets[modelId] and optionTable[optionTableRef.localModels].toggle > 0 and gGlobalSyncTable.charSelectRestrictPalettes == 0 then
                        play_sound(SOUND_MENU_CLICK_FILE_SELECT, cameraToObject)
                        currPaletteTable.currPalette = currPaletteTable.currPalette + 1
                        inputStallTimerButton = inputStallToButton
                    else
                        play_sound(SOUND_MENU_CAMERA_BUZZ, cameraToObject)
                        inputStallTimerButton = inputStallToButton
                    end

                    -- Set bottom right text
                    bindText = 2
                    bindTextTimer = 1
                end
                if characterColorPresets[gCSPlayers[0].modelId] ~= nil then
                    if paletteCount < currPaletteTable.currPalette then currPaletteTable.currPalette = 0 end
                end
            end
        end

        if gridMenu then
            if inputStallTimerDirectional == 0 and not charBeingSet then
                if optionTable[optionTableRef.localModels].toggle ~= 0 then    
                    if (controller.buttonPressed & L_JPAD) ~= 0 or controller.stickX < -60 then
                        currCharRender = currCharRender - 1
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
                        if currCharRender < 1 then currCharRender = #characterTableRender end
                        currChar = characterTableRender[currCharRender].ogNum
                        if characterColorPresets[characterTable[currChar]] ~= nil then
                            characterColorPresets[characterTable[currChar]].currPalette = 0
                        end
                        prevMouseScroll = mouseScroll
                    end
                    if (controller.buttonPressed & R_JPAD) ~= 0 or controller.stickX > 60 then
                        currCharRender = currCharRender + 1
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
                        if currCharRender > #characterTableRender then currCharRender = 1 end
                        currChar = characterTableRender[currCharRender].ogNum
                        if characterColorPresets[characterTable[currChar]] ~= nil then
                            characterColorPresets[characterTable[currChar]].currPalette = 0
                        end
                        prevMouseScroll = mouseScroll
                    end
                    if (controller.buttonPressed & U_JPAD) ~= 0 or controller.stickY > 60 or prevMouseScroll > mouseScroll then
                        currCharRender = currCharRender - gridButtonsPerRow
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
                        if currCharRender < 1 then currCharRender = #characterTableRender end
                        currChar = characterTableRender[currCharRender].ogNum
                        if characterColorPresets[characterTable[currChar]] ~= nil then
                            characterColorPresets[characterTable[currChar]].currPalette = 0
                        end
                        prevMouseScroll = mouseScroll
                    end
                    if (controller.buttonPressed & D_JPAD) ~= 0 or controller.stickY < -60 or prevMouseScroll < mouseScroll then
                        currCharRender = currCharRender + gridButtonsPerRow
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
                        if currCharRender > #characterTableRender then currCharRender = 1 end
                        currChar = characterTableRender[currCharRender].ogNum
                        if characterColorPresets[characterTable[currChar]] ~= nil then
                            characterColorPresets[characterTable[currChar]].currPalette = 0
                        end
                        prevMouseScroll = mouseScroll
                    end

                    -- Tab Switcher
                    if (controller.buttonPressed & L_TRIG) ~= 0 then
                        local renderEmpty = true
                        while renderEmpty do
                            currCategory = currCategory - 1
                            if currCategory < 1 then currCategory = #characterCategories end
                            renderEmpty = not update_character_render_table()
                        end
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_CAMERA_TURN, cameraToObject)
                    end
                    if (controller.buttonPressed & R_TRIG) ~= 0 then
                        local renderEmpty = true
                        while renderEmpty do
                            currCategory = currCategory + 1
                            if currCategory > #characterCategories then currCategory = 1 end
                            renderEmpty = not update_character_render_table()
                        end
                        inputStallTimerDirectional = inputStallToDirectional
                        play_sound(SOUND_MENU_CAMERA_TURN, cameraToObject)
                    end
                end
            end
        end

        -- Handles Camera Posistioning
        camAngle = m.faceAngle.y + 0x800
        eyeState = MARIO_EYES_OPEN
        if controller.buttonPressed & R_CBUTTONS ~= 0 then
            camAngle = camAngle + 0x1000
            eyeState = MARIO_EYES_LOOK_RIGHT
        end
        if controller.buttonPressed & L_CBUTTONS ~= 0 then
            camAngle = camAngle - 0x1000
            eyeState = MARIO_EYES_LOOK_LEFT
        end

        nullify_inputs(m)
        if is_game_paused() then
            controller.buttonPressed = START_BUTTON
        end
    end

    if options and not creditsAndTransition then
        if inputStallTimerDirectional == 0 then
            if (controller.buttonPressed & D_JPAD) ~= 0 or controller.stickY < -60 then
                currOption = currOption + 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
            if (controller.buttonPressed & U_JPAD) ~= 0 or controller.stickY > 60 then
                currOption = currOption - 1
                inputStallTimerDirectional = inputStallToDirectional
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, cameraToObject)
            end
        end

        if inputStallTimerButton == 0 then
            if (controller.buttonPressed & A_BUTTON) ~= 0 and not optionTable[currOption].optionBeingSet and (optionTable[currOption].lock == nil or optionTable[currOption].lock() == nil) then
                optionTable[currOption].toggle = optionTable[currOption].toggle + 1
                if optionTable[currOption].toggle > optionTable[currOption].toggleMax then optionTable[currOption].toggle = 0 end
                if optionTable[currOption].toggleSaveName ~= nil then
                    mod_storage_save(optionTable[currOption].toggleSaveName, tostring(optionTable[currOption].toggle))
                end
                inputStallTimerButton = inputStallToButton
                play_sound(SOUND_MENU_CHANGE_SELECT, cameraToObject)
            end
            if (controller.buttonPressed & B_BUTTON) ~= 0 then
                options = false
                inputStallTimerButton = inputStallToButton
            end
        end
        if currOption > #optionTable then currOption = 1 end
        if currOption < 1 then currOption = #optionTable end
        nullify_inputs(m)
    end

    if creditsAndTransition then
        if (controller.buttonDown & U_JPAD) ~= 0 then
            creditScroll = creditScroll - 1.5
        elseif (controller.buttonDown & D_JPAD) ~= 0 then
            creditScroll = creditScroll + 1.5
        elseif math.abs(controller.stickY) > 30 then
            creditScroll = creditScroll + controller.stickY*-0.03
        end

        if inputStallTimerButton == 0 then
            if (controller.buttonPressed & A_BUTTON) ~= 0 or (controller.buttonPressed & B_BUTTON) ~= 0 or (controller.buttonPressed & START_BUTTON) ~= 0 then
                credits = false
            end
        end
        nullify_inputs(m)
        if creditScroll < 0 then creditScroll = 0 end
        if creditScroll > creditScrollRange then creditScroll = creditScrollRange end
    else
        creditScroll = 0
    end

end

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

--------------
-- Commands --
--------------

promptedAreYouSure = false

local function chat_command(msg)
    msg = string_lower(msg)

    -- Open Menu Check
    if (msg == "" or msg == "menu") then
        if menu_is_allowed(gMarioStates[0]) then
            menu = not menu
            return true
        else
            djui_chat_message_create(TEXT_PAUSE_UNAVAILABLE)
            return true
        end
    end

    -- Help Prompt Check
    if msg == "?" or msg == "help" then
        djui_chat_message_create("Character Select's Avalible Commands:" ..
        "\n\\#ffff33\\/char-select help\\#ffffff\\ - Returns Avalible Commands" ..
        "\n\\#ffff33\\/char-select menu\\#ffffff\\ - Opens the Menu" ..
        "\n\\#ffff33\\/char-select [name/num]\\#ffffff\\ - Switches to Character" ..
        "\n\\#ff3333\\/char-select reset\\#ffffff\\ - Resets your Save Data")
        return true
    end

    -- Reset Save Data Check
    if msg == "reset" or (msg == "confirm" and promptedAreYouSure) then
        reset_options(true)
        return true
    end

    -- Stop Character checks if API disallows it 
    if not menu_is_allowed() or charBeingSet then
        djui_chat_message_create("Character Cannot be Changed")
        return true
    end

    -- Name Check
    for i = 0, #characterTable do
        if not characterTable[i].locked then
            local saveName = string_underscore_to_space(string_lower(characterTable[i].saveName))
            for a = 1, #characterTable[i] do
                if msg == string_lower(characterTable[i][a].name) or msg == saveName then
                    force_set_character(i)
                    if msg ~= saveName then
                        characterTable[i].currAlt = a
                    end
                    djui_chat_message_create('Character set to "' .. characterTable[i][characterTable[i].currAlt].name .. '" Successfully!')
                    return true
                end
            end
        end
    end

    -- Number Check
    msgSplit = string_split(msg)
    if tonumber(msgSplit[1]) then
        local charNum = tonumber(msgSplit[1])
        local altNum = tonumber(msgSplit[2])
        altNum = altNum and altNum or 1
        if charNum > 0 and charNum <= #characterTable and not characterTable[charNum].locked then
            currChar = charNum
            characterTable[charNum].currAlt = altNum
            djui_chat_message_create('Character set to "' .. characterTable[charNum][altNum].name .. '" Successfully!')
            return true
        end
    end
    djui_chat_message_create("Character Not Found")
    return true
end

hook_chat_command("char-select", "- Opens the Character Select Menu", chat_command)

--[[
local function mod_menu_open_cs()
    local m = gMarioStates[0]
    if menu_is_allowed(m) then
        gMarioStates[0].controller.buttonPressed = START_BUTTON
        menu = true
    else
        play_sound(SOUND_MENU_CAMERA_BUZZ, m.pos)
    end
end
hook_mod_menu_button("Open Menu", mod_menu_open_cs)
]]
