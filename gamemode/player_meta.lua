
MsgN("Wastemod: Player meta table modified!")

local Player = FindMetaTable("Player")
 
 /*
	SCRAP FUNCTIONS
 */
 
 --Set the player current scrap
function Player:SetScrap(amount)
	self:SetNWInt("wm_scrap",amount)
end

--Gets the player current scrap
function Player:GetScrap()
	return self:GetNWInt("wm_scrap",-1)
end

--Add scrap amount for the player
function Player:AddScrap(amount)
	self:SetScrap(self:GetScrap()+amount)
end

--Use scrap amount for the player
function Player:RemoveScrap(amount)
	self:AddScrap(-amount)
end

--Can Use scrap amount for the player?
function Player:CanPayScrap(amount)
	local canPay = self:GetScrap()-amount >= 0

	return canPay
end

 /*
	SCRAP MINER FUNCTIONS
 */
 
 --Set the player current scrap
function Player:SetScrapMiner(ent)
	self:SetNWEntity("wm_scrapminer",ent)
end

--Gets the player current scrap
function Player:GetScrapMiner()
	return self:GetNWEntity("wm_scrapminer",nil)
end
