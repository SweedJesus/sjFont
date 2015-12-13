
sjFont = AceLibrary("AceAddon-2.0"):new(
"AceConsole-2.0",
"AceDebug-2.0",
"AceDB-2.0",
"AceEvent-2.0")

local ADDON_PATH = "Interface\\AddOns\\sjFont\\"
local FONT_PATH = ADDON_PATH.."media\\font\\"

-- My fonts
local FONTS = {
    -- Font name, Default size
    "Enigmatic",
    "Gentium",
    "LiberationSans",
    "MetalLord",
    "MyriadCondensed",
    "VeraSerif"
}
local FONT_USAGE = "{ [1]:Default"
for i,v in FONTS do
    FONT_USAGE = FONT_USAGE..format(" | [%s]:%s", i+1, v)
end
FONT_USAGE = FONT_USAGE.." }"

-- Font objects
local FRIZQT = "Fonts\\FRIZQT__.TTF"
local ARIALN = "Fonts\\ARIALN.TTF"
local MORPHE = "Fonts\\MORPHEUS.TTF"
local SKURRI = "Fonts\\skurri.ttf"
local SYSTEM_FONTS = {
    -- Font object, Default size
    { SystemFont, FRIZQT, 15 },
    { GameFontNormal, FRIZQT, 12 },
    { GameFontHighlight, FRIZQT, 12 },
    { GameFontGreen, FRIZQT, 12 },
    { GameFontRed, FRIZQT, 12 },
    { GameFontBlack, FRIZQT, 12 },
    { GameFontWhite, FRIZQT, 12 },
    { GameFontDisable, FRIZQT, 12 },
    { GameFontNormalSmall, FRIZQT, 10 },
    { GameFontHighlightSmall, FRIZQT, 10 },
    { GameFontDisableSmall, FRIZQT, 10 },
    { GameFontDarkGraySmall, FRIZQT, 10 },
    { GameFontGreenSmall, FRIZQT, 10 },
    { GameFontRedSmall, FRIZQT, 10 },
    { GameFontHighlightSmallOutline, FRIZQT, 10 },
    { GameFontNormalLarge, FRIZQT, 16 },
    { GameFontHighlightLarge, FRIZQT, 16 },
    { GameFontDisableLarge, FRIZQT, 16 },
    { GameFontGreenLarge, FRIZQT, 16 },
    { GameFontRedLarge, FRIZQT, 16 },
    { ChatFrameEditBoxHeader, ARIALN, 14 },
    { ChatFrameEditBox, ARIALN, 14 },
    { ChatFontNormal, ARIALN, 14 },
    { NumberFontNormal, ARIALN, 14, "OUTLINE" },
    { NumberFontNormalYellow, ARIALN, 14, "OUTLINE" },
    { NumberFontNormalSmall, ARIALN, 12, "OUTLINE" },
    { NumberFontNormalSmallGray, ARIALN, 12, "OUTLINE" },
    { NumberFontNormalLarge, ARIALN, 16, "OUTLINE" },
    { NumberFontNormalHuge, SKURRI, 30, "OUTLINE" },
    { QuestTitleFont, MORPHE, 18 },
    { QuestFont, FRIZQT, 13 },
    { QuestFontNormalSmall, FRIZQT, 12 },
    { QuestFontHighlight, FRIZQT, 14 },
    { ItemTextFontNormal, MORPHE, 15 },
    { SubSpellFont, FRIZQT, 10 },
    { DialogButtonNormalText, FRIZQT, 16 },
    { DialogButtonHighlightText, FRIZQT, 16 },
    { ZoneTextFont, FRIZQT, 102, "THICKOUTLINE" },
    { SubZoneTextFont, FRIZQT, 26, "THICKOUTLINE" },
    { ErrorFont, FRIZQT, 16 },
    { TextStatusBarText, ARIALN, 14, "OUTLINE" },
    { TextStatusBarTextSmall, ARIALN, 12, "OUTLINE", "MONOCHROME" },
    { CombatLogFont, FRIZQT, 12 },
    { GameTooltipText, FRIZQT, 12 },
    { GameTooltipTextSmall, FRIZQT, 10 },
    { GameTooltipHeaderText, FRIZQT, 14 },
    { WorldMapTextFont, FRIZQT, 102, "THICKOUTLINE" },
    { MailTextFontNormal, MORPHE, 15 },
    { InvoiceTextFontNormal, FRIZQT, 12 },
    { InvoiceTextFontSmall, FRIZQT, 10 }
}

function sjFont.OnInitialize()
    sjFont.fonts = FONTS
    sjFont.font_names = FONT_NAMES
    sjFont.system_fonts = SYSTEM_FONTS

    -- Chat command
    sjFont:RegisterChatCommand({ "/sjFont", "/sjf" }, {
        type = "group",
        args = {
            update = {
                name = "Update Fonts",
                desc = "Update system fonts",
                type = "execute",
                func = sjFont.UpdateSystemFonts
            },
            font = {
                name = "Font",
                desc = "Set the font",
                type = "text",
                get = function()
                    return sjFont.opt.font
                end,
                set = function(set)
                    if set == "1" then
                        sjFont.opt.font = "Default"
                    else
                        set = tonumber(set)-1
                        sjFont:Debug("Selected font \"%s%s\"",FONT_PATH,FONTS[set])
                        sjFont.opt.font = FONTS[set]
                    end
                    sjFont.UpdateSystemFonts()
                end,
                validate = function(set)
                    set = tonumber(set)
                    local valid = set and set >= 1 and set <= getn(FONTS)+1
                    return valid
                end,
                usage = FONT_USAGE
            },
            scale = {
                name = "Font scale",
                desc = "Set the font scale",
                type = "range",
                get = function()
                    return sjFont.opt.font_scale
                end,
                set = function(set)
                    sjFont.opt.font_scale = set
                    sjFont.UpdateSystemFonts()
                end,
                min = 0,
                max = 3,
                step = 0.01,
                bigStep = 0.1,
                isPercent = true
            },
            debug = {
                name = "Debug",
                desc = "Toggle AceDebug",
                type = "toggle",
                get = function()
                    return sjFont.opt.debug
                end,
                set = function(set)
                    sjFont.opt.debug = set
                    sjFont:SetDebugging(set)
                end
            }
        }
    })

    -- Saved variables
    sjFont:RegisterDB("sjFont_DB")
    sjFont:RegisterDefaults("profile", {
        debug = true,
        font = "MyriadCondensed",
        font_scale = 1
    })
    sjFont.opt = sjFont.db.profile

    sjFont:SetDebugging(sjFont.opt.debug)
end

function sjFont.OnEnable()
    CHAT_FONT_HEIGHTS = {
        4, 5, 6, 7, 8, 9, 10, 11,
        12, 13, 14, 15, 16, 17, 18,
        19, 20, 21, 22, 23, 24, 28, 32
    }

    sjFont.UpdateSystemFonts()
end

function sjFont.OnEvent()
end

function sjFont.OnUpdate()
end

function sjFont.UpdateSystemFonts()
    for i,v in SYSTEM_FONTS do
        local font_obj, default_font, size, outline, monochrome = unpack(v)
        local font = sjFont.opt.font == "Default" and default_font or FONT_PATH..sjFont.opt.font..".ttf"
        font_obj:SetFont(font, size * sjFont.opt.font_scale, outline, monochrome)
    end
end
