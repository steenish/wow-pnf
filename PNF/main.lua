-- Indicator of whether player just entered the world and did not /reload.
local enteredWorldNoReload = false

-- Create frame just to catch the login PLAYER_ENTERING_WORLD event.
local SetupFrame = CreateFrame("frame", "SetupFrame")
SetupFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- When the event is caught, set the indicator appropriately.
SetupFrame:SetScript("OnEvent", function(self, event, isInitialLogin, isReloadingUi)
    enteredWorldNoReload = not isReloadingUi
end)

-- Function to create the string that appears in the dialog box.
local function CreateReminderString(findMinerals, findHerbs)
    -- The default string.
    local returnString = "Don't forgetti your professi now!"

    -- Depending on the arguments, concatenate different things to the return string.
    if findMinerals and findHerbs then
        returnString = returnString .. "\n\nCast either Find Herbs or Find Minerals!"
    elseif findMinerals then
        returnString = returnString .. "\n\nCast Find Minerals!"
    elseif findHerbs then
        returnString = returnString .. "\n\nCast Find Herbs!"
    end

    return returnString
end

local function DisplayMessage()
    local findMinerals = false
    local findHerbs = false

    -- Search through the spell book up to index 10000 (to be safe) and look for the profession spells.
    for i = 1, 1000 do
        spellName, spellSubName = GetSpellBookItemName(i, "BOOKTYPE_SPELL")
        
        if spellName == "Find Herbs" then
            findHerbs = true
        elseif spellName == "Find Minerals" then
            findMinerals = true
        end
    end

    if findMinerals or findHerbs then
        message(CreateReminderString(findMinerals, findHerbs))
    end
end

-- Create the frame that will catch the relevant events.
local EventFrame = CreateFrame("frame", "EventFrame")

-- Relevant events:
-- PLAYER_ALIVE --> e.g reincarnation or ress before release
                --> release to graveyard
                --> load into zone
-- PLAYER_UNGHOST --> the player goes from being a ghost to not being a ghost
EventFrame:RegisterEvent("PLAYER_UNGHOST")
EventFrame:RegisterEvent("PLAYER_ALIVE")

EventFrame:SetScript("OnEvent", function(self, event, ...)
    -- If the PLAYER_ALIVE event fires but the player is currently dead, the player has just released to graveyard.
    local playerReleased = event == "PLAYER_ALIVE" and UnitIsDeadOrGhost("player")

    -- Only display message if the player has unghosted or has been ressed before releasing.
    if not playerReleased and not enteredWorldNoReload then
        DisplayMessage()
    end

    -- The first firing of the PLAYER_ALIVE event is ignored if PLAYER_ENTERING_WORLD fired without /reload.
    enteredWorldNoReload = false
end)