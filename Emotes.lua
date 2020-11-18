RPE_Settings = {
	truncate = false
}
local dealerHand  = 0
local dealerTbl = {}
local colour = {"Hearts", "Spades", "Clubs", "Diamonds"}
local cards = {"Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Jack", "Queen", "King"}
local numbers = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen"}
local deck = {}
local shuffledDeck = {}
local tarot = {"The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit", "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World"}
local eightballtable = {"It is certain","It is decidedly so","Without a doubt","Yes definitely","You may rely on it","As I see it, yes","Most likely","Outlook good","Signs point to yes","Reply hazy try again","Ask again later","Better not tell you now","Cannot predict now","Concentrate and ask again","Don't count on it","My reply is no","My sources say no","Outlook not so good","Very doubtful"}
local CurrentCard = 0
local CurrentTarot = 0
local user = UnitName("player")
local gender = UnitSex("player")
local target = nil
local totalDecks = 1
local blackjackPlayers = {}
local spinList = {}
local pronouns = {{},
	{"His","his","He","he","Man","man"},
	{"Her","her","She","she","Woman","woman"}
}
local blackjackValues = {
	Ace = 1,
	Two = 2,
	Three = 3,
	Four = 4,
	Five = 5,
	Six = 6,
	Seven = 7,
	Eight = 8,
	Nine = 9,
	Ten = 10,
	Jack = 10,
	Queen = 10,
	King = 10,
}
local sipEmotes = {
	"takes a sip of %s %s.",
	"sips %s %s.",
	"takes a slow sip of %s %s.",
	"raises her cup to sip some of %s %s.",
	"sips a little of %s %s, savouring the taste before swallowing.",
	"raises %s %s to %s lips, inhaling deeply before deciding to take a sip."
}
local swigEmotes = {
	"takes a swig of %s %s.",
	"swigs %s %s.",
	"takes a slow swig of %s %s.",
	"raises her bottle to swig some of %s %s.",
}
local ClassColourTable = {
	DEATHKNIGHT = "FFC41F3B",
	DEMONHUNTER = "FFA330C9",
	DRUID = "FFFF7D0A",
	HUNTER = "FFABD473",
	MAGE = "FF69CCF0",
	MONK = "FF00FF96",
	PALADIN = "FFF58CBA",
	PRIEST = "FFFFFFFF",
	ROGUE = "FFFFF569",
	SHAMAN = "FF0070DE",
	WARLOCK = "FF9482C9",
	WARRIOR = "FFC79C6E"
}
local Backdrop = {
        bgFile = "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated",  -- path to the background texture
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",  -- path to the border texture
        tile = false,    -- true to repeat the background texture to fill the frame, false to scale it
        tileSize = 32,  -- size (width or height) of the square repeating background tiles (in pixels)
        edgeSize = 32,  -- thickness of edge segments and square size of edge corners (in pixels)
        insets = {    -- distance from the edges of the frame to those of the background texture (in pixels)
            left = 11,
            right = 11,
            top = 11,  --12
            bottom = 10
        }
    }
local helpTable = {
	"/8ball [Question] - This asks the magic 8ball, shakes it and then gives you a randomly selected response.",
	"/draw [Number] - Draws a number of cards specified from a 52 Deck of Cards. If the will automatically shuffle the deck if needed.",
	"/shuffle [Number] - Shuffles the Deck of Cards, use if you want to reset the deck before it's empty. Number specifies the number of decks to use between 1-6.",
	"/check [S] - Checks how many cards remain in the current deck without drawing any. If S is supplied player will be ouput to the user only.",
	"/tdraw [Number] - Draws a number of cards specified from the Tarot Deck. If the will automatically shuffle the deck if needed.",
	"/tshuffle [S] - Shuffles the Tarot Deck, use if you want to reset the deck before it's empty.",
	"/tcheck - Checks how many cards remain in the tarot deck without drawing any. If S is supplied player will be ouput to the user only.",
	"/spin [S] - Spins a bottle for the players listed. If no list exists then one is generated from your present group/raid (excluding offline players). If S is supplied player will be ouput to the user only.",
	"/spinlist - Used for the above spin command. Use to display more options.",
	"Blackjack - Use /deal and /hit to deal out cards to the targetted player. Deal provides two cards, Hit provides one. Use /shuffle to re-shuffle your deck.",
	"Using /Blackjack will now open up a Blackjack Dealer UI.",
	"/rpe truncate - Will remove the excess text from cards. Suggested mode for playing blackjack as cards will show as (Ace) rather than (Ace of Diamonds).",
	"/rpe Emotes - Will list all the custom emotes available."
}
local emoteTable = {
	"flip - Flips a coin in the air and displays the result.",
	"snod/smilenod - You smile and nod your head.",
	"smug/smuggrin - You flash a smug grin.",
	"squint - You squint your eyes.",
	"sip [Drink] - You take a sip of a drink. (Your drink of choice can be specified such as /sip tea. Presumes Cup.)",
	"swig [Drink] - You take a swig of a drink. (Your drink of choice can be specified such as /swip rum. Presumes Bottle.)",
	"shakehead/shakeh - You shake your head.",
	"wag - You wag your eyebrows.",
	"watch - You pull out your watch to check the time.",
}

local spinListHelp = {
	"/spinlist add [players] to add players to the list.",
	"/spinlist del [players] to delete players from the list.",
	"/spinlist clear to clear the list.",
	"/spinlist players to display the current list."
}

local function getArticle(card)
	if card == "Ace" or card == "Eight" then
		return "An"
	else
		return "A"
	end
end

local function getGroup(members)
	--local SubGroups = math.ceil(members/5)
	local GroupSize = GetNumGroupMembers()
	local Group = {}
	local CurrMember = 0
	local VMem = 0
	for i = 1,GroupSize do
		local name, rank, subgroup, level, class, fileName, zone, online = GetRaidRosterInfo(i)
		if online then
			VMem = VMem + 1
			Group[VMem] = name
		end
	end
	return Group	
end

local function emoteFormat(emote,...)
	local str = ""
	local f,s,t,fo,fi,si,se = ...
	str = string.format(emote,f,s,t,fo,fi,si,se)
	return str
end

local function tableFind(tbl,val)
	for i, v in pairs(tbl) do
		if v == val then
			return i
		end
	end
end

local function playerListAdd(msg,list)
	for name in string.gmatch(msg, "%a+") do
		if name ~= "add" then table.insert(list,name) end
	end	
end

local function playerListDel(msg,list)
	for name in string.gmatch(msg, "%a+") do
		if name ~= "del" then table.remove(list, tableFind(list,name) ) end
	end	
end

local function getRandomPlayer(i, Party)
	local Player = ""
	if #Party <= 1 then 
		return nil
	end
	if i == 1 then
		while true do
			Player = Party[math.random(#Party)]
			if Player ~= user then
				return Player
			end
		end
	elseif i == 2 then
		Player = Party[math.random(#Party)]
		return Player
	end
end

local function cardPattern()
	if RPE_Settings["truncate"] then
		return "%a+"
	else
		return "%a+ %a+ %a+"
	end
end

local function cardInsert(tbl, player, class, cards, deal)
	if deal or not tbl[player] then tbl[player] = {} end
	if class then tbl[player]["color"] = ClassColourTable[class] end
	for i, v in ipairs(cards) do
		local card = string.match(cards[i],"%a+")
		table.insert(tbl[player],card)
	end
end

local function cardValues(tbl)
	local total = 0
	local values = {}
	for i = 1, #tbl do	
		table.insert(values,blackjackValues[tbl[i]])	
	end
	table.sort(values, function(a,b) return a>b end)
	for i = 1, #values do
		total = total + values[i]
		if total < 12 and values[i] == 1 then total = total + 10 end
	end
	return total
end

local function eightball(question)
	local fortune = math.random(#eightballtable)
	local output = ""
	if question ~= "" then
		output = string.format("reaches into %s pocket and lifts out a magic 8-Ball. %s quietly asks %q and then shakes it. The 8-Ball answers %q.",pronouns[gender][2],pronouns[gender][3],question,eightballtable[fortune])
	else
		output = string.format("shakes %s magic 8-Ball and looks at the response. It reads %q.",pronouns[gender][2],eightballtable[fortune])
	end
	SendChatMessage(output,"EMOTE")
end

local function shuffle(tbl)
	for i = 1, 10 do
	  for i = #tbl, 2, -1 do
		local rand = math.random(i)
		tbl[i], tbl[rand] = tbl[rand], tbl[i]
	  end
	end
	  return tbl
end

local function newshuffle(array)
    -- fisher-yates
    local output = { }
    local random = math.random

    for index = 1, #array do
        local offset = index - 1
        local value = array[index]
        local randomIndex = offset*random()
        local flooredIndex = randomIndex - randomIndex%1

        if flooredIndex == offset then
            output[#output + 1] = value
        else
            output[#output + 1] = output[flooredIndex + 1]
            output[flooredIndex + 1] = value
        end
    end

    return output
end

local function shuffledeck(msg)
	local output = ""
	local decks = tonumber(msg) or 1
	local cardStr = ""
	deck = {}
	if decks > 6 then 
		decks = 6
		SELECTED_CHAT_FRAME:AddMessage("Deck value provied was greater than 6. It's now 6.")
	end
	for i = 1,decks do
		for i=1,52 do
			local mod = (i % 4) + 1
			local num = math.ceil(i/4)
			local str = string.format("%s of %s",cards[num],colour[mod])
			table.insert(deck,str)
		end
	end
	shuffledDeck = newshuffle(deck)
	CurrentCard = #deck
	PlaySound(53186)
	if decks == 1 then 
		output = "picks up a deck of cards and shuffles it."
	else 
		output = string.format("picks up %s decks of cards and shuffles them together.",numbers[decks])
	end
	SendChatMessage(output, "EMOTE")
end

local function drawcard(msg)
	local num = tonumber(msg)
	local drawncards = ""
	local drawn = {}
	local plu = ""
	if not num then
		num = 1
	elseif num > CurrentCard then
		num = CurrentCard
	end
	for i=1,num do
		drawn[i] = string.match(shuffledDeck[CurrentCard],cardPattern())
		CurrentCard = CurrentCard - 1
	end
	local localizedClass, englishClass = UnitClass("player")
	cardInsert(blackjackPlayers,user,englishClass,drawn,false)
	local firstArticle = getArticle(drawn[1])
	drawncards = table.concat(drawn, ", ")
	if num == 1 then plu = "one card" elseif num > #numbers then plu = "a lot of cards" else plu = numbers[num].." cards" end
	local output = string.format("draws %s from %s deck: %s %s.",plu,pronouns[gender][2],firstArticle,drawncards)
	SendChatMessage(output,"EMOTE")
	return drawncards
end

local function blackjackDeal()
	local drawn = {}
	local output = ""
	local target = UnitName("target")
	local localizedClass, englishClass = UnitClass("target")
	for i = 1 , 2 do
		drawn[i] = string.match(shuffledDeck[CurrentCard],cardPattern())
		CurrentCard = CurrentCard - 1
	end
	local firstArticle = string.lower(getArticle(drawn[1]))
	local secondArticle = string.lower(getArticle(drawn[2]))
	if target and target ~= user then
		cardInsert(blackjackPlayers,target,englishClass,drawn,true)
		local total = cardValues(blackjackPlayers[target])
		output = string.format("draws two cards and passes them over to %s. The cards being %s %s and %s %s. (%d)",target,firstArticle,drawn[1],secondArticle,drawn[2],total)
	else
		output = string.format("draws two cards and passes them over. The cards being %s %s and %s %s.",firstArticle,drawn[1],secondArticle,drawn[2])
	end
	SendChatMessage(output,"EMOTE")
end

local function blackjackHit()
	local drawn = {}
	local output = ""
	local target = UnitName("target")
	drawn[1] = string.match(shuffledDeck[CurrentCard],cardPattern())
	CurrentCard = CurrentCard - 1
	local firstArticle = string.lower(getArticle(drawn[1]))
	if target and target ~= user then
		cardInsert(blackjackPlayers,target,nil,drawn,false)
		local total = cardValues(blackjackPlayers[target])
		output = string.format("draws a single card and passes it over to %s. It's %s %s. (%d)",target,firstArticle,drawn[1],total)
	else
		output = string.format("draws a single card and passes it over. It's %s %s.",firstArticle,drawn[1])
	end
	SendChatMessage(output,"EMOTE")
end

local function blackjackCardCheck()
	for i, v in pairs(blackjackPlayers) do
		local total = cardValues(blackjackPlayers[i])
		local cards = table.concat(blackjackPlayers[i],", ")
		local playerColor = blackjackPlayers[i]["color"] or "FFFFFFFF"
		local valueColor = "FFFFFC00"
		if total > 21 then
			valueColor = "FFC40000"
		elseif total <= 21 and total > 18 then
			valueColor = "FF1CC400"
		elseif total <= 18 and total > 11 then
			valueColor = "FFFFA200"
		end
		local output = string.format("|c%s%s:|r %s. |c%s(%d)|r",playerColor,i,cards,valueColor,total)
		SELECTED_CHAT_FRAME:AddMessage(output)
	end
end

local function blackjackUI()
	if blackjackBG then
		blackjackBG:Hide()
		blackjackBG = nil;
	else
		blackjackBG = CreateFrame("Frame","blackjackBG",UIParent,'BackdropTemplate')
		tinsert(UISpecialFrames,"blackjackBG")
		blackjackBG:SetFrameStrata("MEDIUM")
		blackjackBG:ClearAllPoints()
		blackjackBG:SetBackdrop(Backdrop)
		blackjackBG:SetHeight(150)
		blackjackBG:SetWidth(184)
		blackjackBG:SetPoint("CENTER",UIParent,"CENTER",0,0)
		blackjackBG:SetScript("OnHide", function() blackjackBG = nil end)
		blackjackBG:SetMovable(true)
		blackjackBG:EnableMouse(true)
		blackjackBG:RegisterForDrag("LeftButton")
		blackjackBG:SetScript("OnDragStart", blackjackBG.StartMoving)
		blackjackBG:SetScript("OnDragStop", blackjackBG.StopMovingOrSizing)
		--blackjackBG:SetScript("OnUpdate", function() RPE_Settings.blackjackBGx, RPE_Settings.blackjackBGy = blackjackBG:GetCenter() end)
		
		blackjackDealBtn = CreateFrame("Button","blackjackDealBtn",blackjackBG,"UIPanelCloseButton")
		blackjackDealBtn:SetPoint("TOPRIGHT",blackjackBG,"TOPRIGHT",5,5)
		blackjackDealBtn:SetWidth(30)
		blackjackDealBtn:SetHeight(30)
		blackjackDealBtn:SetText("Deal")
		blackjackDealBtn:SetAlpha(0.95)
		blackjackDealBtn:SetScript("OnClick",function()
			blackjackBG:Hide()
			blackjackBG = nil;
		end)
		
		blackjackTxt = blackjackBG:CreateFontString(nil, "High", "GameTooltipText")
		blackjackTxt:SetPoint("TOP","blackjackBG",0,-15)
		blackjackTxt:SetText("|cffff0000Blackjack Dealer|r")
		blackjackTxt:SetFont("Fonts\\MORPHEUS.ttf", 15, "OUTLINE")
		
		deckTxt = blackjackBG:CreateFontString(nil, "High", "GameTooltipText")
		deckTxt:SetPoint("TOP","blackjackBG",0,-33)
		deckTxt:SetText("Cards Remaining: "..CurrentCard)
		deckTxt:SetFont("Fonts\\FRIZQT__.ttf", 12)

		dealerTxt = blackjackBG:CreateFontString(nil, "High", "GameTooltipText")
		dealerTxt:SetPoint("TOP","blackjackBG",0,-48)
		dealerTxt:SetText("Your Hand: "..dealerHand)
		dealerTxt:SetFont("Fonts\\FRIZQT__.ttf", 11)
			
		blackjackDealBtn = CreateFrame("Button","blackjackDealBtn",blackjackBG,"GameMenuButtonTemplate")
		blackjackDealBtn:SetPoint("LEFT",blackjackBG,"LEFT",10,0)
		blackjackDealBtn:SetWidth(54)
		blackjackDealBtn:SetHeight(25)
		blackjackDealBtn:SetText("Deal")
		blackjackDealBtn:SetAlpha(0.95)
		blackjackDealBtn:SetScript("OnClick",function()
			if CurrentCard == 0 then shuffledeck(totalDecks) end
			blackjackDeal()
			deckTxt:SetText("Cards Remaining: "..CurrentCard)
		end)
		
		blackjackHitBtn = CreateFrame("Button","blackjackHitBtn",blackjackBG,"GameMenuButtonTemplate")
		blackjackHitBtn:SetPoint("LEFT",blackjackDealBtn,"RIGHT",0,0)
		blackjackHitBtn:SetWidth(54)
		blackjackHitBtn:SetHeight(25)
		blackjackHitBtn:SetText("Hit")
		blackjackHitBtn:SetAlpha(0.95)
		blackjackHitBtn:SetScript("OnClick",function()
			if CurrentCard > 0 then blackjackHit() end
			deckTxt:SetText("Cards Remaining: "..CurrentCard)
		end)
		
		blackjackDrawBtn = CreateFrame("Button","blackjackDrawBtn",blackjackBG,"GameMenuButtonTemplate")
		blackjackDrawBtn:SetPoint("LEFT",blackjackHitBtn,"RIGHT",0,0)
		blackjackDrawBtn:SetWidth(54)
		blackjackDrawBtn:SetHeight(25)
		blackjackDrawBtn:SetText("Draw")
		blackjackDrawBtn:SetAlpha(0.95)
		blackjackDrawBtn:SetScript("OnClick",function()
			if CurrentCard == 0 then shuffledeck(totalDecks) end
			local drawnCard = drawcard()
			table.insert(dealerTbl,drawnCard)
			dealerHand = cardValues(dealerTbl)
			dealerTxt:SetText("Dealer Hand: "..dealerHand)
			deckTxt:SetText("Cards Remaining: "..CurrentCard)
		end)

		blackjackCheckBtn = CreateFrame("Button","blackjackCheckBtn",blackjackBG,"GameMenuButtonTemplate")
		blackjackCheckBtn:SetPoint("TOPRIGHT",blackjackDrawBtn,"BOTTOMRIGHT",0,0)
		blackjackCheckBtn:SetWidth(85)
		blackjackCheckBtn:SetHeight(25)
		blackjackCheckBtn:SetText("Check Cards")
		blackjackCheckBtn:SetAlpha(0.95)
		blackjackCheckBtn:SetScript("OnClick",function()
			blackjackCardCheck()
		end)
		
		blackjackDealerClearBtn = CreateFrame("Button","blackjackDealerClearBtn",blackjackBG,"GameMenuButtonTemplate")
		blackjackDealerClearBtn:SetPoint("TOPRIGHT",blackjackCheckBtn,"TOPLEFT",0,0)
		blackjackDealerClearBtn:SetWidth(75)
		blackjackDealerClearBtn:SetHeight(25)
		blackjackDealerClearBtn:SetText("Clear Hands")
		blackjackDealerClearBtn:SetAlpha(0.95)
		blackjackDealerClearBtn:SetScript("OnClick",function()
			dealerTbl = {}
			blackjackPlayers = {}
			dealerHand = 0
			dealerTxt:SetText("Your Hand: "..dealerHand)
		end)
		
		local decksdropDown = CreateFrame("FRAME", "DecksDropdown", blackjackBG, "UIDropDownMenuTemplate")
		decksdropDown:SetPoint("TOPLEFT",blackjackDealerClearBtn,"BOTTOMLEFT",-15,1)
		UIDropDownMenu_SetWidth(decksdropDown, 70)
		UIDropDownMenu_SetText(decksdropDown, "Decks: " .. totalDecks)
		UIDropDownMenu_Initialize(decksdropDown, function(self, level, menuList)
		local info = UIDropDownMenu_CreateInfo()
			info.func = self.SetValue
			for i=1, 6 do
				info.text, info.arg1, info.checked = i, i, i == totalDecks
				UIDropDownMenu_AddButton(info, level)
			end
		end)

		function decksdropDown:SetValue(newValue)
			totalDecks = newValue
			UIDropDownMenu_SetText(decksdropDown, "Decks: " .. totalDecks)
			CloseDropDownMenus()
		end
		
		blackjackShuffleBtn = CreateFrame("Button","blackjackShuffleBtn",blackjackBG,"GameMenuButtonTemplate")
		blackjackShuffleBtn:SetPoint("TOPRIGHT",blackjackCheckBtn,"BOTTOMRIGHT",0,0)
		blackjackShuffleBtn:SetWidth(70)
		blackjackShuffleBtn:SetHeight(25)
		blackjackShuffleBtn:SetText("Shuffle")
		blackjackShuffleBtn:SetAlpha(0.95)
		blackjackShuffleBtn:SetScript("OnClick",function()
			dealerTbl = {}
			blackjackPlayers = {}
			dealerHand = 0
			dealerTxt:SetText("Your Hand: "..dealerHand)
			shuffledeck(totalDecks)
			deckTxt:SetText("Cards Remaining: "..CurrentCard)
		end)
			
	end

end

local function tarotshuffle()
	shuffle(tarot)
	CurrentTarot = #tarot
	PlaySound(53186)
	SendChatMessage("picks up "..pronouns[gender][2].." Tarot Deck and shuffles it.", "EMOTE")
end

local function tarotdraw(msg)
	local num = tonumber(msg)
	local drawncards = ""
	local drawn = {}
	local plu = ""
	if not num then
		num = 1
	elseif num > CurrentTarot then
		num = CurrentTarot
	end
	for i=1,num do
		drawn[i] = tarot[CurrentTarot]
		CurrentTarot = CurrentTarot - 1
	end
	if num > 1 then
		for i=1,#drawn do
			if i > 1 then drawncards = drawn[i] .. ", ".. drawncards
			else drawncards = drawn[i] end
		end
	else
		drawncards = drawn[1]
	end
	if num == 1 then plu = "one tarot card" elseif num > #numbers then plu = "a lot of tarot cards" else plu = numbers[num].." tarot cards" end
	SendChatMessage("draws "..plu.." from "..pronouns[gender][2].." deck: "..drawncards..".","EMOTE")
end

local function bottleSpin(msg)
	local Party = {}
	local RandomType = 1
	if #spinList > 0 then
		RandomType = 2
		Party = spinList
	else
		Party = getGroup()
	end
	local Player = getRandomPlayer(RandomType, Party)
	if Player == nil then 
		SELECTED_CHAT_FRAME:AddMessage("No players available to select.")
	else
		if msg == "s" or msg == "S" then
			SELECTED_CHAT_FRAME:AddMessage("|cFFFF7D0ASelected: |r"..Player)
		else
			SendChatMessage("reaches forwards and spins the bottle, after a few moments it stops pointing towards "..Player..".","EMOTE")
		end
	end
end

SLASH_RPEMOTES1 = '/RPE';
SLASH_RPEMOTES2 = '/RPEmotes';
function SlashCmdList.RPEMOTES(msg, editbox)
	msg:lower()
	if msg and msg == "truncate" or msg == "t" then
		if RPE_Settings["truncate"] then
			RPE_Settings["truncate"] = false
			SELECTED_CHAT_FRAME:AddMessage("Cards drawn will now show their full name. (Ace of Clubs)")
		else
			RPE_Settings["truncate"] = true
			SELECTED_CHAT_FRAME:AddMessage("Cards drawn will now only show their value. (Ace)")
		end
	elseif msg and msg == "emote" or msg == "emotes" or msg == "e" then
		for i = 1,#emoteTable do
			SELECTED_CHAT_FRAME:AddMessage("|cFFFF7D0AEmote List: |r"..emoteTable[i])
		end
	else
		for i = 1,#helpTable do
			SELECTED_CHAT_FRAME:AddMessage("|cFFFF7D0ARP Emotes: |r"..helpTable[i])
		end
	end
end

SLASH_SHUFFLE1 = '/shuffle';
function SlashCmdList.SHUFFLE(msg, editbox)
	shuffledeck(msg)
end

SLASH_DRAW1 = '/draw';
function SlashCmdList.DRAW(msg, editbox)
	if CurrentCard == 0 then shuffledeck() drawcard(msg) else drawcard(msg) end
end

SLASH_DEAL1 = '/deal';
function SlashCmdList.DEAL(msg, editbox)
	if CurrentCard == 0 then shuffledeck() blackjackDeal() else blackjackDeal() end
end

SLASH_HIT1 = '/hit';
function SlashCmdList.HIT(msg, editbox)
	blackjackHit()
end

SLASH_CARDCHECK1 = '/cardcheck';
function SlashCmdList.CARDCHECK(msg, editbox)
	blackjackCardCheck()
end

SLASH_BLACKJACK1 = '/blackjack';
function SlashCmdList.BLACKJACK(msg, editbox)
	blackjackUI()
end

SLASH_CHECK1 = '/check';
function SlashCmdList.CHECK(msg, editbox)
	if msg == "s" or msg == "S" then
		SELECTED_CHAT_FRAME:AddMessage(string.format("There are %s cards remaining in your Deck.",CurrentCard))
	else
		SendChatMessage(string.format("checks %s deck of cards. There are %s Cards remaining.",pronouns[gender][2],CurrentCard),"EMOTE")
	end
end

SLASH_BALL1 = '/8ball';
function SlashCmdList.BALL(msg, editbox)
	eightball(msg)
end

SLASH_TSHUFFLE1 = '/tarotshuffle';
SLASH_TSHUFFLE2 = '/tshuffle';
function SlashCmdList.TSHUFFLE(msg, editbox)
	tarotshuffle()
end

SLASH_TDRAW1 = '/tarotdraw';
SLASH_TDRAW2 = '/tdraw';
function SlashCmdList.TDRAW(msg, editbox)
	if CurrentTarot == 0 then tarotshuffle() tarotdraw(msg) else tarotdraw(msg) end
end

SLASH_TCHECK1 = '/tcheck';
SLASH_TCHECK2 = '/tarotcheck';
function SlashCmdList.TCHECK(msg, editbox)
	if msg == "s" or msg == "S" then
		SELECTED_CHAT_FRAME:AddMessage(string.format("There are %s cards remaining in your Tarot Deck.",CurrentTarot))
	else
		SendChatMessage(string.format("checks %s tarot deck. There are %s Tarot Cards remaining.",pronouns[gender][2],CurrentTarot),"EMOTE")
	end
end

SLASH_FLIP1 = '/flip';
function SlashCmdList.FLIP(msg, editbox)
	local num = math.random(2)
	if num == 1 then Side = "Heads" else Side = "Tails" end
	local output = string.format("flips a coin up into the air. %s catches it in %s palm, the coin showing %s.",pronouns[gender][3],pronouns[gender][2],Side)
	SendChatMessage(output, "EMOTE")
end

SLASH_SPIN1 = '/spin';
function SlashCmdList.SPIN(msg, editbox)
	bottleSpin(msg)
end

SLASH_SPINLIST1 = '/spinlist';
function SlashCmdList.SPINLIST(msg, editbox)
	local subcom = ""
	if msg ~= "" then
		subcom = string.lower(msg:match("%a+"))
	end
	local list = string.sub(msg,string.len(subcom)+2)
	if subcom:match("add") then
		playerListAdd(list,spinList)
	elseif subcom:match("del") then
		playerListDel(list,spinList)
	elseif subcom:match("clear") then
		spinList = {}
		SELECTED_CHAT_FRAME:AddMessage()
	elseif subcom:match("players") then
		if #spinList > 0 then
			SELECTED_CHAT_FRAME:AddMessage(string.format("Players in the List are %s.",table.concat(spinList,", ")))
		else
			SELECTED_CHAT_FRAME:AddMessage("No players currently in the list. Please use /spinlist add [players].")
		end
	else
		for i = 1,#spinListHelp do
			SELECTED_CHAT_FRAME:AddMessage(spinListHelp[i])
		end
	end
end

SLASH_SMILENOD1 = '/snod';
SLASH_SMILENOD2 = '/smilenod';
function SlashCmdList.SMILENOD(msg, editbox)
	local emote = "smiles and nods %s head."
	local targetEmote = "smiles at %s and then gives a nod of %s head."
	local target = UnitName("target")
	local output = ""
	if target and target ~= user then
		output = emoteFormat(targetEmote,target,pronouns[gender][2])
	else
		output = emoteFormat(emote,pronouns[gender][2])
	end
	SendChatMessage(output,"EMOTE")
end 

SLASH_WAG1 = '/wag';
function SlashCmdList.WAG(msg, editbox)
	local emote = "wags %s eyebrows suggestively."
	local targetEmote = "wags %s eyebrows suggestively at %s."
	local target = UnitName("target")
	local output = ""
	if target and target ~= user then
		output = emoteFormat(targetEmote,pronouns[gender][2],target)
	else
		output = emoteFormat(emote,pronouns[gender][2])
	end
	SendChatMessage(output,"EMOTE")
end 

SLASH_SMUG1 = '/smug';
SLASH_SMUG2 = '/smuggrin';
function SlashCmdList.SMUG(msg, editbox)
	local emote = "flashes a smug grin."
	local targetEmote = "flashes a smug grin at %s."
	local target = UnitName("target")
	local output = ""
	if target and target ~= user then
		output = emoteFormat(targetEmote,target)
	else
		output = emoteFormat(emote)
	end
	SendChatMessage(output,"EMOTE")
end 

SLASH_SQUINT1 = '/squint';
function SlashCmdList.SQUINT(msg, editbox)
	local emote = "squints and purses %s lips together suspiciously."
	local targetEmote = "squints and purses %s lips together suspiciously at %s."
	local target = UnitName("target")
	local output = ""
	if target and target ~= user then
		output = emoteFormat(targetEmote,pronouns[gender][2],target)
	else
		output = emoteFormat(emote,pronouns[gender][2])
	end
	SendChatMessage(output,"EMOTE")
end 

SLASH_SIP1 = '/sip';
function SlashCmdList.SIP(msg, editbox)
	local drink = "drink"
	local emote = sipEmotes[math.random(#sipEmotes)]
	local output = ""
	if msg ~= "" then
		drink = msg
	end
	output = emoteFormat(emote,pronouns[gender][2],drink,pronouns[gender][2])
	SendChatMessage(output,"EMOTE")
end 

SLASH_SIP1 = '/swig';
function SlashCmdList.SIP(msg, editbox)
	local drink = "drink"
	local emote = swigEmotes[math.random(#swigEmotes)]
	local output = ""
	if msg ~= "" then
		drink = msg
	end
	output = emoteFormat(emote,pronouns[gender][2],drink,pronouns[gender][2])
	SendChatMessage(output,"EMOTE")
end 

SLASH_SHAKEHEAD1 = '/shakehead';
SLASH_SHAKEHEAD2 = '/shakeh';
function SlashCmdList.SHAKEHEAD(msg, editbox)
	local emote = "shakes %s head."
	local targetEmote = "shakes %s head at %s."
	local target = UnitName("target")
	local output = ""
	if target and target ~= user then
		output = emoteFormat(targetEmote,pronouns[gender][2],target)
	else
		output = emoteFormat(emote,pronouns[gender][2])
	end
	SendChatMessage(output,"EMOTE")
end 

SLASH_WATCH1 = '/watch';
function SlashCmdList.WATCH(msg, editbox)
	local emote = "pulls out %s pocket watch and checks the time."
	local output = emoteFormat(emote,pronouns[gender][2])
	SendChatMessage(output,"EMOTE")
end 