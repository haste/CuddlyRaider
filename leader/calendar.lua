-- Bail out early if the player isn't an officer.
if(not CanEditOfficerNote()) then return end

-- Table of officers in the guild.
local officers = {}

-- The number of events we should ignore.
local blockEvents = 0

local CALENDAR_UPDATE_INVITE_LIST = function(self, event)
	-- Prevent us from doing extra parses when we hammer inn the invite status.
	if(blockEvents > 0) then
		blockEvents = blockEvents - 1
		return
	end

	-- Bail if the calendar isn't shown.
	if(not CalendarCreateEventFrame:IsShown()) then return end

	if(CalendarEventCanEdit()) then
		local num = CalendarEventGetNumInvites()
		for i=1, num do
			local name, level, className, classFilename, inviteStatus, modStatus = CalendarEventGetInvite(i)
			if(officers[name] and not (modStatus == 'MODERATOR' or modStatus == 'CREATOR')) then
				blockEvents = blockEvents + 1
				CalendarEventSetModerator(i)
			end
		end
	end
end

local GUILD_ROSTER_UPDATE = function(self, event)
	local num = GetNumGuildMembers(true)
	for i=1,num do
		local name, rank, rankIndex = GetGuildRosterInfo(i)
		if(rankIndex <= 1) then
			officers[name] = true
		end
	end
end

CuddlyRaider:RegisterEvent('CALENDAR_UPDATE_INVITE_LIST', CALENDAR_UPDATE_INVITE_LIST)
CuddlyRaider:RegisterEvent('GUILD_ROSTER_UPDATE', GUILD_ROSTER_UPDATE)
