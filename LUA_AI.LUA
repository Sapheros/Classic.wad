addHook("BotAI", function(sonic, tails)

/* 		~TODO~
-Allow Tails to pick up Sonic when player 1 holds down custom 1 and double jumps.
*/

//Setting up our variables for Sonic
	if not (tails.skin == "paper_mario" or tails.skin == "paper_luigi") //The Bros have their own AI! Don't mess with it!
	and not(tails.skin == "mario" or tails.skin == "luigi")
	and not (sonic.skin == "mario" or sonic.skin == "luigi")
	
	if sonic.spintime == nil
		sonic.spintime = 0
	end
	if sonic.jumptime == nil
		sonic.jumptime = 0
	end
	if sonic.forwardtime == nil
		sonic.forwardtime = 0
	end
	if sonic.backtime == nil
		sonic.backtime = 0
	end
	if sonic.spinoff == nil
		sonic.spinoff = 0
	end
	if sonic.jumpoff == nil
		sonic.jumpoff = 0
	end
	if sonic.forwardoff == nil
		sonic.forwardoff = 0
	end
	if sonic.backoff == nil
		sonic.backoff = 0
	end
//Counter for Tails to check if he's landed yet.
	if tails.groundcounter == nil
		tails.groundcounter = 1
	end
	
// This table will become tails's button presses 
	local press = {}
	press.forward = false
	press.backward = false
	press.left = false
	press.right = false
	press.strafeleft = false
	press.straferight = false
	press.jump = false
	press.spin = false
	
//This limits Tails' ability to fly to only work when controlled by a human player
//or when I get around to fixing it, when at Sonic's command
	if tails
	and tails.player.bot == 1
	and (tails.player.pflags & PF_JUMPED)
		tails.player.charability = CA_NONE
	end
	if tails
	and tails.player.bot ~= 1
	or not (tails.player.pflags & PF_JUMPED)
		tails.player.charability = skins[tails.skin].ability
	end

//Setting up control timers for tails to use
	if sonic.player.pflags & PF_JUMPED
		sonic.jumptime = $1+1
		sonic.jumpoff = 0
	else
		sonic.jumptime = 0
		sonic.jumpoff = $1+1
	end
	if sonic.player.cmd.buttons & BT_USE
		sonic.spintime = $1+1
		sonic.spinoff = 0
	else
		sonic.spintime = 0
		sonic.spinoff = $1+1
	end
	
//Tails will follow sonic at a distance
	if ((R_PointToDist2(tails.x, tails.y, sonic.x, sonic.y) > FixedMul(RING_DIST/17*FRACUNIT, sonic.scale) and sonic.player.rspeed) or R_PointToDist2(tails.x, tails.y, sonic.x, sonic.y) > FixedMul(RING_DIST/20, sonic.scale))
	and not (sonic.player.pflags & PF_STARTDASH and tails.player.pflags & PF_STARTDASH)
	and not (tails.player.pflags & PF_SPINNING)
		tails.angle = R_PointToAngle2(tails.x, tails.y, sonic.x, sonic.y)
		press.forward = true
	end
	
//This will make it so that if Tails is on land, it'll increment a counter, if he hasn't landed since he spawned, then he won't be able to fly sonic	
	if P_IsObjectOnGround(tails)
		tails.groundcounter = $1+1
	end
		
//And if he gets too far ahead of Sonic, he'll backpedal
	if ((tails.player.speed*(1+(1/2)) > sonic.player.speed) and R_PointToDist2(tails.x, tails.y, sonic.x, sonic.y) > FixedMul(RING_DIST/5+((sonic.player.speed/(FRACUNIT*10))), sonic.scale) and R_PointToDist2(tails.x, tails.y, sonic.x, sonic.y) < FixedMul(RING_DIST/20+((sonic.player.speed/(FRACUNIT*10))), sonic.scale))
	and not (sonic.player.cmd.buttons & BT_CUSTOM1)
		press.backward = true
	end
	
//If Tails is for whatever reason lower than Sonic, as long as he hasn't jumped, he will jump after Sonic with a delay
	if ((tails.z*P_MobjFlip(tails) - ((sonic.z*P_MobjFlip(sonic))-(30*FRACUNIT)) < (sonic.momz/FRACUNIT)) and not (sonic.player.pflags & PF_JUMPED))
	or tails.z*P_MobjFlip(tails) - sonic.z*P_MobjFlip(sonic) < (sonic.momz/FRACUNIT)-(75*FRACUNIT)
	or (not P_IsObjectOnGround(tails) and sonic.player.cmd.buttons & BT_JUMP)
	or (sonic.jumptime >= 10 and sonic.jumpoff <=20 and sonic.player.pflags & PF_JUMPED and not (tails.player.pflags & PF_JUMPED))
	and not (tails.prevz > tails.z and not (tails.player.pflags & PF_JUMPED))
	and not (sonic.prevz > sonic.z and not (sonic.player.pflags & PF_JUMPED))
		press.jump = true
	end
	
	
//Check to see if Tails exists. If he doesn't, reset the ground counter
	if not tails.valid
		tails.groundcounter = 0
	end

	
//Shoddy check to see if Sonic pressed spin 10 frames ago
	if sonic.spintime >= 10
	and sonic.spinoff <= 20
		press.spin = true
	end
//And to see if he's let go of spin 10 frames ago
	if sonic.spinoff >= 10
		press.spin = false
	end
	
//If they're both spindashing, Tails should be pointing in the direction Sonic is
	if sonic.player.pflags & PF_STARTDASH
	and tails.player.pflags & PF_STARTDASH
		tails.angle = sonic.angle 
		if sonic.player.cmd.buttons & BT_JUMP
			press.jump = true
		end
	end

//This prevents Tails from just holding down jump and spin
	if (tails.eflags & MFE_JUSTHITFLOOR)
		press.jump = false
		press.spin = false
	end

//This enables Tails to follow Sonic rather than jumping over springs like he usually would
	if sonic.state == S_PLAY_SPRING
		press.jump = false
	end

//This returns the value of each button press
	return press
end
end)