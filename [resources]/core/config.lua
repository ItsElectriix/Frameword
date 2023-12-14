BJConfig = {}

BJConfig.MaxPlayers = GetConvarInt('sv_maxclients', 64) -- Gets max players from config file, default 32
BJConfig.IdentifierType = "steam" -- Set the identifier type (can be: steam, license)
BJConfig.DefaultSpawn = {x=122.6056,y=-211.204,z=54.55782,a=257.82}
BJConfig.UseGlobalOoc = false -- Set this if you would like OOC to broadcast to everyone. Setting to false restricts to the players close to the command issuer

BJConfig.Currency = {}
BJConfig.Currency.Symbol = '$' -- Currency symbol to use
BJConfig.Currency.HtmlSymbols = {
    ['$'] = '&dollar;',
    ['£'] = '&pound;',
    ['€'] = '&euro;',
}

BJConfig.Money = {}
BJConfig.Money.MoneyTypes = {['cash'] = 100, ['bank'] = 0, ['crypto'] = 0} -- ['type']=startamount - Add or remove money types for your server (for ex. ['blackmoney']=0), remember once added it will not be removed from the database!
BJConfig.Money.DontAllowMinus = {'cash', 'crypto', 'bank'} -- Money that is not allowed going in minus

BJConfig.Player = {}
BJConfig.Player.PhoneNumberPrefix = '06'
BJConfig.Player.MaxWeight = 120000 -- Max weight a player can carry (currently 120kg, written in grams)
BJConfig.Player.MaxInvSlots = 40 -- Max inventory slots for a player
BJConfig.Player.Bloodtypes = {
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-",
}

BJConfig.Server = {} -- General server config
BJConfig.Server.closed = GetConvar("server_type", "DEV") == "DEV" -- Set server closed (no one can join except people with ace permission 'bjadmin.join')
BJConfig.Server.closedReason = "Dev Server." -- Reason message to display when people can't join the server
BJConfig.Server.uptime = 0 -- Time the server has been up.
BJConfig.Server.whitelist = false -- Enable or disable whitelist on the server
BJConfig.Server.discord = "https://discord.gg/*" -- Discord invite link
BJConfig.Server.PermissionList = {} -- permission list

BJConfig.Server.UseDiscordAPI = false 
BJConfig.Server.DiscordAPI = {
    Guild_ID = '',
    Bot_Token = '',
    RoleList = {},  
}
BJConfig.Server.DiscordWhitelistedRole = false -- or include discord role id as a string to enable e.g "231231241234"