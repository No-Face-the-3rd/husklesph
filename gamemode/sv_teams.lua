Team_Hunters = 2
Team_Props = 3

function GM:TeamsSetupPlayer(ply)
	local hunters = team.NumPlayers(Team_Hunters)
	local props = team.NumPlayers(Team_Props)
	if props <= hunters then
		ply:SetTeam(Team_Props)
	else
		ply:SetTeam(Team_Hunters)
	end
end

function GM:HandleTeamChange(ply, NewTeam, Kill)
	if !IsValid(ply) return end
	if ply:Team() == NewTeam return end
	
	ply:SetTeam(newteam)
	if Kill && ply:Alive() then
		ply:Kill()
	end
	local ct = ChatText()
	ct:Add(ply:Nick())
	ct:Add(" changed team to ")
	ct:Add(team.GetName(newteam), team.GetColor(newteam))
	ct:SendAll()	
end
	

concommand.Add("car_jointeam", function (ply, com, args)
	local curteam = ply:Team()
	local newteam = tonumber(args[1] or "") or 0
	if newteam == 1 && curteam != 1 then
		HandleTeamChange(ply, newteam, true)
	elseif newteam >= Team_Hunters && newteam <= Team_Props && newteam != curteam then
		// make sure we can't join the bigger team
		local otherteam = newteam == Team_Hunters and Team_Props or Team_Hunters
		if team.NumPlayers(newteam) <= team.NumPlayers(otherteam) then
			HandleTeamChange(ply, newteam, true)
		else
			local ct = ChatText()
			ct:Add("Team full, you cannot join")
			ct:Send(ply)
		end
	end
end)

function GM:CheckTeamBalance()
	if !self.TeamBalanceCheck || self.TeamBalanceCheck < CurTime() then
		self.TeamBalanceCheck = CurTime() + 3 * 60 // check every 3 minutes

		local diff = team.NumPlayers(Team_Hunters) - team.NumPlayers(Team_Props)
		if math.abs(diff) > 1 then // teams must not be off by more than 2 for team balance
			self.TeamBalanceTimer = CurTime() + 30 // balance in 30 seconds
			for k,ply in pairs(player.GetAll()) do
				ply:ChatPrint("Auto team balance in 30 seconds")
			end
		end
	end
	if self.TeamBalanceTimer && self.TeamBalanceTimer < CurTime() then
		self.TeamBalanceTimer = nil
		self:BalanceTeams()
	end
end

function GM:BalanceTeams(nokill)
	local diff = team.NumPlayers(Team_Hunters) - team.NumPlayers(Team_Props)
	if math.abs(diff) > 1 then // teams must not be off by more than 2 for team balance
		local biggerTeam = diff > 0 and Team_Hunters or Team_Props
		local smallerTeam = diff > 0 and Team_Props or Team_Hunters
		while math.abs(diff) > 1 do
			local players = team.GetPlayers(biggerTeam)
			local ply = players[math.random(#players)]
			HandleTeamChange(ply, smallerTeam, !noKill)
			diff = diff - (diff > 0 and 2 or -2)
		end
	end
end

function GM:SwapTeams()
	for k, ply in pairs(player.GetAll()) do
		if ply:Team() == 2 then
			ply:SetTeam(3)
		elseif ply:Team() == 3 then
			ply:SetTeam(2)
		end
	end
	local ct = ChatText()
	ct:Add("Teams have been swapped", Color(50, 220, 150))
	ct:SendAll()
end
