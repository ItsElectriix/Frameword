local temp = false
function startAnim()
	Citizen.CreateThread(function()
    
      if not temp then
	       RequestAnimDict("amb@world_human_seat_wall_tablet@female@base")
              while not HasAnimDictLoaded("amb@world_human_seat_wall_tablet@female@base") do
                Citizen.Wait(0)
              end
		  attachObject()
		  TaskPlayAnim(GetPlayerPed(-1), "amb@world_human_seat_wall_tablet@female@base", "base" ,8.0, -8.0, -1, 50, 0, false, false, false)
          temp = true
      end
	end)
end

function attachObject()
	tab = CreateObject(GetHashKey("prop_cs_tablet"), 0, 0, 0, true, true, true)
	AttachEntityToEntity(tab, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.17, 0.10, -0.13, 20.0, 180.0, 180.0, true, true, false, true, 1, true)
end

function stopAnim()
    temp = false
	StopAnimTask(GetPlayerPed(-1), "amb@world_human_seat_wall_tablet@female@base", "base" ,8.0, -8.0, -1, 50, 0, false, false, false)
    DeleteObject(tab)
end