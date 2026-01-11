CFG = Server.GetCustomSettings()
MAPS = {}
CURRENT_MAP_INDEX = 1
RTV_VOTERS = {} -- Track players who have voted

function ShuffleInPlace(t)
	for i = #t, 2, -1 do
		local j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

for _, map in pairs(CFG.rtv.maps) do
	Console.Log("Added to map rotation: " .. map)
	table.insert(MAPS, map)
end

Events.Subscribe("ChangeMap", function()
	if #MAPS == 0 then
		Console.Log("No maps in rotation!")
		return
	end

	-- Get the next map in rotation
	local next_map = MAPS[CURRENT_MAP_INDEX]

	-- Increment index and wrap around if needed
	CURRENT_MAP_INDEX = CURRENT_MAP_INDEX + 1
	if CURRENT_MAP_INDEX > #MAPS then
		CURRENT_MAP_INDEX = 1
	end

	Console.Log("Changing map to: " .. next_map)
	Server.ChangeMap(next_map)

	-- Reset RTV votes when map changes
	RTV_VOTERS = {}
end)

function RockTheVote(player)
	if not player then
		return
	end

	-- Get all players
	local allPlayers = Player.GetAll()
	local totalPlayers = #allPlayers

	if totalPlayers == 0 then
		return
	end

	-- Check if player has already voted
	local playerID = player:GetID()
	if RTV_VOTERS[playerID] then
		return -- Player already voted
	end

	-- Add player to voters
	RTV_VOTERS[playerID] = true
	local currentVotes = 0
	for _ in pairs(RTV_VOTERS) do
		currentVotes = currentVotes + 1
	end

	-- Calculate votes needed (90% of players + 1, capped at total players)
	local votesNeeded = math.min(math.ceil(totalPlayers * 0.9) + 1, totalPlayers)

	-- Check if threshold is met
	if currentVotes >= votesNeeded then
		-- Change map
		if #MAPS == 0 then
			Console.Log("No maps in rotation!")
			return
		end

		-- Get the next map in rotation
		local next_map = MAPS[CURRENT_MAP_INDEX]

		-- Increment index and wrap around if needed
		CURRENT_MAP_INDEX = CURRENT_MAP_INDEX + 1
		if CURRENT_MAP_INDEX > #MAPS then
			CURRENT_MAP_INDEX = 1
		end

		Console.Log("Changing map to: " .. next_map)
		Server.ChangeMap(next_map)

		-- Reset votes (this will also be done in ChangeMap event, but doing it here too for safety)
		RTV_VOTERS = {}
	else
		-- Broadcast message about the vote
		local message = "<orange>"
				.. player:GetName()
				.. "</> wants to change the map "
				.. currentVotes
				.. "/"
				.. votesNeeded
				.. " needed, type !rtv to rock the vote"
		Chat.BroadcastMessage(message)
	end
end

function ListMapsRotation(player)
	if not player then
		return
	end

	if #MAPS == 0 then
		Chat.SendMessage(player, "No maps in rotation!")
		return
	end

	-- Get next 5 maps starting from CURRENT_MAP_INDEX
	local nextMaps = {}
	local index = CURRENT_MAP_INDEX

	for i = 1, 5 do
		local map = MAPS[index]
		table.insert(nextMaps, map)

		-- Move to next map, wrap around if needed
		index = index + 1
		if index > #MAPS then
			index = 1
		end
	end

	-- Create formatted message with colors
	local mapList = {}
	for i = 1, #nextMaps do
		table.insert(mapList, "<bold>" .. i .. ". " .. nextMaps[i] .. "</>")
	end

	local message = "<cyan>Next 5 maps:</> \n" .. table.concat(mapList, "\n")
	Chat.SendMessage(player, message)
end

Events.SubscribeRemote("RockTheVote", RockTheVote)
Events.SubscribeRemote("ListMapsRotation", ListMapsRotation)

-- Function to broadcast available commands
function BroadcastCommands()
	local message = "<cyan>Available commands:</> <bold>!rtv</> - Rock the vote to change map\n<bold>!maps</> - List next 5 maps"
	Chat.BroadcastMessage(message)
end

-- Set up timer to broadcast commands every 2.5 minutes (150 seconds)
Timer.SetInterval(function()
	BroadcastCommands()
end, 150000)
