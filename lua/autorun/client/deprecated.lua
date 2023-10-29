hook.Add("CreateMove", "Old ACE", function(Move)
    if Move:GetButtons() ~= 0 then
        chat.AddText(Color(255, 0, 0), "[ACE] This developer branch version is deprecated and wont receive further updates. Use it under your own risk or switch to: https://github.com/RedDeadlyCreeper/ArmoredCombatExtended/tree/dev!")

        hook.Remove("CreateMove", "Old ACE")
    end
end)