Chat.Subscribe("ChatEntry", function(message, player)
  -- Check for !maps command
  if string.find(message, "!maps") then
    Events.CallRemote("ListMapsRotation")
    return
  end

  -- Check for !rtv command
  if string.find(message, "!rtv") then
    Events.CallRemote("RockTheVote")
    return
  end
end)
