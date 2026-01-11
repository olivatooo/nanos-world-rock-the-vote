CFG = Server.GetCustomSettings()
MAPS = {}
CURRENT_MAP_INDEX = 1

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
end)
