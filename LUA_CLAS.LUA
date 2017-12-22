//freeslots, get your freeslots here!
	freeslot("S_SPINDASH1","SPR_SPIN")
	freeslot("sfx_rev1", "sfx_rev2", "sfx_rev3", "sfx_rev4", "sfx_rev5", "sfx_rev6", "sfx_rev7")

local cv_camadjust = CV_RegisterVar({ //Slope camera adjustment console variable setup.
	name = "camadjust",
	defaultvalue = "Off",
	flags = CV_SAVE|CV_SHOWMODIF,
	PossibleValue = CV_OnOff,
	func = nil
})

//oh look this is blatantly copied off of modernabilities
local function P_GravAndScale (actor)
	return P_MobjFlip(actor)*actor.scale
end


//Main Configuration for everyone
addHook("ThinkFrame", do
    for player in players.iterate
	if player.mo
//setting up variables
    //setting up prevz
        if player.mo.prevz == nil
            player.mo.prevz = 0
        end
     
	//setting up a prevnormspd because I can't think of another way to incriment the speed
		if player.prevnormspd == nil
			player.prevnormspd = 0
		end
		
	//setting up player.isclassic to boost compatibility with other wads
		if player.isclassic == nil
			player.isclassic = true
		end
		
	//setting up the player.hasmomentum and classic animations for greater compatibility
		if player.hasmomentum == nil
			player.hasmomentum = true
		elseif not (player.isclassic)
			player.hasmomentum = false
		end
		
//Classic animations: This was split into its own seperate things but this disables all of them
		if player.classicanimations == nil
			player.classicanimations = true
		elseif not (player.isclassic)
			player.classicanimations = false
		end
	
	//specialspindash: If set to true, the player will no longer use the new spindash animations
		if player.specialspindash == nil
			player.specialspindash = false
		elseif not (player.classicanimations)
			player.specialspindash = true
		end
		
	//nowalkspring: disables the walking animation and gives back the old falling frames, good for if your character needs to be in falling frames to avoid conflict.
		if player.nowalkspring == nil
			player.nowalkspring = false
		elseif not (player.classicanimations)
			player.nowalkspring = true
		end
		
	//nocharge: disables the new spindash behavior, for if you have a character like silver that needs to do his own thing while still using PF_STARTDASH
		if player.nocharge == nil
			player.nocharge = false
		elseif not (player.isclassic)
			player.nocharge = true
		end
	//nospinfix: this disables the new spin-when-you-hit-the-ground fix, in case you need to stop the player from spinning when landing.
		if player.nospinfix == nil
			player.nospinfix = false 
		end //This is the only one to not get turned off by "not player.classic"
	
		
    //setting up the check for our real speed
		player.rspeed = R_PointToDist2(0, 0, player.rmomx, player.rmomy)
		//print(player.rspeed/FRACUNIT, "speed", "", "")
	
	//setting up a check for conveyor speed
		player.conveyorspeed = R_PointToDist2(0, 0, player.cmomx, player.cmomy)
		//print(player.conveyorspeed/FRACUNIT, "CSPEED","","")
		
    //setting up default values for everyone to have
		if (player.mo.skin == "sonic")
		or (player.mo.skin == "fsonic")
			player.charability = CA_NONE
			if gametype ~= GT_COOP
				player.topspeed = 38*FRACUNIT
			else
				player.topspeed = 34*FRACUNIT
			end
		else
			player.topspeed = 34*FRACUNIT
		end
		player.maxspeed = 115*FRACUNIT //Because we can't just have Sonic zooming at an out-of-control speed
		
		/*		~TO DO~
		//Make an options screen to make certain aspects of this WAD togglable, akin to the level select in the Sonic 1/2 mobile ports.
		//Add abilities from other classic games for Sonic such as the Insta-Shield, My version of the Drop Dash script, the Super PeelOut (needs running animations) and possibly with Saph's permission, normal shields replaced with elemental shields.
		//Add support for Axis2D.
		//Possibly add in the air drag mechanic.
		//Possibly nerf slope acceleration in later versions when slopes become more widely used (I.E. closer to 2.2's release).
		*/
        if not (player.mo.skin == "peach") //If you're not the exception, you're the rule
        and not (player.mo.skin == "toad")
		and not (player.mo.skin == "samus")
        and not (player.mo.skin == "marisa")
        and not (player.mo.skin == "alice")
        and not (player.mo.skin == "sonicrefancy")
        and not (player.mo.skin == "modernsonic")
        and not (player.mo.skin == "sonicre")
        and not (player.mo.skin == "tailsre")
        and not (player.mo.skin == "knuxre")
        and not (player.mo.skin == "silver")
		and not (player.mo.skin == "kirby")
		and not (player.isclassic == false)
		
	//Here's our base values for everyone, hopefully this is closer to Sonic 2/3's stats
	//KNOWN BUG: Running down ramp sectors will cause them to act like slopes
	//KNOWN BUG: Running on ice when changing sectors will sometimes cause the player to accelerate into infinity.
	//This also happens when running down slopes in Axis2D, I'll have to look at Axis2D's source code to figure out why this happens.
		//Breaking the vanilla speed cap
			if player.rspeed > player.topspeed //If the player is running faster than they can normally
			and not ((player.mo.eflags & MFE_JUSTHITFLOOR) and player.mo.friction != 59392)
			and not (player.mo.eflags & MFE_JUSTHITFLOOR)
			and (player.hasmomentum)
			and not (player.isclassic == false)
			and not (player.mo.skin == "dirk" and player.cmd.buttons & BT_USE)
				if not (player.powers[pw_sneakers])
				and not (player.powers[pw_super])
					if player.rspeed > player.normalspeed //If the player is going faster than their normalspeed
					and player.rspeed >= player.normalspeed - (6*FRACUNIT)
					and P_IsObjectOnGround(player.mo) //and the player is on the ground
						player.normalspeed = $1 + (player.rspeed - player.topspeed) + (6*FRACUNIT)
					elseif player.rspeed < player.normalspeed - 8*FRACUNIT
						player.normalspeed = $1 - 5*FRACUNIT
					end
				end
			elseif not (player.dashmode)
				player.normalspeed = player.topspeed
			end
			
		//Fixing slope physics slightly to play better with the new speed cap
			if player.mo.prevz > player.mo.z //if the player is going downhill
			and player.rspeed >= player.topspeed - 6*FRACUNIT //and the player is running as fast as they normally can
			and P_IsObjectOnGround(player.mo) //And the player is on the ground (kinda important)
			and player.rspeed < player.maxspeed //Don't accelerate if we're over max speed, this keeps control managable
			and (player.hasmomentum) //gives us support for other characters to utilize this
			and not (player.isclassic == false) //isclassic enables and disables the entire system
				player.normalspeed = player.prevnormspd + (((player.mo.prevz - player.mo.z)*2)/(player.normalspeed/FRACUNIT)) //MOAR SPED
			end
			
		//Experimental camera option that adjusts the camera up or down intended to depend on if you're running up or down a slope
		//Sadly, this also ends up messing with the camera when running up and down stairs which is unintended, thus why it defaults to off.
			if (cv_camadjust.value)
				if not (player.mo.eflags & MFE_JUSTHITFLOOR)
				and not (maptol & TOL_2D)
				and P_IsObjectOnGround(player.mo)
					COM_BufInsertText(player, "cam_height "..20+(((player.mo.prevz-player.mo.z)/FRACUNIT)*3))
				else
					COM_BufInsertText(player, "cam_height 20")
				end
			else
			end
			
			
			if (player.powers[pw_super]) //souped up acceleration for super players
			or (player.mo.skin == "metal_sonic") //metal sonic flies so he should have a bit more acceleration
				player.thrustfactor = 5
			else
				player.thrustfactor = 3 
			end
			
			
			if not (player.mo.skin == "metal_sonic") //metal sonic does his own thing
				player.runspeed = 24*FRACUNIT
				player.accelstart = 178
				player.acceleration = 48
			end
			
			
			if player.spinitem == MT_THOK //unless you have a unique spintrail, you don't really need one
				player.spinitem = 0
			end
			
			
			if (player.classicanimations)
				player.revitem = 0
			end
			
			player.mo.prevz = player.mo.z
			player.prevnormspd = player.normalspeed
			
		//Buffing glide acceleration
			if player.charability == CA_GLIDEANDCLIMB
			and not P_IsObjectOnGround(player.mo)
			and player.pflags & PF_THOKKED
			and not (player.mo.state >= S_PLAY_CLIMB1 and player.mo.state <= S_PLAY_CLIMB5)
				if player.rspeed <= player.maxspeed/2
					player.actionspd = $+((player.glidetime^2)/20)
				end
			else
				player.actionspd = skins[player.mo.skin].actionspd
			end
        end
    end
	end
end)


//Classic spring animations
//this was merged with the fix from fsonic
addHook("MobjMoveCollide", function(mobj, spring)
	if (spring.flags & MF_SPRING) 
		if (mobj.z <= spring.z + spring.height)
		and (spring.z <= mobj.z + mobj.height)
			mobj.sprung = true
		end
	end
	if (spring.type == MT_SPRINGSHELL and spring.health > 0) then
		local tmz = (spring.eflags & MFE_VERTICALFLIP and -((mobj.z + mobj.height) or 1) or mobj.z)
		local tmznext = (spring.eflags & MFE_VERTICALFLIP and -mobj.momz or mobj.momz) + tmz
		local thzh = (spring.eflags & MFE_VERTICALFLIP and -(spring.z or 1) or spring.z + spring.height)
		local sprarea = FixedMul(8*FRACUNIT, spring.scale) * P_MobjFlip(spring)
		if (((tmznext <= thzh) and (tmz > thzh)) or ((tmznext > thzh - sprarea) and (tmznext < thzh))) then
			mobj.sprung = true
		end
	end
end, MT_PLAYER)
addHook("ThinkFrame", do
	for player in players.iterate
	if player.mo
		if (player.mo.state == S_PLAY_FALL1)
		and not (player.pflags & PF_JUMPED)
		and not (player.pflags & PF_THOKKED)
		and not player.boostmode
		and not (player.mo.skin == "dirk" and player.mo.standonice)
		and (player.classicanimations)
		and not (player.isclassic == false)
		and not (player.nowalkspring)
		and player.charability2 == CA2_SPINDASH
		and player.mo.sprung == true
			player.mo.state = S_PLAY_RUN1
		end
		if P_IsObjectOnGround(player.mo)
			player.mo.sprung = false
		end
	end
	end
end)

//Spindash animations
addHook("ThinkFrame", do
	for player in players.iterate do
		if player.mo
			if not (player.mo.skin == "metal_sonic")
			and not (player.mo.skin == "fsonic")
			and not (player.mo.skin == "silver")
			and not (player.mo.skin == "shadow")
			and not (player.mo.skin == "tailscd")
			and not (player.mo.skin == "dirk")
			and not (player.specialspindash) //These characters all have their own spindash charging animations
			
			if (player.pflags & PF_SPINNING) and not (player.mo.state >= S_PLAY_ATK1 and player.mo.state <= S_PLAY_ATK4)
				player.mo.state = S_PLAY_ATK1
			end
			if (player.pflags & PF_STARTDASH)
				and (player.mo.state >= S_PLAY_ATK1 and player.mo.state <= S_PLAY_ATK4) then
				player.mo.state = S_SPINDASH1 //Change state
			end
			if (player.mo.state == S_SPINDASH1)
				and (player.pflags & PF_STARTDASH) then
				player.panim = PA_ROLL
			   
				if not player.mo.spindashframe then
					player.mo.spindashframe = 0
				end
			   
				player.mo.spindashframe = ($1 + ((55*FRACUNIT)/90)) % (4*FRACUNIT)
			   
				for i=1,8 do
					local particle = P_SpawnMobj(player.mo.x, player.mo.y,
						player.mo.z + ((player.mo.eflags & MFE_VERTICALFLIP)/MFE_VERTICALFLIP * (player.mo.height - mobjinfo[MT_PARTICLE].height)),
						MT_PARTICLE)
				   
					particle.tics = 8
					particle.eflags = $1 | (player.mo.eflags & MFE_VERTICALFLIP)
					particle.scale = player.mo.scale >> 1
					particle.destscale = player.mo.scale << 3
					particle.scalespeed = FixedMul(particle.scalespeed, player.mo.scale) -- scale the scaling speed!
					P_SetObjectMomZ(particle, (30*FRACUNIT)/30+P_RandomByte()<<10, false)
				   
					P_InstaThrust(particle, player.mo.angle+FixedAngle(P_RandomRange(-15,15)*FRACUNIT), -(30*FRACUNIT)/9)
					P_TryMove(particle, particle.x+particle.momx, particle.y+particle.momy, true)
				end
				player.mo.frame = player.mo.spindashframe/FRACUNIT
			   end
			end
		end
	end
end)


 
//Classic spindash behavior
addHook("ThinkFrame", do
	for player in players.iterate
	if player.mo
	and not (player.nocharge)
	//setting up the variable to check for how many charges a spindash has
		if player.spincharges == nil
			player.spincharges = 0
		end
		
//These checks do two things: 1. Enable momentum when spinning in the air,
//& 2. Keep the player from skimming on water when rolling.		

		if player.pflags & PF_SPINNING
		and not P_IsObjectOnGround(player.mo)
			if player.pflags & PF_JUMPED
				player.pflags = $1 & ~PF_SPINNING
			else
				player.pflags = $1 & ~PF_SPINNING
				player.pflags = $1 | PF_JUMPED
				player.pflags = $1 | PF_THOKKED
			end
		end
		
	//To make this a little easier on ourselves
		if player.spincharges > 0
			player.mindash = player.maxdash
		end

	//Prevents the default spindash sound after the first chage
		if player.spincharges > 0
			player.dashtime = 1
		end
				
		if player.jumpwasdown == nil
			player.jumpwasdown = 0
		end
		//print(player.maxdash/FRACUNIT,"","","")
		
		if not (player.mo.skin == "silver")
		and not (player.mo.skin == "metal_sonic")
		and (player.isclassic)
		and not (player.mo.state == S_PLAY_DIE)
	//These characters have special spindash functions and should not be charging
		and player.charability2 == CA2_SPINDASH
		and not ((leveltime < 4*TICRATE) and (gametype == GT_RACE or gametype == GT_COMPETITION)) //because someone had the bright idea to make it so none of the buttons register durring the race countdown
			player.mindash = player.maxdash
			
		//You gotta be spindashing, man!
			if (player.pflags & PF_STARTDASH)
			//This ensures that the player can't jump while spindashing
				player.jumpfactor = 0
				
		//Main loop
			//This is only for the first one, it ensures that the spincharge
			//sound plays once
				if player.spincharges == 0
					player.mindash = 23*FRACUNIT
					player.maxdash = 25*FRACUNIT
				end
				
			//Second charge, continues on from the first
				if player.spincharges == 0
				and player.cmd.buttons & BT_JUMP
				and player.jumpwasdown == 0
					S_StartSound(player.mo, sfx_rev1)
					player.maxdash = 30*FRACUNIT
					player.spincharges = 1
			//From here, the process automates
				elseif player.spincharges <= 7
				and player.cmd.buttons & BT_JUMP
				and player.jumpwasdown == 0
					if player.maxdash < 60*FRACUNIT
					player.maxdash = $1 + 5*FRACUNIT
					end
					player.spincharges = $1 + 1
				//Sound logic
					if player.spincharges == 2
						S_StartSound(player.mo, sfx_rev2)
					elseif player.spincharges == 3
						S_StartSound(player.mo, sfx_rev3)
					elseif player.spincharges == 4
						S_StartSound(player.mo, sfx_rev4)
					elseif player.spincharges == 5
						S_StartSound(player.mo, sfx_rev5)
					elseif player.spincharges == 6
						S_StartSound(player.mo, sfx_rev6)
					elseif player.spincharges == 7
						S_StartSound(player.mo, sfx_rev7)
						player.spincharges = 6
					end
				end
			else
			//This resets our spincharges
				player.jumpfactor = skins[player.mo.skin].jumpfactor
				player.spincharges = 0
			end
		end
	//Our "was jump pressed last frame?" check ends here
		player.jumpwasdown = (player.cmd.buttons & BT_JUMP)
	end
	if ((leveltime < 4*TICRATE) and (gametype == GT_RACE or gametype == GT_COMPETITION) and P_IsObjectOnGround(player.mo)) //also because someone had the bright idea to make it so none of the buttons register durring the race countdown
		player.charability2 = CA2_NONE
	elseif (leveltime == (4*TICRATE)+1)
		player.charability2 = skins[player.mo.skin].ability2
	end
	end
end)
 
//Fixing Spin-pressed-when-landing behavior
//KNOWN BUG: Spin SFX will play when the player lands even if they're in their standing animation
addHook("ThinkFrame", do
	for player in players.iterate
		if player.mo
		and player.charability2 == CA2_SPINDASH
		and not (player.mo.skin == "silver")
		and not (player.mo.skin == "amy")
		and not (player.mo.skin == "dirk" and ((player.mo.state >= S_PLAY_SPD1 and player.mo.state <= S_PLAY_SPD4 or player.mo.state >= S_PLAY_ICESURF1 and player.mo.state <= S_PLAY_ICESURF2) and player.speed > FixedMul(player.runspeed, player.mo.scale)	and (player.cmd.forwardmove or player.cmd.sidemove)	or player.mo.standonfreeze and player.speed)) //Basically this ENTIRE line is copied from Dirk's lua script with minor modifications to ensure that he doesn't spin while he can actually do his ice surf cheesy crust.
		and (player.cmd.buttons & BT_USE)
		and (player.mo.eflags & MFE_JUSTHITFLOOR)
		and player.mo.state != S_PLAY_DIE
		and not (player.nospinfix)
		and not P_CheckDeathPitCollide(player.mo)
		and not player.mo.sprung
			player.pflags = $1 | PF_SPINNING
			if player.rspeed > FixedMul(4*FRACUNIT, player.mo.scale)
				S_StartSound(player.mo, sfx_spin)
			end
		end
	end
end)


// Everybody's Super Sonic, even outside of match
addHook("ThinkFrame", do
	for player in players.iterate
		if not (player.charflags & SF_SUPER)
		and not (player.isclassic == false)
			player.charflags = $1|SF_SUPER
		end
	end
end)