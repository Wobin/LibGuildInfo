local MAJOR, MINOR = "LibGuildInfo-1.0", 1
local LibGuildInfo, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibGuildInfo then return end	--the same or newer version of this lib is already loaded into memory 

local Classes = {[1] = "Dragon Knight", [2]="Sorcerer", [3]="Nightblade", [6]="Templar"}
local Alliances = {[1] = "Aldmeri Dominion", [2] = "Ebonhart Pact", [3] = "Daggerfall Convenant"}
-- API --

-- If the table for the name is empty, that means the member has left the guild (thus the 'next' usage)
-- All future API should funnel through this function, or be aware of the limitations
function LibGuildInfo:GetGuildMemberByMemberName(name)
	local member = name:find("@") and self.DisplayNames[name:lower()] or self.CharacterNames[name:lower()]
	if member and next(member) then return member end
end

function LibGuildInfo:GetClassNumByMemberName(name)
	local member = self:GetGuildMemberByMemberName(name)
	if member then return member.class end
end

function LibGuildInfo:GetClassNameByMemberName(name)
	local classNum = self:GetClassNumByMemberName(name)
	if classNum and Classes[classNum] then return Classes[classNum] end
end

function LibGuildInfo:GetLevelByMemberName(name)
	local member = self:GetGuildMemberByMemberName(name)
	if member then 
		if member.level < 50 then return member.level end
		return "v" .. member.veteranRank
	end 
end

function LibGuildInfo:GetAllianceNumByMemberName(name)	
	local member = self:GetGuildMemberByMemberName(name)
	if member then return member.alliance end
end

function LibGuildInfo:GetAllianceNameByMemberName(name)
	local allianceNum = self:GetAllianceNumByMemberName(name)
	if allianceNum and Alliances[allianceNum] then return Alliances[allianceNum] end
end

function LibGuildInfo:GetGuildRankIndexByMemberName(name)
	local member = self:GetGuildMemberByMemberName(name)
	if member then return member.rankIndex end	
end	

function LibGuildInfo:GetGuildRankByMemberName(name)
	local rankIndex = self:GetGuildRankIndexByMemberName(name)
	if rankIndex == 1 then 
		return "GL"
	else
		return "R"..rankIndex
	end
end

-- Setup functions --

-- This is my deep table copy function, that bypasses previously copied tables
-- to avoid infinite loops when it comes to recursive copying. Essentially a copy
-- of the ZO_DeepCopyTable, but without the game locking

local visitedTables = {}

function LibGuildInfo:DeepTableCopy(source, subCall)
    local dest =  {}
    
    for k, v in pairs(source) do
        if type(v) == "table" and not visitedTables[v] then        	            
        	visitedTables[v] = true
            dest[k] = self:DeepTableCopy(v, true)            
        else
            dest[k] = v
        end
    end
    
    if not subCall then visitedTables = {} end

    return dest
end


function LibGuildInfo:DataLoaded()
	if self.GuildDataLoaded then return end

	self.GuildDataLoaded = true

	local currentGuildId = GUILD_ROSTER.guildId
	
	self.GuildRoster = {}

	for i=1, GetNumGuilds() do
		GUILD_ROSTER:SetGuildId(i)
		self.GuildRoster[i] = self:DeepTableCopy(GUILD_ROSTER["masterList"])	
	end

	GUILD_ROSTER:SetGuildId(currentGuildId)
	self:ProcessData()
end

function LibGuildInfo:ProcessData()
	self.DisplayNames = self.DisplayNames or {}

	ZO_ClearTable(self.DisplayNames)

	for i,roster in pairs(self.GuildRoster) do
		for i,v in pairs(roster) do
			self.DisplayNames[v.displayName:lower()] = v
		end
	end

	self.CharacterNames = self.CharacterNames or {}

	ZO_ClearTable(self.CharacterNames)

	for i, roster in pairs(self.GuildRoster) do
		for i,v in pairs(roster) do
			self.CharacterNames[v.characterName:lower()] = v
		end
	end
end

function LibGuildInfo:FindInCurrentRoster(name)
	for i,v in pairs(GUILD_ROSTER["masterList"]) do
		if name:find("@") and v.displayName:lower() == name:lower() or v.characterName == name:lower() then
			return v
		end
	end
end

function LibGuildInfo:OnGuildMemberAdded(guildId, displayName)
	if not self.GuildDataLoaded then return end
	local currentGuildId = GUILD_ROSTER.guildId
	
	GUILD_ROSTER:SetGuildId(guildId)
	local v = self:DeepTableCopy(self:FindInCurrentRoster(displayName))
	table.insert(self.GuildRoster[guildId], v)
	self.DisplayNames[v.displayName:lower()] = v
	self.CharacterNames[v.characterName:lower()] = v

	GUILD_ROSTER:SetGuildId(currentGuildId)
end

-- If they're removed from the guild, empty the table out
function LibGuildInfo:OnGuildMemberRemoved(guildId, displayName)	
	if not self.GuildDataLoaded then return end
	local v = self.DisplayNames[displayName:lower()]
	ZO_ClearTable(v)
end

-- We just shallow copy into the existing table so as not to lose the 
-- table references everywhere by replacing it
function LibGuildInfo:OnGuildMemberCharacterUpdated(guildId, displayName)
	if not self.GuildDataLoaded then return end
	local currentGuildId = GUILD_ROSTER.guildId
	
	GUILD_ROSTER:SetGuildId(guildId)
	local v = self:FindInCurrentRoster(displayName)
	ZO_ShallowTableCopy(v,self.DisplayNames[displayName:lower()])
	GUILD_ROSTER:SetGuildId(currentGuildId)
end

EVENT_MANAGER:RegisterForEvent("LGI_EVENT_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function() LibGuildInfo:DataLoaded() end)
EVENT_MANAGER:RegisterForEvent("LGI_EVENT_GUILD_MEMBER_ADDED", EVENT_GUILD_MEMBER_ADDED, function(_, guildId, displayName) LibGuildInfo:OnGuildMemberAdded(guildId, displayName) end)
EVENT_MANAGER:RegisterForEvent("LGI_EVENT_GUILD_MEMBER_REMOVED", EVENT_GUILD_MEMBER_REMOVED, function(_, guildId, displayName) LibGuildInfo:OnGuildMemberRemoved(guildId, displayName) end)
EVENT_MANAGER:RegisterForEvent("LGI_EVENT_GUILD_MEMBER_CHARACTER_UPDATED", EVENT_GUILD_MEMBER_CHARACTER_UPDATED,  function(_, guildId, displayName) LibGuildInfo:OnGuildMemberCharacterUpdated(guildId, displayName) end)
EVENT_MANAGER:RegisterForEvent("LGI_EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED", EVENT_GUILD_MEMBER_CHARACTER_LEVEL_CHANGED,	function(_, guildId, displayName) LibGuildInfo:OnGuildMemberCharacterUpdated(guildId, displayName) end)
EVENT_MANAGER:RegisterForEvent("LGI_EVENT_GUILD_MEMBER_CHARACTER_VETERAN_RANK_CHANGED", EVENT_GUILD_MEMBER_CHARACTER_VETERAN_RANK_CHANGED, function(_, guildId, displayName) LibGuildInfo:OnGuildMemberCharacterUpdated(guildId, displayName) end)