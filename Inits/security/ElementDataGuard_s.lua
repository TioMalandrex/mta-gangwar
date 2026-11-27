--[[
	Proteção de element data contra alterações feitas pelo cliente.

	Por padrão o MTA sincroniza para o servidor as alterações de element data
	feitas por scripts client-side, ou seja, um cheat pode chamar
	setElementData(localPlayer, "bank_balance", 999999999) e o servidor aceita.
	Aqui revertemos qualquer alteração vinda de um cliente nas chaves que o
	gamemode usa para dinheiro, contas, gangues e territórios.

	Chaves que os scripts client-side alteram legitimamente (ex.: "afk",
	"chatting", "fps", "neon") NÃO estão na lista e continuam funcionando.

	Ref.: https://wiki.multitheftauto.com/wiki/Script_security
	Alternativa no servidor: opção elementdata_whitelisted do mtaserver.conf.
]]

local PROTECTED_KEYS = {
	-- Conta / jogador
	["account"] = true,
	["bank_balance"] = true,
	["money"] = true,
	["kills"] = true,
	["deaths"] = true,
	["ratio"] = true,
	["vip"] = true,
	["vip_account"] = true,
	["ID"] = true,
	-- Gangue
	["gang"] = true,
	["Level"] = true,
	["gang.tag"] = true,
	["convite-data"] = true,
	["xp"] = true,
	["tag"] = true,
	["slogan"] = true,
	-- Territórios
	["turf_domination"] = true,
	["state"] = true,
	["isAttacking"] = true,
	["owner"] = true,
	["currentTime"] = true,
	["maximumTime"] = true,
	-- [extras]/comandos (duelo, recompensa, eventos, loteria)
	["duelo"] = true,
	["duelo_stats"] = true,
	["HITMAN"] = true,
	["StatsEv"] = true,
	["LOTO"] = true,
}

addEventHandler("onElementDataChange", root,
function(key, oldValue)
	-- `client` só existe quando a alteração veio de um jogador.
	if not client or not PROTECTED_KEYS[key] then
		return
	end

	if oldValue == nil then
		removeElementData(source, key)
	else
		setElementData(source, key, oldValue)
	end

	outputServerLog(string.format("[SECURITY] %s (%s) tentou alterar element data '%s'",
		getPlayerName(client), getPlayerSerial(client), tostring(key)))
end)
