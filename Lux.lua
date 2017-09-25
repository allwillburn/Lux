local ver = "0.04"


if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end


if GetObjectName(GetMyHero()) ~= "Lux" then return end


require("DamageLib")
require("OpenPredict")

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat('<font color = "#00FFFF">New version found! ' .. data)
        PrintChat('<font color = "#00FFFF">Downloading update, please wait...')
        DownloadFileAsync('https://raw.githubusercontent.com/allwillburn/Lux/master/Lux.lua', SCRIPT_PATH .. 'Lux.lua', function() PrintChat('<font color = "#00FFFF">Update Complete, please 2x F6!') return end)
    else
        PrintChat('<font color = "#00FFFF">No updates found!')
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/allwillburn/Lux/master/Lux.version", AutoUpdate)


GetLevelPoints = function(unit) return GetLevel(unit) - (GetCastLevel(unit,0)+GetCastLevel(unit,1)+GetCastLevel(unit,2)+GetCastLevel(unit,3)) end
local SetDCP, SkinChanger = 0

local LuxMenu = Menu("Lux", "Lux")

LuxMenu:SubMenu("Combo", "Combo")
LuxMenu.Combo:Boolean("Q", "Use Q in combo", true)
LuxMenu.Combo:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
LuxMenu.Combo:Boolean("W", "Use W in combo", true)
LuxMenu.Combo:Boolean("E", "Use E in combo", true)
LuxMenu.Combo:Slider("Epred", "E Hit Chance", 3,0,10,1)
LuxMenu.Combo:Boolean("R", "Use R in combo", true)
LuxMenu.Combo:Boolean("RS", "Use R if stunned", true)
LuxMenu.Combo:Slider("Rpred", "R Hit Chance", 3,0,10,1)
LuxMenu.Combo:Slider("RX", "X Enemies to Cast R",3,1,5,1)
LuxMenu.Combo:Boolean("Cutlass", "Use Cutlass", true)
LuxMenu.Combo:Boolean("Tiamat", "Use Tiamat", true)
LuxMenu.Combo:Boolean("BOTRK", "Use BOTRK", true)
LuxMenu.Combo:Boolean("RHydra", "Use RHydra", true)
LuxMenu.Combo:Boolean("YGB", "Use GhostBlade", true)
LuxMenu.Combo:Boolean("Gunblade", "Use Gunblade", true)
LuxMenu.Combo:Boolean("Randuins", "Use Randuins", true)


LuxMenu:SubMenu("AutoMode", "AutoMode")
LuxMenu.AutoMode:Boolean("Level", "Auto level spells", false)
LuxMenu.AutoMode:Boolean("Ghost", "Auto Ghost", false)
LuxMenu.AutoMode:Boolean("Q", "Auto Q", false)
LuxMenu.AutoMode:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
LuxMenu.AutoMode:Boolean("W", "Auto W", false)
LuxMenu.AutoMode:Boolean("E", "Auto E", false)
LuxMenu.AutoMode:Slider("Epred", "E Hit Chance", 3,0,10,1)
LuxMenu.AutoMode:Boolean("R", "Auto R", false)
LuxMenu.AutoMode:Slider("Rpred", "R Hit Chance", 3,0,10,1)


LuxMenu:SubMenu("AutoFarm", "AutoFarm")
LuxMenu.AutoFarm:Boolean("Q", "Auto Q", false)
LuxMenu.AutoFarm:Boolean("E", "Auto E", false)

LuxMenu:SubMenu("LaneClear", "LaneClear")
LuxMenu.LaneClear:Boolean("Q", "Use Q", true)
LuxMenu.LaneClear:Boolean("W", "Use W", true)
LuxMenu.LaneClear:Boolean("E", "Use E", true)
LuxMenu.LaneClear:Boolean("RHydra", "Use RHydra", true)
LuxMenu.LaneClear:Boolean("Tiamat", "Use Tiamat", true)


LuxMenu:SubMenu("Harass", "Harass")
LuxMenu.Harass:Boolean("Q", "Use Q", true)
LuxMenu.Harass:Boolean("W", "Use W", true)


LuxMenu:SubMenu("KillSteal", "KillSteal")
LuxMenu.KillSteal:Boolean("Q", "KS w Q", true)
LuxMenu.KillSteal:Slider("Qpred", "Q Hit Chance", 3,0,10,1)
LuxMenu.KillSteal:Boolean("E", "KS w E", true)
LuxMenu.KillSteal:Slider("Epred", "E Hit Chance", 3,0,10,1)
LuxMenu.KillSteal:Boolean("R", "KS w R", true)
LuxMenu.KillSteal:Slider("Rpred", "R Hit Chance", 3,0,10,1)


LuxMenu:SubMenu("AutoIgnite", "AutoIgnite")
LuxMenu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)


LuxMenu:SubMenu("Drawings", "Drawings")
LuxMenu.Drawings:Boolean("DQ", "Draw Q Range", true)


LuxMenu:SubMenu("SkinChanger", "SkinChanger")
LuxMenu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
LuxMenu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 4, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

OnTick(function (myHero)
	local target = GetCurrentTarget()
        local YGB = GetItemSlot(myHero, 3142)
	local RHydra = GetItemSlot(myHero, 3074)
	local Tiamat = GetItemSlot(myHero, 3077)
        local Gunblade = GetItemSlot(myHero, 3146)
        local BOTRK = GetItemSlot(myHero, 3153)
        local Cutlass = GetItemSlot(myHero, 3144)
        local Randuins = GetItemSlot(myHero, 3143)
	local LuxQ = {delay = 0.3, range = 1175, width = 70, speed = 1200}
        local LuxE = {delay = 0.25, range = 1000, width = 350, speed = 1300}
        local LuxR = {delay = 1.0, range = 3340, width = 190, speed = math.huge} 
		
		

	--AUTO LEVEL UP
	if LuxMenu.AutoMode.Level:Value() then

			spellorder = {_E, _W, _Q, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
			if GetLevelPoints(myHero) > 0 then
				LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
			end
	end
        
        --Harass
          if Mix:Mode() == "Harass" then
            if LuxMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 825) then
				if target ~= nil then 
                                      CastTargetSpell(target, _Q)
                                end
            end

            if LuxMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 1075) then
				CastSkillShot(_W, target)
            end     
          end

	--COMBO
	  if Mix:Mode() == "Combo" then
            if LuxMenu.Combo.YGB:Value() and YGB > 0 and Ready(YGB) and ValidTarget(target, 700) then
			CastSpell(YGB)
            end

            if LuxMenu.Combo.Randuins:Value() and Randuins > 0 and Ready(Randuins) and ValidTarget(target, 500) then
			CastSpell(Randuins)
            end

            if LuxMenu.Combo.BOTRK:Value() and BOTRK > 0 and Ready(BOTRK) and ValidTarget(target, 550) then
			 CastTargetSpell(target, BOTRK)
            end

            if LuxMenu.Combo.Cutlass:Value() and Cutlass > 0 and Ready(Cutlass) and ValidTarget(target, 700) then
			 CastTargetSpell(target, Cutlass)
            end

            

            if LuxMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 1175) then
                 local QPred = GetPrediction(target,LuxQ)
                 if QPred.hitChance > (LuxMenu.Combo.Qpred:Value() * 0.1) and not QPred:mCollision(1) then
                           CastSkillShot(_Q, QPred.castPos)
                 end
            end	

            if LuxMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 1000) then
                 local EPred = GetPrediction(target,LuxE)
                 if EPred.hitChance > (LuxMenu.Combo.Epred:Value() * 0.1) then
                           CastSkillShot(_E, EPred.castPos)
                 end
            end	

            if LuxMenu.Combo.Tiamat:Value() and Tiamat > 0 and Ready(Tiamat) and ValidTarget(target, 350) then
			CastSpell(Tiamat)
            end

            if LuxMenu.Combo.Gunblade:Value() and Gunblade > 0 and Ready(Gunblade) and ValidTarget(target, 700) then
			CastTargetSpell(target, Gunblade)
            end

            if LuxMenu.Combo.RHydra:Value() and RHydra > 0 and Ready(RHydra) and ValidTarget(target, 400) then
			CastSpell(RHydra)
            end

	    if LuxMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, GetCastRange(myHero,_W)) then
			CastSkillShot(_W, target)
	    end
	    
	    
            if LuxMenu.Combo.RS:Value() and Ready(_R) and ValidTarget(target, 3340) and GetMoveSpeed(target) < 1 then
                 local RPred = GetPrediction(target,LuxR)
                 if RPred.hitChance > (LuxMenu.Combo.Rpred:Value() * 0.1) and not RPred:mCollision(1) then
                           CastSkillShot(_R, RPred.castPos)
                 end
            end	
			
	    if LuxMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 3340) then
                 local RPred = GetPrediction(target,LuxR)
                 if RPred.hitChance > (LuxMenu.Combo.Rpred:Value() * 0.1) and not RPred:mCollision(1) then
                           CastSkillShot(_R, RPred.castPos)
                 end
            end	

          end

         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 1075) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 1075) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if LuxMenu.KillSteal.Q:Value() and Ready(_Q) and ValidTarget(target, 1175) and GetHP(enemy) < getdmg("Q",enemy) then
                 local QPred = GetPrediction(target,LuxQ)
                    if QPred.hitChance > (LuxMenu.KillSteal.Qpred:Value() * 0.1) and not QPred:mCollision(1) then
                           CastSkillShot(_Q, QPred.castPos)
                    end
                end	


                if LuxMenu.KillSteal.E:Value() and Ready(_E) and ValidTarget(target, 1000) and GetHP(enemy) < getdmg("E",enemy) then 
                 local EPred = GetPrediction(target,LuxE)
                 if EPred.hitChance > (LuxMenu.Combo.Epred:Value() * 0.1) then
                           CastSkillShot(_E, EPred.castPos)
                 end
            end	
			
		if LuxMenu.KillSteal.R:Value() and Ready(_R) and ValidTarget(target, 3340) and GetHP(enemy) < getdmg("R",enemy) then
                 local RPred = GetPrediction(target,LuxR)
                  if RPred.hitChance > (LuxMenu.KillSteal.Rpred:Value() * 0.1) then
                           CastSkillShot(_R, RPred.castPos)
                  end
                end	
      end

      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if LuxMenu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 825) then
	        	CastTargetSpell(closeminion, _Q)
                end

                if LuxMenu.LaneClear.W:Value() and Ready(_W) and ValidTarget(closeminion, 1075) then
	        	CastSkillShot(_W, target)
	        end

                if LuxMenu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 1075) then
	        	CastSkillShot(_E, target)
	        end

                if LuxMenu.LaneClear.Tiamat:Value() and ValidTarget(closeminion, 350) then
			CastSpell(Tiamat)
		end
	
		if LuxMenu.LaneClear.RHydra:Value() and ValidTarget(closeminion, 400) then
                        CastTargetSpell(closeminion, RHydra)
      	        end
          end
      end
		
		
		--Auto on minions
          for _, minion in pairs(minionManager.objects) do
      			
      			   	
              if LuxMenu.AutoFarm.Q:Value() and Ready(_Q) and ValidTarget(minion, 1100) and GetCurrentHP(minion) < CalcDamage(myHero,minion,QDmg,Q) then
                  CastSkillShot(_Q, minion)
              end
	     if LuxMenu.AutoFarm.E:Value() and Ready(_E) and ValidTarget(minion, 1000) and GetCurrentHP(minion) < CalcDamage(myHero,minion,EDmg,E) then
                  CastSkillShot(_E, minion)
              end
	   end		
		
		
        --AutoMode
        if LuxMenu.AutoMode.Q:Value() and Ready(_Q) and ValidTarget(target, 1175) then
                 local QPred = GetPrediction(target,LuxQ)
                 if QPred.hitChance > (LuxMenu.AutoMode.Qpred:Value() * 0.1) and not QPred:mCollision(1) then
                           CastSkillShot(_Q, QPred.castPos)
                 end
        end	

        if LuxMenu.AutoMode.W:Value() then        
          if Ready(_W) and ValidTarget(target, 1075) then
	  	      CastSkillShot(_W, target)
          end
        end
        if LuxMenu.AutoMode.E:Value() and Ready(_E) and ValidTarget(target, 1000) then
                 local EPred = GetPrediction(target,LuxE)
                 if EPred.hitChance > (LuxMenu.Combo.Epred:Value() * 0.1) then
                           CastSkillShot(_E, EPred.castPos)
                 end
            end	
        if LuxMenu.AutoMode.R:Value() and Ready(_R) and ValidTarget(target, 3340) then
                 local RPred = GetPrediction(target,LuxR)
                 if RPred.hitChance > (LuxMenu.KillSteal.Rpred:Value() * 0.1) then
                           CastSkillShot(_R, RPred.castPos)
                 end
            end	
                
	--AUTO GHOST
	if LuxMenu.AutoMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)

OnDraw(function (myHero)
        
         if LuxMenu.Drawings.DQ:Value() then
		DrawCircle(GetOrigin(myHero), 825, 0, 200, GoS.Red)
	end

end)


OnProcessSpell(function(unit, spell)
	local target = GetCurrentTarget()        
       
               

        if unit.isMe and spell.name:lower():find("itemtiamatcleave") then
		Mix:ResetAA()
	end	
               
        if unit.isMe and spell.name:lower():find("itemravenoushydracrescent") then
		Mix:ResetAA()
	end

end) 


local function SkinChanger()
	if LuxMenu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Lux</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')





