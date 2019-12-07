AddCSLuaFile()

ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.PrintName = "Ragdoll Fight Arena"
ENT.Author = "Necrossin"
ENT.Information = "Lets you punch other players anywhere."
//ENT.Purpose = "Controls:\n\nAttack - Left mouse button + jumping/crouching/etc\nGrab - Hold right mouse button. Release +crouch/jump/etc to throw\n\nTo remove an arena - just undo it"
ENT.Category = "Fun + Games"

ENT.Spawnable = true
ENT.AdminOnly = false

ENT.MaxRounds = 3
ENT.StartingCharge = 33//0 //should probably make convars for these
ENT.ChargeMultiplier = 1.6//1.2

ENT.MessageBig = 1
ENT.MessageMed = 2
ENT.MessageSmall = 3

local arena_length = 48
local arena_width = 400
local arena_height = 200

//bottom
local box1_min = Vector( -arena_width/2, -arena_length/2, -7 )
local box1_max = Vector( arena_width/2, arena_length/2, -0.2 )

//top
local box2_min = Vector( -arena_width/2, -arena_length/2, 0 )
local box2_max = Vector( arena_width/2, arena_length/2, 2 )

local box2_offset = Vector( 0, 0, arena_height )

//wall
local box3_min = Vector( -arena_width/2, -1, 0 )
local box3_max = Vector( arena_width/2, 0, arena_height )

local box3_offset = Vector( 0, -arena_length/2, 0 )


//small walls
local box4_min = Vector( -3, -arena_length/2, 0 )
local box4_max = Vector( 0, arena_length/2, arena_height )

local box4_offset = Vector( -arena_width/2, 0, 0 )

local cam_offset = Vector( 0, -200, 75 )

local cam_points = {
	Vector( -arena_width/2, -arena_length/2, 0 ),
	Vector( arena_width/2, -arena_length/2, 0 ),
	Vector( -arena_width/2, -arena_length/2, arena_height ),
	Vector( arena_width/2, -arena_length/2, arena_height ),
}

local spawnpoints = {
	[1] = Vector( -arena_width/3, 0, 15 ),
	[2] = Vector( arena_width/3, 0, 15 ),
}

local player_styles = { 
	"six fingers", "fart of dragon", "mingejitsu", "backup plan", "hi youtube", "molten core", "old and spicy", "that guy", "angry frenchman", "local man",
	"college ball", "butt breaker", "your mom", "deadly fedora", "nothing personnel", "i studied fist", "minecon punch", "facepunch", "timeroller",
	"i eat steroids", "drop 2k or die", "windows 10", "200% invincible", "wild ride", "i collect wood", "nanomachines, son"
}


if SERVER then

util.AddNetworkString( "RagdollFightArenaUpdatePlayer" )
util.AddNetworkString( "RagdollFightArenaUpdateSpectator" )
util.AddNetworkString( "RagdollFightArenaRemoveSpectator" )
util.AddNetworkString( "RagdollFightArenaRemovePlayer" )
util.AddNetworkString( "RagdollFightArenaSendMessage" )


	function ENT:SpawnFunction( pl, tr, classname )

		if ( !tr.Hit ) then return end

		local SpawnPos = tr.HitPos
		local SpawnAng = pl:EyeAngles()
		SpawnAng.p = 0
		
		SpawnAng = SpawnAng:Forward():Angle()

		local ent = ents.Create( classname )
		ent:SetPos( tr.HitPos )
		ent:SetAngles( SpawnAng )
		ent:Spawn()
		ent:Activate()

		return ent

	end

	function ENT:Initialize()
		self:SetModel( "models/dav0r/camera.mdl" )
		self:DrawShadow( false )

		self:PhysicsInitMultiConvex( 
		{
			{ 
				Vector( box1_min.x, box1_min.y, box1_min.z ),
				Vector( box1_min.x, box1_min.y, box1_max.z ),
				Vector( box1_min.x, box1_max.y, box1_min.z ),
				Vector( box1_min.x, box1_max.y, box1_max.z ),
				Vector( box1_max.x, box1_min.y, box1_min.z ),
				Vector( box1_max.x, box1_min.y, box1_max.z ),
				Vector( box1_max.x, box1_max.y, box1_min.z ),
				Vector( box1_max.x, box1_max.y, box1_max.z ),
			},
			{ 
				Vector( box2_min.x, box2_min.y, box2_min.z ) + box2_offset,
				Vector( box2_min.x, box2_min.y, box2_max.z ) + box2_offset,
				Vector( box2_min.x, box2_max.y, box2_min.z ) + box2_offset,
				Vector( box2_min.x, box2_max.y, box2_max.z ) + box2_offset,
				Vector( box2_max.x, box2_min.y, box2_min.z ) + box2_offset,
				Vector( box2_max.x, box2_min.y, box2_max.z ) + box2_offset,
				Vector( box2_max.x, box2_max.y, box2_min.z ) + box2_offset,
				Vector( box2_max.x, box2_max.y, box2_max.z ) + box2_offset,
			},
			{ 
				Vector( box3_min.x, box3_min.y, box3_min.z ) + box3_offset,
				Vector( box3_min.x, box3_min.y, box3_max.z ) + box3_offset,
				Vector( box3_min.x, box3_max.y, box3_min.z ) + box3_offset,
				Vector( box3_min.x, box3_max.y, box3_max.z ) + box3_offset,
				Vector( box3_max.x, box3_min.y, box3_min.z ) + box3_offset,
				Vector( box3_max.x, box3_min.y, box3_max.z ) + box3_offset,
				Vector( box3_max.x, box3_max.y, box3_min.z ) + box3_offset,
				Vector( box3_max.x, box3_max.y, box3_max.z ) + box3_offset,
			},
			{ 
				Vector( box3_min.x, box3_min.y, box3_min.z ) - box3_offset,
				Vector( box3_min.x, box3_min.y, box3_max.z ) - box3_offset,
				Vector( box3_min.x, box3_max.y, box3_min.z ) - box3_offset,
				Vector( box3_min.x, box3_max.y, box3_max.z ) - box3_offset,
				Vector( box3_max.x, box3_min.y, box3_min.z ) - box3_offset,
				Vector( box3_max.x, box3_min.y, box3_max.z ) - box3_offset,
				Vector( box3_max.x, box3_max.y, box3_min.z ) - box3_offset,
				Vector( box3_max.x, box3_max.y, box3_max.z ) - box3_offset,
			},
			{ 
				Vector( box4_min.x, box4_min.y, box4_min.z ) + box4_offset,
				Vector( box4_min.x, box4_min.y, box4_max.z ) + box4_offset,
				Vector( box4_min.x, box4_max.y, box4_min.z ) + box4_offset,
				Vector( box4_min.x, box4_max.y, box4_max.z ) + box4_offset,
				Vector( box4_max.x, box4_min.y, box4_min.z ) + box4_offset,
				Vector( box4_max.x, box4_min.y, box4_max.z ) + box4_offset,
				Vector( box4_max.x, box3_max.y, box4_min.z ) + box4_offset,
				Vector( box4_max.x, box4_max.y, box4_max.z ) + box4_offset,
			},
			{ 
				Vector( box4_min.x, box4_min.y, box4_min.z ) - box4_offset,
				Vector( box4_min.x, box4_min.y, box4_max.z ) - box4_offset,
				Vector( box4_min.x, box4_max.y, box4_min.z ) - box4_offset,
				Vector( box4_min.x, box4_max.y, box4_max.z ) - box4_offset,
				Vector( box4_max.x, box4_min.y, box4_min.z ) - box4_offset,
				Vector( box4_max.x, box4_min.y, box4_max.z ) - box4_offset,
				Vector( box4_max.x, box3_max.y, box4_min.z ) - box4_offset,
				Vector( box4_max.x, box4_max.y, box4_max.z ) - box4_offset,
			},
			
			
		} )
		self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
		self:SetSolid( SOLID_VPHYSICS  )
		self:SetMoveType( MOVETYPE_VPHYSICS  )

		self:EnableCustomCollisions( true )

		self:PhysWake()
		
		self:SetUseType( SIMPLE_USE ) 
		
		local phys = self:GetPhysicsObject()
		if phys and phys:IsValid() then
			phys:EnableMotion( false )
		end
		
		self:SetRound( 1 )
		
		local ang = self:GetAngles()
		ang.p = 0
		
		self:SetDirVector( 1, ang:Forward() )
		
		ang:RotateAroundAxis( self:GetUp(), 180 )
		self:SetDirVector( 2, ang:Forward() )
		
		self.IsArena = true
		
		self.Spectators = {}
		
		//just to be sure
		constraint.Weld( self, game.GetWorld(), 0, 0, 0, false, false )
		
		
	end
	
	function ENT:Use( activator, caller, useType, value )
				
		//spectate
		if activator and activator:IsPlayer() and activator:Alive() and self:GetPlayerNum() > 1 and !IsValid( activator.RagdollFightArena ) and !IsValid( activator.RagdollFightArenaSpectator ) then
			if not self.Spectators[ tostring( activator ) ] then
				self.Spectators[ tostring( activator ) ] = activator
				self:AddSpectator( activator )
				return
			end
		end
		
		//join arena
		if activator and activator:IsPlayer() and activator:Alive() and self:GetPlayerNum() < 2 and !IsValid( activator.RagdollFightArena ) then
					
			local free_slot = 1
			
			for i=1, 2 do
				if !IsValid( self:GetPlayer( i ) ) then
					free_slot = i
					break
				end
			end
			
			self:AddPlayer( free_slot, activator )
		end
		
		
	end
	
	function ENT:OnRemove()
		
		self.Removing = true
		
		if IsValid( self:GetPlayer( 1 ) ) then
			self:RemovePlayer( 1 )
		end
		if IsValid( self:GetPlayer( 2 ) ) then
			self:RemovePlayer( 2 )
		end
		
	end
	
	function ENT:SendMessage( txt, dur, t )
		
		for i=1, 2 do
			local pl = self:GetPlayer( i )
			
			if pl and pl:IsValid() then
				
				net.Start( "RagdollFightArenaSendMessage" )
					net.WriteInt( t, 32 )
					net.WriteFloat( dur )
					net.WriteString( txt )
				net.Send( pl )
				
			end
		end
		
		for k, v in pairs( self.Spectators ) do
			if v and v:IsValid() and v:Alive() then
				net.Start( "RagdollFightArenaSendMessage" )
					net.WriteInt( t, 32 )
					net.WriteFloat( dur )
					net.WriteString( txt )
				net.Send( v )
			end
		end
		
	end
	
	function ENT:AddSpectator( ent )
		
		ent.RagdollFightArenaSpectator = self
		
		net.Start( "RagdollFightArenaUpdateSpectator" )
			net.WriteEntity( self )
		net.Send( ent )
		
		undo.Create( "Spectate" )
		undo.SetPlayer( ent )
		undo.SetCustomUndoText( "Stopped spectating" )
		undo.AddFunction( function( tab, arena, pl )
				if arena and arena:IsValid() and pl and pl:IsValid() then
					arena:RemoveSpectator( pl )
				end
			end, self.Entity, ent )
		undo.Finish()
		
	end
	
	function ENT:RemoveSpectator( ent )
		
		if ent and self.Spectators[ tostring( ent ) ] then
			self.Spectators[ tostring( ent ) ] = nil
			net.Start( "RagdollFightArenaRemoveSpectator" )
			net.Send( ent )
			ent.RagdollFightArenaSpectator = nil
		end
		
	end
	
	function ENT:AddPlayer( slot, ent )
	
		//remove noclip
		ent:SetMoveType( MOVETYPE_WALK )
		
		if ent:FlashlightIsOn() then
			ent:Flashlight( false )
		end
		
		slot = math.Clamp( slot, 1, 2 )
		self:SetDTEntity( slot, ent )
		
		ent.RagdollFightArena = self
		ent.RagdollFightArenaSlot = slot
		net.Start( "RagdollFightArenaUpdatePlayer" )
			net.WriteEntity( self )
			net.WriteInt( slot, 32 )
		net.Send( ent )
		
		self:SetSpawnPos( slot, ent )
		RagdollFightRemoveRagdoll( ent )
		RagdollFightSpawnRagdoll( ent )
		
		self:AddRagdollFighter( slot, ent )
		self:ClearPos( ent )
		
		self:SetPlayerHealth( slot, 100 )
		self:SetCharge( slot, self.StartingCharge )
		self:SetPlayerText( slot, player_styles[ math.random( 1, #player_styles ) ] )
		
		for i=1, 2 do
			if IsValid( self:GetPlayer( i ) ) and i ~= slot then
				self:SetSpawnPos( i, self:GetPlayer( i ) )
			end
		end
		
		if self:GetPlayerNum() >= 2 then
			self:SendMessage( "ROUND "..self:GetRound(), 1.5, self.MessageBig )
			self:SendMessage( "FIGHT", 1.5, self.MessageBig )
		end
		
		undo.Create( "Joined Ragdoll Fight Arena" )
		undo.SetPlayer( ent )
		undo.SetCustomUndoText( "Abandoned Ragdoll Fight Arena" )
		undo.AddFunction( function( tab, arena, pl, sl )
				if arena and arena:IsValid() and pl and pl:IsValid() and sl then
					if arena:GetPlayer( sl ) == pl then
						arena:RemovePlayer( sl )
					end
				end
			end, self.Entity, ent, slot )
		undo.Finish()
		
		hook.Run( "RagdollFightPlayerJoinedArena", ent, self, slot )
		
	end
	
	function ENT:RemovePlayer( slot )
		slot = math.Clamp( slot, 1, 2 )
		
		local pl = self:GetPlayer( slot )
		
		if pl and pl:IsValid() then
			RagdollFightRemoveRagdoll( pl )
			pl:SetMoveType( MOVETYPE_WALK )
			pl:SetCollisionGroup( COLLISION_GROUP_PLAYER )
			if pl.OldJumpPower then
				pl:SetJumpPower( pl.OldJumpPower )
			end
			pl.RagdollFightArena = nil
			pl.RagdollFightArenaSlot = nil
			net.Start( "RagdollFightArenaRemovePlayer" )
			net.Send( pl )
			if pl:Alive() and not self.Removing then
				pl:SetPos( self:GetPos() + self:GetRight() * 100 + self:GetForward() * ( slot == 1 and -90 or 90 ) )
			end
			
			hook.Run( "RagdollFightPlayerAbandonedArena", pl, self, slot )
			
			if pl:IsBot() and pl.RagdollFightBot then
				pl:Kick()
			end
			
		end
		
		if not self.Removing then
			self:SetCharge( slot, self.StartingCharge )
			self:SetPlayerHealth( slot, 100 )
			self:SetDTEntity( slot, NULL )
		end
		
	end
	
	function ENT:SetSpawnPos( slot, pl )
		local pos = spawnpoints[ slot ]
		
		if pos then
			local new_pos = LocalToWorld( pos, Angle( 0, 0, 0 ) , self:GetPos(), self:GetAngles() )
			pl:SetPos( new_pos )
		end
		
	end
	
	//lets make sure players wont get stuck in each other
	function ENT:ClearPos( ent1, pos )
	
		local pl1 = self:GetPlayer( 1 )
		local pl2 = self:GetPlayer( 2 )
		
		local ent2 = ent1 == pl1 and pl2 or pl1
		local slot1 = ent1 == pl1 and 1 or 2
		local slot2 = slot1 == 1 and 2 or 1
			
		if ent1:IsValid() and ent2:IsValid() then
					
			pos = pos or ent1:GetPos()
			local pos2 = ent2:GetPos()
			
			local c_pos = Vector( pos.x, pos.y, 0 )
			local c_pos2 = Vector( pos2.x, pos2.y, 0 )
			
			local dist = c_pos:Distance( c_pos2 )
									
			if dist < 60 then
							
				local new_pos = pos + self:GetDirVector( slot1 ) * 65
								
				new_pos = self:ConvertIntoSafePos( new_pos )
				
				c_pos2 = Vector( new_pos.x, new_pos.y, 0 )
				
				local dist2 = c_pos:Distance( c_pos2 )
				
												
				if dist2 < 60 then
									
					new_pos = pos + self:GetDirVector( slot2 ) * 65
					
					new_pos = self:ConvertIntoSafePos( new_pos )
					
				end
								
				ent2:SetPos( new_pos )
				
			end
			
			
		end
		
	end
	
	//prevents player from getting stuck inside the arena itself (or outside)
	function ENT:ConvertIntoSafePos( pos )
		
		local pos_loc = self:WorldToLocal( pos )
		
		pos_loc.x = math.Clamp( pos_loc.x, -176, 176 )
		pos_loc.y = 0
		pos_loc.z = 15
		
		local fixed_pos = self:LocalToWorld( pos_loc )
		
		return fixed_pos, pos_loc
		
	end
	
	function ENT:AddRagdollFighter( slot, pl )
		
		slot = math.Clamp( slot + 2, 3, 4 )
		self:SetDTEntity( slot, pl.Ragdoll )
		
	end
	
	function ENT:SetPlayerHealth( slot, am )
		
		local rag = self:GetRagdollFighter( slot )
		
		slot = math.Clamp( slot, 1, 2 )
		if rag and rag:IsValid() then 
			self:SetDTInt( slot, math.Clamp( am or 100, 0, 100 ) )
			
			if self.ResettingRound then return end
			
			if self:GetPlayerHealth( slot ) <= 0 then
				
				self.ResettingRound = true
				
				local enemy_slot = slot == 1 and 2 or 1
				
				self:SetPlayerScore( enemy_slot, self:GetPlayerScore( enemy_slot ) + 1 )
				
				if self:GetRound() == 2 and ( self:GetPlayerScore( 1 ) >= 2 or self:GetPlayerScore( 2 ) >= 2 ) or self:GetRound() == 3 then
					local winner = self:GetPlayerScore( enemy_slot ) >= 2 and enemy_slot == 1 and 1 or 2
					
					local winner_pl = self:GetPlayer( winner )
					
					if winner_pl and winner_pl:IsValid() then
						self:SendMessage( string.upper( winner_pl:Nick() ).." WON THE MATCH!", 3, self.MessageSmall )
						hook.Run( "RagdollFightPlayerWonMatch", winner_pl, self, winner )
					end
					
					timer.Simple( 5, function() if IsValid( self.Entity ) then self:ResetRound( true ) end end )
				else
				
					local winner_pl = self:GetPlayer( enemy_slot )
					
					if winner_pl and winner_pl:IsValid() then
						self:SendMessage( string.upper( winner_pl:Nick() ).." WINS!", 3, self.MessageMed )
						hook.Run( "RagdollFightPlayerWonRound", winner_pl, self, enemy_slot )
					end
				
					timer.Simple( 5, function() if IsValid( self.Entity ) then self:ResetRound() end end )
				end
				
				
			end
			
		end
		
	end
	
	function ENT:Think()
		
		local reset = false
		
		local pl1 = self:GetPlayer( 1 )
		local pl2 = self:GetPlayer( 2 )
		
		if pl1 and pl1:IsValid() and !pl1:Alive() then
			self:RemovePlayer( 1 )
			reset = true
		end
		
		if pl2 and pl2:IsValid() and !pl2:Alive() then
			self:RemovePlayer( 2 )
			reset = true
		end
		
		if reset then
		
			for k, v in pairs( self.Spectators ) do
				if v and v:IsValid() then
					self:RemoveSpectator( v )
				end
			end
		
			self:ResetRound( true )
		end
		
		//Should I really keep it?
		for k, v in pairs( self.Spectators ) do
			if v and v:IsValid() and !v:Alive() then
				self:RemoveSpectator( v )
			end
		end
	
	end
	
	
	function ENT:SetPlayerScore( slot, am )
		slot = math.Clamp( slot + 2, 3, 4 )
		self:SetDTInt( slot, math.Clamp( am or 0, 0, self.MaxRounds ) )
	end
	
	function ENT:SetCharge( slot, am )
		slot = math.Clamp( slot + 4, 5, 6 )
		self:SetDTInt( slot, math.Clamp( am or 0, 0, 99 ) )
	end
	
	function ENT:SetPlayerText( slot, txt )
		txt = string.upper( txt )
		slot = math.Clamp( slot, 1, 2 )
		self:SetDTString( slot, txt )
	end
	
	function ENT:PlayerTakeDamage( slot, am )
		self:SetPlayerHealth( slot, self:GetPlayerHealth( slot ) - am )
		self:SetCharge( slot, self:GetCharge( slot ) + math.floor( am * self.ChargeMultiplier ) )
	end
	
	function ENT:SetDirVector( slot, vec )
		vec = vec:GetNormal()
		slot = math.Clamp( slot, 1, 2 )
		self:SetDTVector( slot, vec )
	end
	
	function ENT:SetRound( am )
		self:SetDTInt( 7, am or 1 )
	end
	
	function ENT:ResetRound( full )
		
		self.ResettingRound = false
		
		for i=1, 2 do
			local pl = self:GetPlayer( i )
			
			if pl and pl:IsValid() then
				self:SetSpawnPos( i, pl )
				self:ClearPos( pl )
				self:SetPlayerHealth( i, 100 )
				if full then
					self:SetPlayerScore( i, 0 )
					self:SetPlayerText( i, player_styles[ math.random( 1, #player_styles ) ] )
					self:SetCharge( i, self.StartingCharge )
				end
			end
			
		end
		
		if full then
			self:SetRound( 1 )
			if self:GetPlayerNum() >= 2 then
				self:SendMessage( "ROUND "..self:GetRound(), 1.5, self.MessageBig )
				self:SendMessage( "FIGHT", 1.5, self.MessageBig )
			end
		else
			self:SetRound( self:GetRound() + 1 )
			if self:GetPlayerNum() >= 2 then
				self:SendMessage( "ROUND "..self:GetRound(), 1.5, self.MessageBig )
				self:SendMessage( "FIGHT", 1.5, self.MessageBig )
			end
		end		
	end
	
		
	
else
		
	function ENT:DrawSpectatorHUD()
		
		local pl = LocalPlayer()
		local ang = self:GetAngles()
		
		if pl.RagdollFightArenaSpectator and pl.RagdollFightArenaSpectator:IsValid() and pl.RagdollFightArenaSpectator == self and IsValid( pl.RagdollFightArenaHUD ) then
		
			ang:RotateAroundAxis( self:GetForward(), 90 )
		
			cam.Start3D2D( self:LocalToWorld( self:OBBCenter() ) - self:GetRight() * arena_length / 2 - self:GetForward() * arena_width / 2 + self:GetUp() * arena_height / 2 ,ang, 0.1)
				pl.RagdollFightArenaHUD:PaintManual()
			cam.End3D2D()
		
		end
		
	end
	
	function ENT:DrawBlur()
		
		local pl = LocalPlayer()
		local ang = self:GetAngles()
		
		self.Alpha = self.Alpha or 0
		self.GoalAlpha = self.GoalAlpha or 0
		
		local arena = pl.RagdollFightSpectator and pl.RagdollFightArenaSpectator or pl.RagdollFightArena

		local dist = 20
		
		if pl.XRayTable and pl.XRayTable.xray_time and pl.XRayTable.xray_time > CurTime() and arena and arena == self then
			self.GoalAlpha = 230
		else
			self.GoalAlpha = 0
		end
		
		self.Alpha = math.Approach( self.Alpha, self.GoalAlpha, FrameTime() * 300 )
		
		if self.Alpha > 0 then
			
			cam.Start3D2D( self:GetPos() + vector_up - self:GetRight() * dist,ang, 1)//20
				surface.SetDrawColor( 10, 10, 10, self.Alpha )
				surface.DrawRect( - ScrW(), 0, ScrW()*2, ScrH() )
			cam.End3D2D()
			
			ang:RotateAroundAxis( self:GetForward(), 90 )
			
			cam.Start3D2D( self:LocalToWorld( self:OBBCenter() ) - self:GetRight() * ( dist + 2 ),ang, 1)//22
				surface.SetDrawColor( 10, 10, 10, self.Alpha )
				surface.DrawRect( - ScrW(), - ScrH() / 2, ScrW()*2, ScrH() )
			cam.End3D2D()
		end
		
		
	end
	
	local wireframe = Material( "models/wireframe" )
	local wire_col = Color( 200, 200, 255, 255 )
	
	local RF_SPECTATE_HINTS = util.tobool( CreateClientConVar("cl_rf_spectate_hints", 1, true, false, "Enable or disable hints for spectators in Ragdoll Fight."):GetInt() )
	cvars.AddChangeCallback("cl_rf_spectate_hints", function(cvar, oldvalue, newvalue)
		RF_SPECTATE_HINTS = util.tobool( newvalue )
	end)
	
	function ENT:Draw()
		
		local pl = LocalPlayer()
		
		self:SetRenderBounds( Vector( -400, -400, 0 ), Vector( 400, 400, 200 ) )

		local pos, ang = self:GetPos(), self:GetAngles()
		
		local rag1 = self:GetRagdollFighter( 1 )
		local rag2 = self:GetRagdollFighter( 2 )
		
		if rag1 and rag1:IsValid() and not rag1.GetPlayerColor then
			rag1.GetPlayerColor = function( s ) 
				local owner = s:GetOwner()
				if owner and owner:IsValid() then
					local col = owner:GetPlayerColor()
					return Vector( col.x, col.y, col. z )
				end
				return Vector( 1, 1, 1 )
			end
		end
		
		if rag2 and rag2:IsValid() and not rag2.GetPlayerColor then
			rag2.GetPlayerColor = function( s ) 
				local owner = s:GetOwner()
				if owner and owner:IsValid() then
					local col = owner:GetPlayerColor()
					return Vector( col.x, col.y, col. z )
				end
				return Vector( 1, 1, 1 )
			end
		end
		
		if pl.RagdollFightSpectator and IsValid( pl.RagdollFightArenaSpectator) or IsValid( pl.RagdollFightArena ) then
			self:DrawBlur()
		end
		
		/*if IsValid( LocalPlayer().RagdollFightArenaSpectator ) then
			self:DrawSpectatorHUD()
		end*/
		
		if self:GetPlayerNum() < 2 and !IsValid( pl.RagdollFightArena ) then
			
			render.DrawWireframeBox( pos, ang, box1_min, box1_max, wire_col )
			render.DrawWireframeBox( pos, ang, box2_min + box2_offset, box2_max + box2_offset, wire_col )
			render.DrawWireframeBox( pos, ang, box3_min + box3_offset, box3_max + box3_offset, wire_col )
			render.DrawWireframeBox( pos, ang, box3_min - box3_offset, box3_max - box3_offset, wire_col )
			render.DrawWireframeBox( pos, ang, box4_min + box4_offset, box4_max + box4_offset, wire_col )
			render.DrawWireframeBox( pos, ang, box4_min - box4_offset, box4_max - box4_offset, wire_col )
			
			local pos = self:GetPos()
			local ang = self:GetAngles()
			
			local cam_pos, cam_ang = LocalToWorld( cam_offset, Angle( 0, 90, 0 ), pos, ang )
			
			self:SetRenderOrigin( cam_pos )
			self:SetRenderAngles( cam_ang )
			
			render.SetColorModulation( wire_col.r / 255, wire_col.g / 255, wire_col.b / 255 )
				render.ModelMaterialOverride( wireframe )
				self:DrawModel()
				render.ModelMaterialOverride( )
			render.SetColorModulation( 1, 1, 1 )
			
			self:SetRenderOrigin( )
			self:SetRenderAngles( )
			
			for i = 1, 4 do
				local vec = cam_points[ i ]
				if vec then
					local vec_pos, vec_ang = LocalToWorld( vec, Angle( 0, 0, 0 ), pos, ang )
					render.DrawLine( cam_pos, vec_pos, wire_col, false ) 
				end
			end
			
			local eyeang = EyeAngles()
			eyeang:RotateAroundAxis( eyeang:Right(), 90 )
			eyeang:RotateAroundAxis( eyeang:Up(), -90 )
			
			cam.Start3D2D( self:GetPos() + vector_up * 72, eyeang, 0.3)
				draw.DrawText( "Press "..string.upper( input.LookupBinding( "+use", true ) or "e" ).." to join", "RagdollFightDefault", 0, 0, wire_col, TEXT_ALIGN_CENTER )
				draw.DrawText( "To exit arena, just press undo button", "RagdollFightDefault", 0, 25, wire_col, TEXT_ALIGN_CENTER )
			cam.End3D2D()
			
		end
		
		if RF_SPECTATE_HINTS then
			if self:GetPlayerNum() > 1 and !IsValid( pl.RagdollFightArena ) and !IsValid( pl.RagdollFightArenaSpectator ) then
				local eyepos = EyePos()
				if eyepos:Distance( self:NearestPoint( eyepos ) ) < 100 then//self:LocalToWorld( self:OBBCenter() )
					
					local eyeang = EyeAngles()
					eyeang:RotateAroundAxis( eyeang:Right(), 90 )
					eyeang:RotateAroundAxis( eyeang:Up(), -90 )
				
					cam.Start3D2D( self:GetPos() + vector_up * 72, eyeang, 0.3)
						draw.DrawText( "Press "..string.upper( input.LookupBinding( "+use", true ) or "e" ).." to spectate", "RagdollFightDefault", 0, 0, wire_col, TEXT_ALIGN_CENTER )
						draw.DrawText( "To exit spectating, just press undo button", "RagdollFightDefault", 0, 25, wire_col, TEXT_ALIGN_CENTER )
						draw.DrawText( "Type cl_rf_spectate_hints 0 to disable this message", "RagdollFightDefault", 0, 50, wire_col, TEXT_ALIGN_CENTER )
					cam.End3D2D()
				end
			end
		end
		
		
	end
	
	local grad = surface.GetTextureID( "gui/gradient" )
	local white_bar = Color( 255, 255, 255, 220 )
	
	local RF_DRAW_HUD = util.tobool( CreateClientConVar("cl_rf_drawhud", 1, true, false, "Enable or disable UI in Ragdoll Fight."):GetInt() )
	cvars.AddChangeCallback("cl_rf_drawhud", function(cvar, oldvalue, newvalue)
		RF_DRAW_HUD = util.tobool( newvalue )
	end)
	
	//I'm gonna play it safe and have all HUD inside this panel, without worrrying about 400+ other HUD addons that players might have installed
	local function RagdollFightHUD( spectator )
		
		local pl = LocalPlayer()
		
		if IsValid( pl.RagdollFightArenaHUD ) then
			pl.RagdollFightArenaHUD:Remove()
		end
		
		
		local base = vgui.Create( "DPanel" )
		base:SetPos( 0, 0 )
		base:SetSize( ScrW(), ScrH() )
		base:SetMouseInputEnabled( false )
		base:SetKeyboardInputEnabled( false )
		base.Arena = spectator and pl.RagdollFightArenaSpectator or pl.RagdollFightArena
		base.ShowHints = true
		if spectator then
			base.Spectate = true
			//base:SetPaintedManually( true )
		end
		
		base.Messages = {}
		
		pl.RagdollFightArenaHUD = base
		
		local bind_to_button = function( bind )
			local txt = input.LookupBinding( bind, true )
			if txt then
				return string.upper( txt )
			end
			return ""
		end
		
		base.HintText = {}
		
		base.HintText[ 1 ] = { txt = bind_to_button( "+attack" ).." - attack (also try jumping/crouching)", keys = { IN_ATTACK } }
		base.HintText[ 2 ] = { txt = bind_to_button( "+attack2" ).." - hold to grab. Release to throw", keys = { IN_ATTACK2 } }
		base.HintText[ 3 ] = { txt = bind_to_button( "+reload" ).." - hold to block", keys = { IN_RELOAD } }
		base.HintText[ 4 ] = { txt = "" }
		base.HintText[ 5 ] = { txt = bind_to_button( "+attack" ).." + "..bind_to_button( "+jump" ).." - jump kick", keys = { IN_ATTACK, IN_JUMP } }
		base.HintText[ 6 ] = { txt = bind_to_button( "+attack" ).." + "..bind_to_button( "+duck" ).." when moving - slide attack", keys = { IN_ATTACK, IN_DUCK } }
		base.HintText[ 7 ] = { txt = bind_to_button( "+forward" ).." + "..bind_to_button( "+attack" ).." + "..bind_to_button( "+jump" ).." when moving - heavy jump kick", keys = { IN_ATTACK, IN_FORWARD, IN_JUMP } }
		base.HintText[ 8 ] = { txt = "" }
		base.HintText[ 9 ] = { txt = bind_to_button( "+walk" ).." - fix your spine or playermodel", keys = { IN_WALK } }
		base.HintText[ 10 ] = { txt = bind_to_button( "+showscores" ).." - toggle hints" }
		base.HintText[ 11 ] = { txt = "" }
		base.HintText[ 12 ] = { txt = "To disable/enable UI - type cl_rf_drawhud 0 or 1 in console" }
		base.HintText[ 13 ] = { txt = "" }
		base.HintText[ 14 ] = { txt = "Now try to explain this to the second player" }
		
		base.AddMessage = function( self, txt, dur, t )
			
			if not RF_DRAW_HUD then return end
			
			local msg = {}
			
			msg.text = txt
			//msg.time = CurTime()
			msg.dur = dur 
			msg.t = t
			
			table.insert( self.Messages, msg )
			
		end
		
		base.PaintTriangle = function( self, x, y, size, id )
			
			if not self.Triangles then
				self.Triangles = {}
			end
			
			if not self.Triangles[ id ] then
				self.Triangles[ id ] = {
					{ x = x - size/2, y = y },
					{ x = x + size/2, y = y },
					{ x = x, y = y + size }
				}
			end
			
			surface.DrawPoly( self.Triangles[ id ] )//

		end
		
		base.PaintCircle = function( self, x, y, radius, seg, id )
			
			if not self.Circles then
				self.Circles = {}
			end
			
			if not self.Circles[ id ] then
				self.Circles[ id ] = {}

				table.insert( self.Circles[ id ], { x = x, y = y, u = 0.5, v = 0.5 } )
				for i = 0, seg do
					local a = math.rad( ( i / seg ) * -360 )
					table.insert( self.Circles[ id ], { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
				end

				local a = math.rad( 0 )
				table.insert( self.Circles[ id ], { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
				
			end
			
			
			surface.DrawPoly( self.Circles[ id ] )
		end
		
		base.PaintChargeBar = function( self, x, y, w, h, shift, scale )
			
			shift = shift or 5
			
			local poly = {
				{ x = x + shift, y = y - h * ( scale - 1 ) / 2 }, { x = x + shift + w, y = y - h * ( scale - 1 ) / 2 },
				{ x = x + w, y = y + h + h * ( scale - 1 ) / 2 },{ x = x, y = y + h + h * ( scale - 1 ) / 2 }
			}
			draw.NoTexture()
			surface.DrawPoly( poly )
			
		end
		
		base.Paint = function( self, pw, ph ) 
			
			local pl = LocalPlayer()
			local arena = self.Spectate and pl.RagdollFightArenaSpectator or pl.RagdollFightArena//pl.RagdollFightArena
			local my_slot = pl.RagdollFightArenaSlot
			
			if not RF_DRAW_HUD then return end
			
			if pl and arena and arena:IsValid() and my_slot then

				local slot1 = my_slot
				local slot2 = my_slot == 1 and 2 or 1
				
				self.Arena = arena
				
				//top
				
				local w, h = pw/2.3, 15
				local x, y = pw/4 - w/2, 30
				
				//all this, because I was too lazy to make a texture instead
				
				render.ClearStencil()
				render.SetStencilEnable( true )
					
				render.SetStencilWriteMask( 1 )
				render.SetStencilTestMask( 1 )
					
				render.SetStencilFailOperation( STENCIL_REPLACE )
				render.SetStencilPassOperation( STENCIL_ZERO )
				render.SetStencilZFailOperation( STENCIL_ZERO )
				render.SetStencilCompareFunction( STENCIL_NEVER )
				render.SetStencilReferenceValue( 1 )
					
					
				surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
					
				local rad1 = ( pw/2 - w + 22 ) / 2
				local rad2 = pw/22.2//72//( pw/2 - w + 22 ) / 2
									
				self:PaintCircle( pw/2, y + h + 15, rad1, 35, 1 )
					
				draw.RoundedBox( 0, x, y + h, w - rad2 * 0.7, 20, Color( 0, 0, 0, 255 ) ) 
				draw.RoundedBox( 0, 3*pw/4 - w/2 + rad2 * 0.7, y + h, w - rad2 * 0.7, 20, Color( 0, 0, 0, 255 ) ) 
					
				surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
				self:PaintCircle( x + w - rad2 * 0.7, y + h + rad2, rad2, 40, 2 )
				self:PaintCircle( 3*pw/4 - w/2 + rad2 * 0.7, y + h + rad2, rad2, 40, 3 )
				
				render.SetStencilFailOperation( STENCIL_ZERO )
				render.SetStencilPassOperation( STENCIL_REPLACE )
				render.SetStencilZFailOperation( STENCIL_ZERO )
				render.SetStencilCompareFunction( STENCIL_EQUAL )
				
				//render.SetStencilReferenceValue( 2 )
				
				render.SetStencilEnable( false )
				
				local pl1 = arena:GetPlayer( slot1 )
				
				if pl1 and pl1:IsValid() then
				
					local hp = arena:GetPlayerHealth( slot1 )
					self.LastHP1 = self.LastHP1 or hp
					self.LastChangedHP1 = self.LastChangedHP1 or hp
					self.LastHP1Fade = self.LastHP1Fade or 0
					self.FlashTime1 = self.FlashTime1 or 0
					
					if self.LastHP1 ~= hp and ( not self.LastHP1Changed or self.LastChangedHP1 ~= hp ) then
						self.LastHP1Changed = true
						self.LastChangedHP1 = hp
						self.LastHP1Fade = CurTime() + 1
						self.FlashTime1 = CurTime() + 0.07
					end
						
					render.SetStencilEnable( true )
					render.SetStencilReferenceValue( 2 )
						
					if ( self.LastHP1Fade + 1 ) > CurTime() and hp  ~= 100 then
						local delta2 = math.Clamp( ( ( self.LastHP1Fade + 1 ) - CurTime() ) / 1.3 , 0, 1 )
						surface.SetDrawColor( Color( 215 - 120 * ( 1 - delta2 ), 15, 15, 220 * delta2 ) )
						render.SetScissorRect( x + w * ( 1 - self.LastHP1/100 ), y, x + w * ( 1 - hp/100 ), y + h + 20, true )
						surface.DrawRect( x, y, w, h + 20 )
							surface.SetDrawColor( Color( 0, 0, 0, 200 * delta2  ) )
							draw.NoTexture()
							self:PaintTriangle( x + w/2, y, 6, 1 )
							self:PaintTriangle( x + 3*w/4, y, 6, 2 )
							self:PaintTriangle( x + w * 0.9, y, 6, 3 )
							self:PaintTriangle( x + w * 0.92, y, 6, 4 )
							self:PaintTriangle( x + w * 0.94, y, 6, 5 )
							self:PaintTriangle( x + w * 0.96, y, 6, 6 )
							self:PaintTriangle( x + w * 0.98, y, 6, 7 )
						render.SetScissorRect( 0, 0, 0, 0, false )
					else
						if self.LastHP1Changed then
							self.LastHP1Changed = false
							self.LastChangedHP1 = hp
							self.LastHP1 = hp
						end
					end
					
					local delta = math.Clamp( hp/100, 0, 1 )
					
					white_bar.r = 255
					white_bar.g = 255
					white_bar.b = 255
					
					if self.FlashTime1 > CurTime() then
						
						local new_col = 170//math.sin( RealTime() * 15 ) * 35 + 220
						
						white_bar.r = new_col
						white_bar.g = new_col
						white_bar.b = new_col
						
					end
				
					
					surface.SetDrawColor( white_bar )
					render.SetScissorRect( x + w * ( 1 - delta ), y, x + w, y + h + 20, true )
					surface.DrawRect( x, y, w, h + 20 )
					
					surface.SetTexture( grad )
					surface.SetDrawColor( Color( 0, 0, 0, 100 ) )
					surface.DrawTexturedRectRotated( x + w/4, y + h/2, w / 2 + 2, h + 2, 0 )
					surface.SetDrawColor( Color( 0, 0, 0, 250 ) )
					draw.NoTexture()
					self:PaintTriangle( x + w/2, y, 6, 8 )
					self:PaintTriangle( x + 3*w/4, y, 6, 9 )
					self:PaintTriangle( x + w * 0.9, y, 6, 10 )
					self:PaintTriangle( x + w * 0.92, y, 6, 11 )
					self:PaintTriangle( x + w * 0.94, y, 6, 12 )
					self:PaintTriangle( x + w * 0.96, y, 6, 13 )
					self:PaintTriangle( x + w * 0.98, y, 6, 14 )
					render.SetScissorRect( 0, 0, 0, 0, false )

					render.SetStencilEnable( false )
					
					//render.SetStencilReferenceValue( 2 )
					
					if hp < 100 and hp ~= 0 then
						local extra = hp <= 6 and hp > 2 and ( 1 - hp/6 ) * 15 or 0
						surface.SetDrawColor( Color( 255, 255, 255, 230 ) )
						surface.DrawRect( x + w * ( 1 - delta ), y, 1, h + extra )
						surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
						surface.DrawRect( x + w * ( 1 - delta )- 1, y - 3, 1, h+5+extra )
					end
					
					local style = arena:GetPlayerText( slot1 )
					draw.SimpleText( style or "", "RagdollFightDefault", x, y + h + 15, Color( 255, 255, 255, 220 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					draw.SimpleText( string.upper( pl1:Nick() or "" ), "RagdollFightDefaultTitle", x, y + h + 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
								
				end
				
				x, y = 3*pw/4 - w/2, y
				
				//render.SetStencilReferenceValue( 1 )
				
				local pl2 = arena:GetPlayer( slot2 )
				
				if pl2 and pl2:IsValid() then
				
					local hp = arena:GetPlayerHealth( slot2 )
					self.LastHP2 = self.LastHP2 or hp
					self.LastChangedHP2 = self.LastChangedHP2 or hp
					self.LastHP2Fade = self.LastHP2Fade or 0
					self.FlashTime2 = self.FlashTime2 or 0
					
					if self.LastHP2 ~= hp and ( not self.LastHP2Changed or self.LastChangedHP2 ~= hp ) then
						self.LastHP2Changed = true
						self.LastChangedHP2 = hp
						self.LastHP2Fade = CurTime() + 1
						self.FlashTime2 = CurTime() + 0.07
					end
					
					render.SetStencilEnable( true )
					render.SetStencilReferenceValue( 2 )
					
					if ( self.LastHP2Fade + 1 ) > CurTime() and hp~= 100 then
						local delta2 = math.Clamp( ( ( self.LastHP2Fade + 1 ) - CurTime() ) / 1.3 , 0, 1 )
						surface.SetDrawColor( Color( 215 - 120 * ( 1 - delta2 ), 15, 15, 220 * delta2 ) )
						render.SetScissorRect( x + w * hp/100, y, x + w * self.LastHP2/100, y + h + 20, true )
						surface.DrawRect( x, y, w, h + 20 )
							surface.SetDrawColor( Color( 0, 0, 0, 200 * delta2 ) )
							draw.NoTexture()
							self:PaintTriangle( x + w/2, y, 6, 15 )
							self:PaintTriangle( x + w/4, y, 6, 16 )
							self:PaintTriangle( x + w * 0.1, y, 6, 17 )
							self:PaintTriangle( x + w * 0.08, y, 6, 18 )
							self:PaintTriangle( x + w * 0.06, y, 6, 19 )
							self:PaintTriangle( x + w * 0.04, y, 6, 20 )
							self:PaintTriangle( x + w * 0.02, y, 6, 21 )
						render.SetScissorRect( 0, 0, 0, 0, false )
					else
						if self.LastHP2Changed then
							self.LastHP2Changed = false
							self.LastChangedHP2 = hp
							self.LastHP2 = hp
						end
					end
					
					local delta = math.Clamp( hp/100, 0, 1 )
					
					white_bar.r = 255
					white_bar.g = 255
					white_bar.b = 255
					
					if self.FlashTime2 > CurTime() then
						
						local new_col = 170
						
						white_bar.r = new_col
						white_bar.g = new_col
						white_bar.b = new_col
						
					end
									
					surface.SetDrawColor( white_bar )
					render.SetScissorRect( x, y, x + w * delta, y + h + 20, true )
					surface.DrawRect( x, y, w, h + 20 )
					surface.SetTexture( grad )
					surface.SetDrawColor( Color( 0, 0, 0, 100 ) )
					surface.DrawTexturedRectRotated( x + 3*w/4, y + h/2, w/2 + 2, h + 2, 180 )
					surface.SetDrawColor( Color( 0, 0, 0, 250 ) )
					draw.NoTexture()
					self:PaintTriangle( x + w/2, y, 6, 22 )
					self:PaintTriangle( x + w/4, y, 6, 23 )
					self:PaintTriangle( x + w * 0.1, y, 6, 24 )
					self:PaintTriangle( x + w * 0.08, y, 6, 25 )
					self:PaintTriangle( x + w * 0.06, y, 6, 26 )
					self:PaintTriangle( x + w * 0.04, y, 6, 27 )
					self:PaintTriangle( x + w * 0.02, y, 6, 28 )
					render.SetScissorRect( 0, 0, 0, 0, false )
					
					render.SetStencilEnable( false )
										
					
					if hp < 100 and hp ~= 0 then
						surface.SetDrawColor( Color( 255, 255, 255, 230 ) )
						surface.DrawRect( x + w * delta - 1, y, 1, h )
						surface.SetDrawColor( Color( 255, 255, 255, 100 ) )
						surface.DrawRect( x + w * delta, y - 3, 1, h+5 )
					end
					
					
					
					local style = arena:GetPlayerText( slot2 )
					draw.SimpleText( style or "", "RagdollFightDefault", x + w, y + h + 15, Color( 255, 255, 255, 220 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
					draw.SimpleText( string.upper( pl2:Nick() or "" ), "RagdollFightDefaultTitle", x + w, y + h + 40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
				
				end
				
				x, y = pw/2, y + h/2
							
				draw.SimpleText( arena:GetRound(), "RagdollFightRoundNumber", x, y + 10, Color( 255, 255, 255, 220 ),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				
				
				//bottom
				
				local gap = 20
				local gap2 = pw/4 - w/2
				
				local name1, hint1 = "ESCAPE GRAB", "PRESS ["..string.upper( input.LookupBinding( "+use", true ) or "e" ).."]"
				local name2, hint2 = "HORSE LEGS", "JUMPKICK / SLIDE"
				local name3, hint3 = "X-RAY", "GRAB + ATTACK"
				
				w, h = pw/4 / 3, 7
				x, y = gap2 + 5, ph - 30 - h
				
				if pl1 and pl1:IsValid() then
									
					white_bar.r = 255
					white_bar.g = 255
					white_bar.b = 255
					
					surface.SetDrawColor( Color( 0, 0, 0, 120 ) )
					draw.NoTexture()
					if !arena:IsChargeReady( slot1, 1 ) then
						self:PaintChargeBar( x, y, w, h, -5, 1 )
					end
					if !arena:IsChargeReady( slot1, 2 ) then
						self:PaintChargeBar( x + w + gap, y, w, h, -5, 1 )
					end
					if !arena:IsChargeReady( slot1, 3 ) then
						self:PaintChargeBar( x + w * 2 + gap * 2, y, w, h, -5, 1 )
					end
					
					local rate = RealTime() * 0.8
					local sin = math.sin( rate )
					local cos = math.cos( rate )
					
					if arena:IsChargeReady( slot1, 1 ) then
						draw.SimpleText( sin > 0 and name1 or hint1, "RagdollFightChargeDesc", x + w/2 - 5, y - h - 10, Color( 255, 255, 255, math.abs( sin * 220 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
					
					if arena:IsChargeReady( slot1, 2 ) then
						draw.SimpleText( sin > 0 and name2 or hint2, "RagdollFightChargeDesc", x + w + gap + w/2 - 5, y - h - 10, Color( 255, 255, 255, math.abs( sin * 220 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
					
					if arena:IsChargeReady( slot1, 3 ) then
						draw.SimpleText( sin > 0 and name3 or hint3, "RagdollFightChargeDesc", x + w * 2 + gap * 2 + w/2 - 5, y - h - 10, Color( 255, 255, 255, math.abs( sin * 220 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
					
					local col_flash = Color( 255, 255, 255, 220 + math.abs( cos * 35 ) )
					
					surface.SetDrawColor( arena:IsChargeReady( slot1, 1 ) and col_flash or white_bar )	
					self:PaintChargeBar( x, y, w * arena:GetChargeStatus( slot1, 1 ), h, -5, arena:IsChargeReady( slot1, 1 ) and 2 or 1 )
					surface.SetDrawColor( arena:IsChargeReady( slot1, 2 ) and col_flash or white_bar )	
					self:PaintChargeBar( x + w + gap, y, w * arena:GetChargeStatus( slot1, 2 ), h, -5, arena:IsChargeReady( slot1, 2 ) and 2 or 1 )
					surface.SetDrawColor( arena:IsChargeReady( slot1, 3 ) and col_flash or white_bar )	
					self:PaintChargeBar( x + w * 2 + gap * 2, y, w * arena:GetChargeStatus( slot1, 3 ), h, -5, arena:IsChargeReady( slot1, 3 ) and 2 or 1 )
				
				end
				
				local gap3 = gap2 + 5 + w * 3 + gap * 2
				
				x, y = pw - gap3, ph - 30 - h
				
				if pl2 and pl2:IsValid() then
					
					white_bar.r = 255
					white_bar.g = 255
					white_bar.b = 255
					
					white_bar.a = 220
					
					surface.SetDrawColor( Color( 0, 0, 0, 120 ) )
					draw.NoTexture()
					if !arena:IsChargeReady( slot2, 3 ) then
						self:PaintChargeBar( x, y, w, h, 5, 1 )
					end
					if !arena:IsChargeReady( slot2, 2 ) then
						self:PaintChargeBar( x + w + gap, y, w, h, 5, 1 )
					end
					if !arena:IsChargeReady( slot2, 1 ) then
						self:PaintChargeBar( x + w * 2 + gap * 2, y, w, h, 5, 1 )
					end
					
					local rate = RealTime() * 1
					local sin = math.sin( rate )
					local cos = math.cos( rate )
					
					if arena:IsChargeReady( slot2, 1 ) then
						draw.SimpleText( sin > 0 and name1 or hint1, "RagdollFightChargeDesc", x + w * 2 + gap * 2 + w/2, y - h - 10, Color( 255, 255, 255, math.abs( sin * 220 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
					
					if arena:IsChargeReady( slot2, 2 ) then
						draw.SimpleText( sin > 0 and name2 or hint2, "RagdollFightChargeDesc", x + w + gap + w/2, y - h - 10, Color( 255, 255, 255, math.abs( sin * 220 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
					
					if arena:IsChargeReady( slot2, 3 ) then
						draw.SimpleText( sin > 0 and name3 or hint3, "RagdollFightChargeDesc", x + w/2, y - h - 10, Color( 255, 255, 255, math.abs( sin * 220 ) ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
					end
					
					local col_flash = Color( 255, 255, 255, 220 + math.abs( cos * 35 ) )
					
					surface.SetDrawColor( arena:IsChargeReady( slot2, 1 ) and col_flash or white_bar )		
					self:PaintChargeBar( x + w * 2 + gap * 2 + w * ( 1 - arena:GetChargeStatus( slot2, 1 ) ), y, w * arena:GetChargeStatus( slot2, 1 ), h, 5, arena:IsChargeReady( slot2, 1 ) and 2 or 1 )
					surface.SetDrawColor( arena:IsChargeReady( slot2, 2 ) and col_flash or white_bar )	
					self:PaintChargeBar( x + w + gap + w * ( 1 - arena:GetChargeStatus( slot2, 2 ) ), y, w * arena:GetChargeStatus( slot2, 2 ), h, 5, arena:IsChargeReady( slot2, 2 ) and 2 or 1 )
					surface.SetDrawColor( arena:IsChargeReady( slot2, 3 ) and col_flash or white_bar )	
					self:PaintChargeBar( x + w * ( 1 - arena:GetChargeStatus( slot2, 3 ) ), y, w * arena:GetChargeStatus( slot2, 3 ), h, 5, arena:IsChargeReady( slot2, 3 ) and 2 or 1 )
				end
				
				self.ShowHintsDelay = self.ShowHintsDelay or 0
				
				if pl:KeyDown( IN_SCORE ) and self.ShowHintsDelay < CurTime( )then
					self.ShowHints = !self.ShowHints
					self.ShowHintsDelay = CurTime() + 0.5
				end
				
				if arena:GetPlayerNum() < 2 and self.ShowHints then
					
					for i=1, #self.HintText do
						
						local pressed = true
						
						if self.HintText[ i ].keys then
							for _, v in pairs( self.HintText[ i ].keys ) do
								if not pl:KeyDown( v ) then
									pressed = false
									break
								end
							end
						else
							pressed = false
						end
						
						local text_col = pressed and Color( 225, 50, 50, 250 ) or white_bar
						
						local txt = self.HintText[ i ].txt
						draw.SimpleText( txt, "RagdollFightDefault", pw/2, ph/2 + 25 * i, text_col, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
					end
					
				end
				
				
				
				for _, msg in pairs( self.Messages or {} ) do
					
					if not msg.time then
						msg.time = CurTime()
					end
					
					local fadeout = ( msg.time + msg.dur ) - CurTime()
					
					if ( msg.time + msg.dur ) > CurTime() then
						
						local font = msg.t == 1 and "RagdollFightBigMessage" or msg.t == 2 and "RagdollFightMedMessage" or "RagdollFightSmallMessage"
						
						surface.SetFont( font)
						local t_w, t_h = surface.GetTextSize( msg.text )
						local r_h = t_h * 1.2
						
						surface.SetDrawColor( Color( 0, 0, 0, 120 * math.Clamp( fadeout, 0, 1 ) ) )
						surface.DrawRect( 0, ph/2.5 - r_h/2, pw, r_h )
						
						draw.SimpleText( msg.text, font, pw/2, ph/2.5, Color( 255, 255, 255, fadeout * 220 ),TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
						
						return
					end

				end
				
				if #self.Messages > 0 then
					table.Empty( self.Messages )
				end
				
			end
			
			
		end
		base.Think = function( self )
			//self:MoveToFront()
			if !IsValid( self.Arena ) then
				self:Remove()
				return
			end
		end
			
	end
	
	
	net.Receive( "RagdollFightArenaRemovePlayer", function( len )

		local pl = LocalPlayer()
		
		if !IsValid( pl ) then return end
		
		pl.RagdollFightArena = nil
		pl.RagdollFightArenaSlot = nil
		
	end )	
	
	net.Receive( "RagdollFightArenaRemoveSpectator", function( len )

		local pl = LocalPlayer()
		
		if !IsValid( pl ) then return end
		
		pl.RagdollFightSpectator = nil
		pl.RagdollFightArenaSpectator = nil
		pl.RagdollFightArenaSlot = nil
		
	end )
	
	net.Receive( "RagdollFightArenaSendMessage", function( len )
		
		local pl = LocalPlayer()
		
		if !IsValid( pl ) then return end
		
		local t = net.ReadInt( 32 )
		local dur = net.ReadFloat( )
		local text = net.ReadString()
		
		if pl.RagdollFightArenaHUD then
			pl.RagdollFightArenaHUD:AddMessage( text, dur, t )
		end
		
	end )
	
	net.Receive( "RagdollFightArenaUpdateSpectator", function( len )

		local pl = LocalPlayer()
				
		if !IsValid( pl ) then return end
		
		local arena = net.ReadEntity()
		
		if pl.RagdollFightDummies then
			for k, v in pairs( pl.RagdollFightDummies ) do
				if v and v:IsValid() then
					v:Remove()
				end
			end
			table.Empty( pl.RagdollFightDummies )
		end
		
		if arena and arena:IsValid() then
			pl.RagdollFightSpectator = true
			pl.RagdollFightArenaSpectator = arena
			pl.RagdollFightArenaSlot = 1
						
			RagdollFightHUD( true )
		end

	end )	
	
	net.Receive( "RagdollFightArenaUpdatePlayer", function( len )

		local pl = LocalPlayer()
		
		if !IsValid( pl ) then return end
		
		local arena = net.ReadEntity()
		local slot = net.ReadInt( 32 )
		
		//clean up previous clientside dummies
		if pl.RagdollFightDummies then
			for k, v in pairs( pl.RagdollFightDummies ) do
				if v and v:IsValid() then
					v:Remove()
				end
			end
			table.Empty( pl.RagdollFightDummies )
		end

		if arena and arena:IsValid() and slot then
			pl.RagdollFightSpectator = nil
			pl.RagdollFightArenaSpectator = nil
			pl.RagdollFightArena = arena
			pl.RagdollFightArenaSlot = slot
			
			RagdollFightHUD()
		end
		
		
	end )	
	
end

function ENT:GetPlayer( slot )
	slot = math.Clamp( slot, 1, 2 )
	return self:GetDTEntity( slot )
end

function ENT:GetPlayerText( slot )
	slot = math.Clamp( slot, 1, 2 )
	return self:GetDTString( slot )
end

function ENT:GetPlayerHealth( slot )
	slot = math.Clamp( slot, 1, 2 )
	return self:GetDTInt( slot ) or 0
end

function ENT:GetCharge( slot )
	slot = math.Clamp( slot + 4, 5, 6 )
	return self:GetDTInt( slot )
end

function ENT:IsChargeReady( slot, num )
	local charge = self:GetChargeStatus( slot, num )
	return charge >= 1
end

function ENT:GetChargeStatus( slot, num )
	local charge = self:GetCharge( slot )
	local delta = ( charge - ( num - 1 ) * 33 ) / 33
	return math.Clamp( delta, 0, 1 )
end

function ENT:GetPlayerScore( slot )
	slot = math.Clamp( slot + 2, 3, 4 )
	return self:GetDTInt( slot ) or 0
end

function ENT:GetDirVector( slot )
	slot = math.Clamp( slot, 1, 2 )
	return self:GetDTVector( slot )
end

function ENT:GetRound()
	return self:GetDTInt( 7 )
end
	

function ENT:GetPlayerNum()
	local cnt = 0
	
	if IsValid( self:GetPlayer( 1 ) ) then
		cnt = cnt + 1
	end
	
	if IsValid( self:GetPlayer( 2 ) ) then
		cnt = cnt + 1
	end

	return cnt
end

function ENT:GetRagdollFighter( slot )
	slot = math.Clamp( slot + 2, 3, 4 )
	return self:GetDTEntity( slot )
end