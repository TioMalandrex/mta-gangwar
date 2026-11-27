-- Catálogo oficial da loja. Os preços e armas são definidos SOMENTE aqui no
-- servidor; o cliente envia apenas o nome do item (valores enviados pelo
-- cliente podem ser falsificados). Mantenha em sincronia com
-- client/Ammunation.lua (static.items).
local AMMU_ITEMS = {
	["9mm"]            = { weapon = 22, price = 240 },
	["Silenced 9mm"]   = { weapon = 23, price = 720 },
	["Desert Eagle"]   = { weapon = 24, price = 1440 },
	["Tec-9"]          = { weapon = 32, price = 360 },
	["Micro Uzi"]      = { weapon = 28, price = 600 },
	["MP5"]            = { weapon = 29, price = 2400 },
	["Shotgun"]        = { weapon = 25, price = 720 },
	["Sawnoff"]        = { weapon = 26, price = 960 },
	["Combat Shotgun"] = { weapon = 27, price = 1200 },
	["AK47"]           = { weapon = 30, price = 4200 },
	["M4"]             = { weapon = 31, price = 5400 },
	["Rifle"]          = { weapon = 33, price = 1200 },
	["Sniper Rifle"]   = { weapon = 34, price = 6000 },
	["Armor"]          = { armor = true, price = 240 },
}

addEvent("onPlayerBuyAmmuItem",true)
addEventHandler("onPlayerBuyAmmuItem",root,
function(itemName)
	-- Os outros parâmetros (weaponid, price) enviados pelo cliente são ignorados.
	if not isElement(client) or type(itemName) ~= "string" then return end
	local item = AMMU_ITEMS[itemName]
	if not item then return end

	if (getPlayerMoney(client) >= item.price) then
		playSoundFrontEnd(client, 11)
		takePlayerMoney(client, item.price)
		if item.armor then
			setPedArmor(client, 100)
		else
			giveWeapon(client, item.weapon, 25)
		end
		outputChatBox("#FF6464[AMMUNATION]#00FF00 Você comprou "..itemName, client, 0, 255, 0, true)
	else
		playSoundFrontEnd(client, 1)
		outputChatBox("#FF6464[AMMUNATION]#00FF00 Dinheiro insuficiente", client, 255, 0, 0, true)
	end
end)

local blipPosition = {
	{2159.54077, 943.18250, 10.82031},
	{2539.54297, 2084.05005, 10.82031},
	{776.72345, 1871.40454, 4.90660},
	{-316.16156, 829.97339, 14.24219},
	{-1508.77307, 2610.69629, 55.83594},
	{-2625.92676, 208.23489, 4.81250},
	{-2093.64087, -2464.96045, 30.62500},
	{243.29506, -178.36353, 1.58216},
	{2333.08838, 61.54024, 26.70579},
	{1369.00000, -1279.67737, 13.54688},
	{2400.43774, -1981.99609, 13.54688}
}

addEventHandler("onResourceStart", resourceRoot, function()
	for i, v in pairs (blipPosition) do
		local blip = createBlip(v[1], v[2], v[3], 6)
		setBlipVisibleDistance(blip, 500)
	end
end)