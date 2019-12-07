AddCSLuaFile() 

if SERVER then

local fingerbones = {
	{
		//"ValveBiped.Bip01_L_Finger0",
		//"ValveBiped.Bip01_L_Finger01",
		//"ValveBiped.Bip01_L_Finger02",
		"ValveBiped.Bip01_L_Finger1",
		"ValveBiped.Bip01_L_Finger11",
		"ValveBiped.Bip01_L_Finger12",
		"ValveBiped.Bip01_L_Finger2",
		"ValveBiped.Bip01_L_Finger21",
		"ValveBiped.Bip01_L_Finger22",
		"ValveBiped.Bip01_L_Finger3",
		"ValveBiped.Bip01_L_Finger31",
		"ValveBiped.Bip01_L_Finger32",
		"ValveBiped.Bip01_L_Finger4",
		"ValveBiped.Bip01_L_Finger41",
		"ValveBiped.Bip01_L_Finger42",
	},
	{
		//"ValveBiped.Bip01_R_Finger0",
		//"ValveBiped.Bip01_R_Finger01",
		//"ValveBiped.Bip01_R_Finger02",
		"ValveBiped.Bip01_R_Finger1",
		"ValveBiped.Bip01_R_Finger11",
		"ValveBiped.Bip01_R_Finger12",
		"ValveBiped.Bip01_R_Finger2",
		"ValveBiped.Bip01_R_Finger21",
		"ValveBiped.Bip01_R_Finger22",
		"ValveBiped.Bip01_R_Finger3",
		"ValveBiped.Bip01_R_Finger31",
		"ValveBiped.Bip01_R_Finger32",
		"ValveBiped.Bip01_R_Finger4",
		"ValveBiped.Bip01_R_Finger41",
		"ValveBiped.Bip01_R_Finger42",
	}
}

local function RandomStanceNum( stance )
	if not RagdollFight.Stances[ stance ] then return 1 end
	local cnt = #RagdollFight.Stances[ stance ]
	
	return math.random( 1, cnt )
end

local bone_to_hitbox = {
	["ValveBiped.Bip01_L_Hand"] = "left_hand",
	["ValveBiped.Bip01_R_Hand"] = "right_hand",
	["ValveBiped.Bip01_L_Foot"] = "left_leg",
	["ValveBiped.Bip01_R_Foot"] = "right_leg",
}

local function ActivateHitbox( ent, lh, rh, ll, rl, attack_type, force, force_ragdoll, dmg, world_damage )
	if ent and ent:IsValid() then
		ent.HitDetection.left_hand = false
		ent.HitDetection.right_hand = false
		ent.HitDetection.left_leg = false
		ent.HitDetection.right_leg = false
		
		ent.AttackForce = nil
		ent.AttackType = RAGDOLL_ATTACK_ANY
		ent.AttackForceRagdoll = nil
		ent.AttackForceRagdollDamage = nil
		ent.AttackDamage = 0
		
		if lh then
			ent.HitDetection.left_hand = true
		end
		if rh then
			ent.HitDetection.right_hand = true
		end
		if ll then
			ent.HitDetection.left_leg = true
		end
		if rl then
			ent.HitDetection.right_leg = true
		end
		
		if attack_type then 
			ent.AttackType = attack_type
		end
		
		if force and ent:GetOwner() and ent:GetOwner():IsValid() then
			ent.AttackForce = ent:GetOwner():GetForward() * force
		end
		
		if force_ragdoll then
			ent.AttackForceRagdoll = CurTime() + 1.5
		end
		
		if world_damage then
			ent.AttackForceRagdollDamage = world_damage
		end
		
		if dmg then
			ent.AttackDamage = dmg
		end
		
		
		
	end
end

local hitsound = Sound( "npc/vort/foot_hit.wav" )
local hitsound2 = Sound( "ambient/voices/citizen_punches2.wav" )

util.AddNetworkString( "RagdollFightUpdateRagdoll" )

function RagdollFightSpawnRagdoll( pl, cmd, args )

	local mdl = pl:GetModel()
	local skin = pl:GetSkin()
	local ang = pl:GetAngles()
	local pos = pl:GetPos()
	
	local ent = ents.Create( "prop_ragdoll" )
	if ( !IsValid( ent ) ) then return end
	if IsValid( pl.Ragdoll ) then return end

	ent:SetModel( mdl )
	ent:SetSkin( skin )
	ent:SetAngles( ang )
	ent:SetPos( pos )
	ent:Spawn()
	ent:Activate()
	ent:SetOwner( pl )
	pl.Ragdoll = ent
	ent.IsRagdollFighter = true
	ent:SetCollisionGroup( COLLISION_GROUP_WEAPON  )
	ent:CollisionRulesChanged()
	pl:SetRenderMode( RENDERMODE_NONE )
	pl.OldJumpPower = pl:GetJumpPower()
	pl:SetJumpPower( 230 )
	pl:StripWeapons()
	ent.Stance = RAGDOLL_STANCE_IDLE
	ent.StanceNum = 1
	ent.LastStance = ent.Stance
	ent.LastStanceNum = ent.StanceNum
	ent.StanceDuration = -1
	ent.Grab = false
	ent.GrabbedObject = nil
	ent._Constraints = nil
	ent.RagdollMode = false
	ent.OriginalMass = {}
	ent.OriginalDamping = {}
	ent.HitDetection = { left_hand = false, right_hand = false, left_leg = false, right_leg = false }
	ent.HitPhysBones = {}
	ent.AttackType = nil
	ent.AttackForce = nil
	ent:SetCustomCollisionCheck( true ) 
	pl:SetCustomCollisionCheck( true )
	
	timer.Simple( 0.1, function() 
		net.Start( "RagdollFightUpdateRagdoll" )
			net.WriteInt( ent:EntIndex(), 32 )
		net.Send( pl )
	end)
	
	ent.ChangeFace = function( self )
		local FlexNum = self:GetFlexNum() - 1
		if ( FlexNum <= 0 ) then return end
		
		for i=0, FlexNum-1 do
			if math.random(3) == 3 then
				self:SetFlexWeight( i, math.Rand(0,1.1) )
			end
		end
		
		self:SetFlexScale(math.random(-10,10))
	end
	
	ent.RagdollTakeDamage = function( self, am )
		local owner = self:GetOwner()
		if owner and owner:IsValid() and owner.RagdollFightArena and owner.RagdollFightArena:IsValid() then
			local arena = owner.RagdollFightArena
			local my_slot = owner.RagdollFightArenaSlot
			
			arena:PlayerTakeDamage( my_slot, am )

		end
	end
	
	ent.RagdollTakeXRayDamage = function( self, num, b_name )
		local owner = self:GetOwner()
		if owner and owner:IsValid() and owner.RagdollFightArena and owner.RagdollFightArena:IsValid() then
			
			local arena = owner.RagdollFightArena
			local my_slot = owner.RagdollFightArenaSlot
			
			local hp = math.min( arena:GetPlayerHealth( my_slot ), RAGDOLL_DAMAGE_XRAY )
			
			local dmg = math.ceil( hp / num )
			
			if not self.XRayDamage then
				self.XRayDamage = dmg
			end
			
			arena:PlayerTakeDamage( my_slot, self.XRayDamage )
			
			if arena:GetPlayerHealth( my_slot ) <= 0 then
				self.DontForceRagdoll = true
				self.ForceResetDamping = true
			end
			
			local b = self:LookupBone( b_name )
								
			if b then
				local m = self:GetBoneMatrix( b )
				if m then
					local bone_pos = m:GetTranslation()
					local bone_ang = m:GetAngles()
					if bone_pos and bone_ang then
						local e = EffectData()
							e:SetOrigin( bone_pos )
							e:SetNormal( VectorRand() )
							e:SetScale( 0.2 )
							e:SetMagnitude( 1 )
						util.Effect( "HunterDamage", e, nil, true )
						local e = EffectData()
							e:SetOrigin( bone_pos )
							e:SetNormal( VectorRand() )
							e:SetScale( 6 )
							e:SetFlags( 3 )
							e:SetColor( 0 )
						util.Effect( "bloodspray", e, nil, true )
					end
				end
			end

		end
	end
	
	ent.HasPowerup = function( self, power )
		local owner = self:GetOwner()
		if owner and owner:IsValid() and owner.RagdollFightArena and owner.RagdollFightArena:IsValid() then
			local arena = owner.RagdollFightArena
			local my_slot = owner.RagdollFightArenaSlot
			
			return arena:IsChargeReady( my_slot, power )

		end
		return false
	end
	
	ent.ConsumeCharge = function( self, power )
		local owner = self:GetOwner()
		if owner and owner:IsValid() and owner.RagdollFightArena and owner.RagdollFightArena:IsValid() then
			local arena = owner.RagdollFightArena
			local my_slot = owner.RagdollFightArenaSlot
			
			arena:SetCharge( my_slot, arena:GetCharge( my_slot ) - power * 33 )//- 99 - power * 33

		end
	end
	
	for i=0, ent:GetPhysicsObjectCount() - 1 do
		local phys_bone = ent:GetPhysicsObjectNum( i )
		
		local rag_bone = ent:TranslatePhysBoneToBone( i )
		local bone_name = ent:GetBoneName( rag_bone )
				
		if phys_bone and phys_bone:IsValid() then
		
			phys_bone:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
			
			local mass = phys_bone:GetMass() or 1
			ent.OriginalMass[ i ] = mass
			
			local lin_d, ang_d = phys_bone:GetDamping()
			
			ent.OriginalDamping[ i ] = { lin_d, ang_d }
			
		end
	end
	
	
	for k, v in pairs( bone_to_hitbox ) do
		local bone = ent:LookupBone( k )
		if bone then
			local physbone_id = ent:TranslateBoneToPhysBone( bone )
			local phys_bone = ent:GetPhysicsObjectNum( physbone_id )
			if phys_bone and phys_bone:IsValid() then
				ent.HitPhysBones[ v ] = phys_bone
			end
		end
	end
	
	local function RagdollCallback( self, data )
		
		local head_bonename = "ValveBiped.Bip01_Head1"
		local head_bone = self:LookupBone( head_bonename )
		
		if not head_bone then
			head_bonename = "ValveBiped.Bip01_Spine4"
			head_bone = self:LookupBone( head_bonename )
		end
				
		local head_physbone_id = self:TranslateBoneToPhysBone( head_bone )
		local head_physbone = self:GetPhysicsObjectNum( head_physbone_id )
		
		if not self.HeadPhysBone then
			self.HeadPhysBone = head_physbone
		end
		
		if self.RagdollMode or ( self.RagdollModeTime and self.RagdollModeTime >= CurTime() ) then
			if ( self.NextBreakSound or 0 ) <= CurTime() and data.HitEntity and ( data.HitEntity:IsWorld() or data.HitEntity.IsArena ) and data.Speed > 100 then// 
				if not self.FixBones then
					self:EmitSound( "physics/body/body_medium_break"..math.random(2,4)..".wav", 75, math.random( 95, 115 ) )
					util.Decal("Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
					local e = EffectData()
						e:SetOrigin( data.HitPos )
						e:SetNormal( data.HitNormal )
					util.Effect( "BloodImpact", e, nil, true )
					self.NextBreakSound = CurTime() + 0.4
				end
				if self.WasThrown then
					self:RagdollTakeDamage( RAGDOLL_DAMAGE_GRAB_THROW * self.WasThrown )
					self.NextGrab = CurTime() + 2
					self.WasThrown = nil
					
					if data.PhysObject == self.HeadPhysBone then
						self:ChangeFace()
					end
					
				end
			end
		end
		
		if self.Attack and self.Attack >= CurTime() and !self.Grab and !IsValid( self.GrabbedObject ) then
			if data.PhysObject and data.HitEntity:IsValid() and data.HitObject:IsValid() and data.HitEntity ~= self and data.HitEntity.IsRagdollFighter then
				for k, v in pairs( self.HitDetection ) do
					if v and self.HitPhysBones[ k ] then
						if data.HitEntity.Blocking and data.HitEntity.Blocking == self.AttackType then
							self:EmitSound( "physics/body/body_medium_impact_soft"..math.random(5,7)..".wav", 75, math.random( 95, 115 ) )
						else
							local e = EffectData()
								e:SetOrigin( data.HitPos )
								e:SetNormal( data.HitNormal )
							util.Effect( "BloodImpact", e, nil, true )
							
							util.Decal("Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
							self:EmitSound( hitsound, 75, math.random( 95, 115 ) )
							
							if self.AttackDamage then
								data.HitEntity:RagdollTakeDamage( self.AttackDamage )
								if data.HitObject == data.HitEntity.HeadPhysBone and data.HitEntity.ChangeFace then
									data.HitEntity:ChangeFace()
								end
							end
							
							if self.AttackForce and data.HitEntity:GetOwner() and data.HitEntity:GetOwner():IsValid() then
								
								data.HitEntity:GetOwner():SetGroundEntity( NULL )
								data.HitEntity:GetOwner():SetLocalVelocity( self.AttackForce )
								
								if self.AttackForceRagdoll and self:GetOwner() and self:GetOwner():IsValid() then
								
									data.HitEntity.RagdollModeTime = self.AttackForceRagdoll
									RagdollFightApplyForce( data.HitEntity, self.AttackForce , self.AttackForce:Length() * 2 )
									
									if self.AttackForceRagdollDamage then
										data.HitEntity.WasThrown = self.AttackForceRagdollDamage
									end
								end
							end
																				
						end
						self.Attack = nil
						ActivateHitbox( self )
						break
					end
				end
			end
		end
		
		if self.Grab and ( self.GrabTime or 0 ) >= CurTime() and !IsValid(self.GrabbedObject) then
			
			local lh_bonename = "ValveBiped.Bip01_L_Hand"
			local lh_bone = self:LookupBone( lh_bonename )
				
			local lh_physbone_id = self:TranslateBoneToPhysBone( lh_bone )
			local lh_physbone = self:GetPhysicsObjectNum( lh_physbone_id )
			
			local rh_bonename = "ValveBiped.Bip01_R_Hand"
			local rh_bone = self:LookupBone( rh_bonename )
				
			local rh_physbone_id = self:TranslateBoneToPhysBone( rh_bone )
			local rh_physbone = self:GetPhysicsObjectNum( rh_physbone_id )
			
			
			
			if data.PhysObject and ( data.PhysObject == lh_physbone or data.PhysObject == rh_physbone ) and data.HitEntity:IsValid() and data.HitObject:IsValid() and data.HitEntity ~= self then
				
				if not ( self.RagdollMode or self.RagdollModeTime or data.HitEntity.NextGrab and data.HitEntity.NextGrab > CurTime() ) then
					if data.HitEntity.IsRagdollFighter and ( self:GetOwner():Crouching() and data.HitEntity.Blocking == RAGDOLL_BLOCK_CROUCH or !self:GetOwner():Crouching() and data.HitEntity.Blocking == RAGDOLL_BLOCK_NORMAL ) then return end
					local self_phys_num = data.PhysObject == lh_physbone and lh_physbone_id or rh_physbone_id
					local hitent_phys_num = 0
					
					for i=0, data.HitEntity:GetPhysicsObjectCount() - 1 do
						local cur = data.HitEntity:GetPhysicsObjectNum( i )
						if cur and cur == data.HitObject then
							hitent_phys_num = i
							break
						end
					end
					
					if data.HitEntity.IsRagdollFighter then
						data.HitEntity.RagdollMode = true
						RagdollFightRemoveMass( data.HitEntity )
						self.GrabDuration = CurTime() + 3
						data.HitEntity.GrabbedBy = self
					end
					
					self.ToWeld = { ent1 = self, ent2 = data.HitEntity, bone1 = self_phys_num, bone2 = hitent_phys_num, bone_alt = ( data.PhysObject == lh_physbone and rh_physbone_id or lh_physbone_id ) }//
					self.GrabbedObject = data.HitEntity
					data.HitEntity.WasThrown = nil
				end
			end
		
		end
		
	end

	ent:AddCallback( "PhysicsCollide", RagdollCallback )
	
	for i=1, 2 do 
		for k, v in pairs( fingerbones[ i ] ) do
			local bone = ent:LookupBone( v )
			if bone then
				ent:ManipulateBoneAngles( bone, Angle( 0, -60, 0 ) )
			end
		end
	end
	
	
	RagdollFight.Ragdolls[tostring(ent)] = ent
	
	/*undo.Create( "Ragdoll" )
		undo.SetPlayer( pl )
		undo.AddEntity( ent )
		undo.AddFunction( function( tab, arg2 )
				if arg2 and arg2:IsValid() then
					arg2:SetRenderMode( RENDERMODE_NORMAL ) 
					arg2:SetJumpPower( arg2.OldJumpPower or 200 )
					//arg2:SetCollisionGroup( COLLISION_GROUP_PLAYER ) 
					GAMEMODE:PlayerLoadout( arg2 )
					if IsValid( arg2.Ragdoll ) then
						if arg2.Ragdoll._Constraints then
							constraint.RemoveConstraints( arg2.Ragdoll, "Weld" ) 
							//arg2.Ragdoll.Constraints:Remove()
							//arg2.Ragdoll.Constraints = nil
						end
						RagdollFight.Ragdolls[tostring(arg2.Ragdoll)] = nil
					end
				end
			end, pl )
	undo.Finish( "Ragdoll (" .. tostring( mdl ) .. ")" )*/
	
	ent:ChangeFace()
	

end
//concommand.Add( "rag_create", RagdollFightSpawnRagdoll )

function RagdollFightApplyForce( ent, dir, power, noang )

	if ent then
		local pow = power / ent:GetPhysicsObjectCount()
		for i=0, ent:GetPhysicsObjectCount() - 1 do
			local phys_bone = ent:GetPhysicsObjectNum( i )
			if phys_bone and phys_bone:IsValid() then
				phys_bone:ApplyForceCenter( dir * power ) 
				if not noang then
					phys_bone:AddAngleVelocity( VectorRand() * power ) 
				end
			end
		end
	end
end

function RagdollFightRemoveMass( ent )
	if ent and ent.OriginalMass then
		for i=0, ent:GetPhysicsObjectCount() - 1 do
			local phys_bone = ent:GetPhysicsObjectNum( i )
			if phys_bone and phys_bone:IsValid() then
				local mass = 1
				phys_bone:SetMass( mass )
			end
		end
	end
end

function RagdollFightResetMass( ent )
	if ent and ent.OriginalMass then
		for i=0, ent:GetPhysicsObjectCount() - 1 do
			local phys_bone = ent:GetPhysicsObjectNum( i )
			if phys_bone and phys_bone:IsValid() then
				local mass = ent.OriginalMass[ i ] or 1
				phys_bone:SetMass( mass )
			end
		end
	end
end

function RagdollFightChangeDamping( ent, lin, ang )
	if ent and ent.OriginalMass then
		for i=0, ent:GetPhysicsObjectCount() - 1 do
			local phys_bone = ent:GetPhysicsObjectNum( i )
			if phys_bone and phys_bone:IsValid() then
				phys_bone:SetDamping( lin or 1, ang or 1 )
			end
		end
	end
end

function RagdollFightResetDamping( ent )
	if ent and ent.OriginalDamping then
		for i=0, ent:GetPhysicsObjectCount() - 1 do
			local phys_bone = ent:GetPhysicsObjectNum( i )
			if phys_bone and phys_bone:IsValid() then
				local lin = ent.OriginalDamping[ i ][ 1 ] or 1
				local ang = ent.OriginalDamping[ i ][ 2 ] or 1
				phys_bone:SetDamping( lin, ang )
			end
		end
	end
end

function RagdollFightRemoveRagdoll( pl )
	
	if pl.Ragdoll and pl.Ragdoll:IsValid() then
		RagdollFight.Ragdolls[tostring(pl.Ragdoll)] = nil
		pl.Ragdoll:Remove()
		pl:SetRenderMode( RENDERMODE_NORMAL ) 
		pl:SetJumpPower( pl.OldJumpPower or 200 )
		//pl:SetCollisionGroup( COLLISION_GROUP_PLAYER ) 
		//GAMEMODE:PlayerLoadout( pl )
		hook.Run( "PlayerLoadout", pl ) 
		pl.Ragdoll = nil
	end
	
end

local function RagdollFightThink( )
	if RagdollFight.Ragdolls then
		for k, v in pairs( RagdollFight.Ragdolls ) do
			if v and v:IsValid() and !IsValid(v:GetOwner()) then
				RagdollFight.Ragdolls[tostring(v)] = nil
				v:Remove()
				continue
			end
			if v and v:IsValid() and v:GetOwner() and v:GetOwner():IsValid() and v:GetOwner():Alive() then
				local pl = v:GetOwner()
				
				if #pl:GetWeapons() > 0 then pl:StripWeapons() end
				
				if v.ToWeld then
					v._Constraints = true
					constraint.Weld( v.ToWeld.ent1, v.ToWeld.ent2, v.ToWeld.bone1, v.ToWeld.bone2, 0, false, false )
					constraint.Weld( v.ToWeld.ent1, v.ToWeld.ent2, v.ToWeld.bone_alt, v.ToWeld.bone2, 0, false, false )
					v.ToWeld = nil
				end
				
				if v.Blocking and v:GetOwner():KeyDown( IN_RELOAD ) then
					if v:GetOwner():Crouching() and v.Blocking ~= RAGDOLL_BLOCK_CROUCH then
						v.Blocking = RAGDOLL_BLOCK_CROUCH
					end
					if !v:GetOwner():Crouching() and v.Blocking ~= RAGDOLL_BLOCK_NORMAL then
						v.Blocking = RAGDOLL_BLOCK_NORMAL
					end
				end
				
				local reference_bonename = "ValveBiped.Bip01_Pelvis"
				local reference_bone = pl:LookupBone( reference_bonename )
				
				local reference_physbone_id = v:TranslateBoneToPhysBone( reference_bone )
				local reference_physbone = v:GetPhysicsObjectNum( reference_physbone_id )
				
				local bone_stance = v.Stance and RagdollFight.Stances[ v.Stance ][ v.StanceNum ]
				local last_stance = v.LastStance and RagdollFight.Stances[ v.LastStance ][ v.LastStanceNum ]
				
				local idle_stance = IsValid( v.GrabbedObject ) and RAGDOLL_STANCE_GRAB_IDLE or RAGDOLL_STANCE_IDLE
				
				
				if v:GetOwner():KeyDown( IN_RELOAD ) and !v.RagdollMode and !IsValid( v.GrabbedObject ) and !v.Grab then
					v.Blocking = v:GetOwner():Crouching() and RAGDOLL_BLOCK_CROUCH or RAGDOLL_BLOCK_NORMAL
				end
				
				if v.Blocking then idle_stance = RAGDOLL_STANCE_BLOCK end
				
				if v.StanceDuration and v.StanceDuration < CurTime() and v.Stance ~= idle_stance then
					v.Stance = idle_stance
					v.StanceNum = RandomStanceNum( idle_stance )
					v.StanceDuration = -1
				end
					
				local lerp_dur = 0.15
					
				if ( v.Stance ~= v.LastStance or v.StanceNum ~= v.LastStanceNum ) and not v.Lerping then
					v.Lerping = CurTime() + lerp_dur
					if v.LastBonePos then
						table.Empty( v.LastBonePos )
					else
						v.LastBonePos = {}
					end
				end
				
				if v.RagdollModeTime and v.RagdollModeTime < CurTime() then
					if v.FixBones then
						v.FixBones = nil
					else
						if v:GetOwner().RagdollFightArena and v:GetOwner().RagdollFightArena:IsValid() then
							local safe_pos = v:GetOwner().RagdollFightArena:ConvertIntoSafePos( v:GetPos() )
							v:GetOwner():SetPos( safe_pos )
							RagdollFightResetMass( v )
							v:GetOwner().RagdollFightArena:ClearPos( v:GetOwner(), v:GetOwner():GetPos() )//v:GetOwner():GetPos()
						else
							v:GetOwner():SetPos( v:GetPos() )
						end
					end
					v.RagdollModeTime = nil
				end
				
				if v.GrabDuration and v.GrabDuration < CurTime() or v.ForceDrop then
					v.GrabDuration = nil
					v.ForceDrop = nil
					if v.GrabbedObject and v.GrabbedObject:IsValid() then
						if v.GrabbedObject.IsRagdollFighter then
							v.GrabbedObject.NextGrab = CurTime() + 4
							RagdollFightResetMass( v.GrabbedObject )
						end
						v.GrabbedObject.GrabbedBy = nil
						v.GrabbedObject = nil
						v.Grab = false
					end
					if v._Constraints then
						constraint.RemoveConstraints( v, "Weld" ) 
					end
				end
				
				if v.ThrowTime and v.ThrowTime < CurTime() then
					v.ThrowTime = nil
				end
				
				
				local arena = IsValid( v:GetOwner().RagdollFightArena ) and v:GetOwner().RagdollFightArena
				
				
				if v.RagdollMode or v.RagdollModeTime and v.RagdollModeTime >= CurTime() or arena and v:GetOwner().RagdollFightArenaSlot and arena:GetPlayerHealth( v:GetOwner().RagdollFightArenaSlot ) <= 0 and !( v.XRay and v.XRayTime and v.XRayTime > CurTime() ) then
				
					v.Blocking = nil
					
					if v.ForceResetDamping then
						RagdollFightResetDamping( v )
						v.ForceResetDamping = nil
					end
				
					if not v.FixBones then
						if v:GetOwner():GetCollisionGroup() ~= COLLISION_GROUP_IN_VEHICLE then
							v:GetOwner():SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
							//v:GetOwner():CollisionRulesChanged()
						end
					end
					
					if not v.FixBones then
						if v:GetCollisionGroup() ~= COLLISION_GROUP_PLAYER then
							v:SetCollisionGroup( COLLISION_GROUP_PLAYER )
							v:CollisionRulesChanged()
						end
					end
					
					if !IsValid(v.GrabbedBy) then
						if v.RagdollMode then
							v.RagdollMode = false
							v.RagdollModeTime = CurTime() + 1.5
						end
					end
				
				else 
					
					if v:GetOwner():GetCollisionGroup() == COLLISION_GROUP_IN_VEHICLE then
						v:GetOwner():SetCollisionGroup( COLLISION_GROUP_PLAYER )
					end
					
					if v:GetCollisionGroup() ~= COLLISION_GROUP_WEAPON then
						v:SetCollisionGroup( COLLISION_GROUP_WEAPON )
						v:CollisionRulesChanged() 
					end
					
					
					if v.XRay and v.XRayTime and v.XRayTime > CurTime() and arena and arena:IsValid() then
					
						local xray_num = #RagdollFight.XRayStances[ v.XRayIndex or 1 ]
						
						local mini_dur = v.XRayDuration / xray_num
						local xray_lerp_dur = math.min( mini_dur / 3, 0.2 )//math.min( mini_dur / 3, 0.15 )
						
						if not v.XRayCurMove then
							v.XRayDamage = nil
							v.XRayCurMove = 1
							if v.XRay == RAGDOLL_XRAY_VICTIM then
								v:EmitSound( "physics/body/body_medium_break"..math.random(2,4)..".wav", 75, math.random( 55, 65 ) )
								v:EmitSound( "vo/npc/male01/pain0"..math.random(7,9)..".wav", 120, math.random( 45, 55 ) )
								v:EmitSound( "physics/wood/wood_strain"..math.random(2,4)..".wav", 130, math.random( 65, 75 ) )
								
								if RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].extra_sound and IsValid( v.XRayAttacker ) then
									RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].extra_sound( v.XRayAttacker )
								end
								
								v:RagdollTakeXRayDamage( xray_num, RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].bone )
								
							end
							
							if not v.XRayLerping then
								v.XRayLerping = CurTime() + xray_lerp_dur
								if v.XRayLastBonePos then
									table.Empty( v.XRayLastBonePos )
								else
									v.XRayLastBonePos = {}
								end
							end
							
						end
						
						if ( v.XRayTime - v.XRayDuration + v.XRayCurMove * mini_dur ) < CurTime() and v.XRayCurMove < xray_num then
							v.XRayCurMove = math.Clamp( v.XRayCurMove + 1, 1, xray_num )
							if v.XRay == RAGDOLL_XRAY_VICTIM then
								v:EmitSound( "physics/body/body_medium_break"..math.random(2,4)..".wav", 75, math.random( 55, 65 ) )
								v:EmitSound( "vo/npc/male01/pain0"..math.random(7,9)..".wav", 120, math.random( 45, 55 ) )
								v:EmitSound( "physics/wood/wood_strain"..math.random(2,4)..".wav", 130, math.random( 65, 75 ) )
								
								if RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].extra_sound and IsValid( v.XRayAttacker ) then
									RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].extra_sound( v.XRayAttacker )
								end
								
								v:RagdollTakeXRayDamage( xray_num, RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].bone )
							end
							
							//if not v.XRayLerping then
								v.XRayLerping = CurTime() + xray_lerp_dur
								if v.XRayLastBonePos then
									table.Empty( v.XRayLastBonePos )
								else
									v.XRayLastBonePos = {}
								end
							//end
							
						end
						
						local xray_stance = RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].data
						
						local attacker = v.XRayAttacker
						local victim = v.XRayVictim
						
						if v.XRay == RAGDOLL_XRAY_VICTIM and !IsValid( attacker ) then
							v.XRay = nil
							v.XRayTime = nil
							return
						end
						
						if v.XRay == RAGDOLL_XRAY_ATTACKER and !IsValid( victim ) then
							v.XRay = nil
							v.XRayTime = nil
							return
						end
						
						local reference_bonename = "ValveBiped.Bip01_Pelvis"
						local reference_bone = pl:LookupBone( reference_bonename )
						
						if v.XRay == RAGDOLL_XRAY_VICTIM and attacker then
							reference_bone = attacker:LookupBone( reference_bonename )
						end
				
						local reference_physbone_id = v:TranslateBoneToPhysBone( reference_bone )
						local reference_physbone = v:GetPhysicsObjectNum( reference_physbone_id )
						
						if v.XRay == RAGDOLL_XRAY_VICTIM and attacker then
							reference_physbone_id = attacker:TranslateBoneToPhysBone( reference_bone )
							reference_physbone = attacker:GetPhysicsObjectNum( reference_physbone_id )
						end
						
						for i=0, v:GetPhysicsObjectCount() - 1 do
							
							local phys_bone = v:GetPhysicsObjectNum( i )
							local rag_bone = pl:TranslatePhysBoneToBone( i )
							local bone_name = v:GetBoneName( rag_bone )
							local bone = pl:LookupBone( bone_name )
							
							if xray_stance and xray_stance[ v.XRay ] and xray_stance[ v.XRay ][ bone_name ] and reference_physbone then
								if bone and phys_bone and phys_bone:IsValid() and not xray_stance[ v.XRay ][ bone_name ].ignore then
									
									local m = pl:GetBoneMatrix( reference_bone )
									
									if v.XRay == RAGDOLL_XRAY_VICTIM and attacker then
										m = attacker:GetBoneMatrix( reference_bone )
									end
									
									if m then
										
										local angles = v.XRayAngles or arena:GetAngles()//pl:GetAngles()
										
										//hacky way to adjust offset for some moves
										if v.XRay == RAGDOLL_XRAY_ATTACKER then
											
											if v.XRay == RAGDOLL_XRAY_ATTACKER and v.XRayFixHeight then
												m:SetTranslation( Vector( m:GetTranslation().x, m:GetTranslation().y, v.XRayFixHeight ) )// m:GetTranslation() + v.XRayFixHeight
											end
											
											if v.XRay == RAGDOLL_XRAY_ATTACKER and RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].offset then
												m:SetTranslation( m:GetTranslation() + RagdollFight.XRayStances[ v.XRayIndex or 1 ][ v.XRayCurMove ].offset )
											end
											
										end
										
										local pos, ang = LocalToWorld( xray_stance[ v.XRay ][ bone_name ].pos, xray_stance[ v.XRay ][ bone_name ].ang, m:GetTranslation(), angles )
										
										if v.XRayLerping then
											if not v.XRayLastBonePos[ bone_name ] then
												local temp_ang = angles
												temp_ang.p = 0
												local temp_pos2, temp_ang2 = WorldToLocal( phys_bone:GetPos(), phys_bone:GetAngles(), reference_physbone:GetPos(), temp_ang )
												v.XRayLastBonePos[ bone_name ] = { pos = temp_pos2, ang = temp_ang2  }
											end
											if v.XRayLerping >= CurTime() then
												local delta = math.Clamp( 1 - ( v.XRayLerping - CurTime() )/xray_lerp_dur, 0, 1 )

												local lerp_pos = LerpVector( delta, v.XRayLastBonePos[ bone_name ].pos, xray_stance[ v.XRay ][ bone_name ].pos ) 
												local lerp_ang = LerpAngle( delta, v.XRayLastBonePos[ bone_name ].ang, xray_stance[ v.XRay ][ bone_name ].ang ) 
												pos, ang = LocalToWorld( lerp_pos, lerp_ang, m:GetTranslation(), angles )
												
											else
												v.XRayLerping = nil
											end
										end
										
										if pos and ang then
											
											phys_bone:Wake()
											//phys_bone:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG ) 
											//phys_bone:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS ) 
											phys_bone:SetMaterial( "zombieflesh" )									
											phys_bone:SetPos( pos )
											phys_bone:SetAngles( ang )
										end
										
									end
								end
							end
							
						end
						
						
					else
					
						if v:GetOwner():GetMoveType() == MOVETYPE_NONE then
							v:GetOwner():SetMoveType( MOVETYPE_WALK )
							RagdollFightResetDamping( v )
							//v.RagdollModeTime = CurTime() + 1.5
						end
						
						if v.XRay and v.XRayTime and v.XRayTime < CurTime() then
							
							if v.XRay == RAGDOLL_XRAY_VICTIM then
								if v.DontForceRagdoll then
									v.DontForceRagdoll = nil
								else
									v.RagdollModeTime = CurTime() + 1.5
								end
							end
							
							v.XRay = nil
							v.XRayTime = nil
							RagdollFightResetDamping( v )
							
						end
						
						if v.XRayCurMove then
							v.XRayCurMove = nil
						end
						
				
						for i=0, v:GetPhysicsObjectCount() - 1 do
							local phys_bone = v:GetPhysicsObjectNum( i )
							local rag_bone = pl:TranslatePhysBoneToBone( i )
							local bone_name = v:GetBoneName( rag_bone )
							local bone = pl:LookupBone( bone_name )
																
							if bone_stance and bone_stance[ bone_name ] and reference_physbone then
								if bone and phys_bone and phys_bone:IsValid() and not bone_stance[ bone_name ].ignore then
									
									local m = pl:GetBoneMatrix( reference_bone )
									if m then
										
										if v.Stance == RAGDOLL_STANCE_SLIDE then
											m:SetTranslation( m:GetTranslation() - vector_up * 20 ) 
										end
										
										local pos, ang = LocalToWorld( bone_stance[ bone_name ].pos, bone_stance[ bone_name ].ang, m:GetTranslation(), pl:GetAngles() )
										
										
										if v.Lerping then
											if not v.LastBonePos[ bone_name ] then
												local temp_ang = pl:GetAngles()
												temp_ang.p = 0
												local temp_pos2, temp_ang2 = WorldToLocal( phys_bone:GetPos(), phys_bone:GetAngles(), reference_physbone:GetPos(), temp_ang )
												v.LastBonePos[ bone_name ] = { pos = temp_pos2, ang = temp_ang2  }
											end
											if v.Lerping >= CurTime() and last_stance then
												local delta = math.Clamp( 1 - ( v.Lerping - CurTime() )/lerp_dur, 0, 1 )
												
												if last_stance[ bone_name ] then
													local lerp_pos = LerpVector( delta, last_stance[ bone_name ].pos, bone_stance[ bone_name ].pos ) 
													local lerp_ang = LerpAngle( delta, last_stance[ bone_name ].ang, bone_stance[ bone_name ].ang ) 
													pos, ang = LocalToWorld( lerp_pos, lerp_ang, m:GetTranslation(), pl:GetAngles() )
												else
													local lerp_pos = LerpVector( delta, v.LastBonePos[ bone_name ].pos, bone_stance[ bone_name ].pos ) 
													local lerp_ang = LerpAngle( delta, v.LastBonePos[ bone_name ].ang, bone_stance[ bone_name ].ang ) 
													pos, ang = LocalToWorld( lerp_pos, lerp_ang, m:GetTranslation(), pl:GetAngles() )
												end
											else
												v.LastStance = v.Stance
												v.LastStanceNum = v.StanceNum
												v.Lerping = nil
											end
										end
										
										if pos and ang then
											
											phys_bone:Wake()
											//phys_bone:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG ) 
											//phys_bone:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS ) 
											phys_bone:SetMaterial( "zombieflesh" )									
											phys_bone:SetPos( pos )
											phys_bone:SetAngles( ang )
											phys_bone:SetVelocity( pl:GetVelocity() )
											
										end
									end
									
								end
							else
								if bone and phys_bone and phys_bone:IsValid() then
									
									local m = pl:GetBoneMatrix( bone )
									if m then
									
										if v.Stance == RAGDOLL_STANCE_SLIDE then
											m:SetTranslation( m:GetTranslation() - vector_up * 20 ) 
										end
									
										local pos, ang = m:GetTranslation(), m:GetAngles()
										if pos and ang then
										
											phys_bone:Wake()
											//phys_bone:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG ) 
											//phys_bone:AddGameFlag( FVPHYSICS_NO_SELF_COLLISIONS ) 
											phys_bone:SetMaterial( "zombieflesh" )
											phys_bone:SetPos( pos )
											phys_bone:SetAngles( ang )
											phys_bone:SetVelocity( pl:GetVelocity() )
											
										end
									end
								end
							end
						end
					end
				
				end
			end
		end
	end
end
hook.Add( "Think", "RagdollFightThink", RagdollFightThink )

local IdleActivity = ACT_HL2MP_IDLE_FIST
local IdleActivityTranslate = {}
IdleActivityTranslate[ ACT_MP_STAND_IDLE ]					= IdleActivity
IdleActivityTranslate[ ACT_MP_WALK ]						= IdleActivity + 1
IdleActivityTranslate[ ACT_MP_RUN ]							= IdleActivity + 2
IdleActivityTranslate[ ACT_MP_CROUCH_IDLE ]					= IdleActivity + 3
IdleActivityTranslate[ ACT_MP_CROUCHWALK ]					= IdleActivity + 4
IdleActivityTranslate[ ACT_MP_ATTACK_STAND_PRIMARYFIRE ]	= IdleActivity + 5
IdleActivityTranslate[ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ]	= IdleActivity + 5
IdleActivityTranslate[ ACT_MP_RELOAD_STAND ]				= IdleActivity + 6
IdleActivityTranslate[ ACT_MP_RELOAD_CROUCH ]				= IdleActivity + 6
IdleActivityTranslate[ ACT_MP_JUMP ]						= ACT_HL2MP_JUMP_SLAM
IdleActivityTranslate[ ACT_MP_SWIM ]						= IdleActivity + 9
IdleActivityTranslate[ ACT_LAND ]							= ACT_LAND

local function RagdollFightTranslateActivity( ply, act )
	if ply.Ragdoll and ply.Ragdoll:IsValid() then
		return IdleActivityTranslate[ act ]
	end
end
hook.Add( "TranslateActivity", "RagdollFightTranslateActivity", RagdollFightTranslateActivity )

util.AddNetworkString( "RagdollFightSendXRay" )

local function RagdollFightKeyPress( pl, key )

	if pl.Ragdoll and pl.Ragdoll:IsValid() then
		
		pl.Ragdoll.NextAttack = pl.Ragdoll.NextAttack or 0
		
		if pl.Ragdoll.StanceDuration > CurTime() then return end
		if pl.Ragdoll.NextAttack > CurTime() then return end
		if pl.Ragdoll.XRay and pl.Ragdoll.XRayTime and pl.Ragdoll.XRayTime > CurTime() then return end
		
		//escape grab powerup
		if key == IN_USE and IsValid( pl.Ragdoll.GrabbedBy ) and pl.Ragdoll:HasPowerup( RAGDOLL_POWERUP_BREAKER ) then
			local enemy = pl.Ragdoll.GrabbedBy
			pl.Ragdoll.WasThrown = nil
			enemy.RagdollModeTime = CurTime() + 1.5
			RagdollFightApplyForce( enemy, pl:GetForward() + vector_up, 3000 )
			RagdollFightApplyForce( pl.Ragdoll, pl:GetForward() * -1 + vector_up, 3000 )
			enemy.WasThrown = 1.2
			enemy:EmitSound( "npc/antlion_guard/shove1.wav", 100, math.random( 100, 115 ) )
			pl.Ragdoll:ConsumeCharge( RAGDOLL_POWERUP_BREAKER )
			RagdollFightResetMass( pl.Ragdoll )
			enemy.GrabbedObject.GrabbedBy = nil
			enemy.GrabbedObject = nil
			if enemy._Constraints then
				constraint.RemoveConstraints( enemy, "Weld" ) 
			end
			enemy.Grab = false
			pl.Ragdoll.GrabbedBy = nil
			pl.Ragdoll.NextAttack = CurTime() + 1
			return
		end
		
		if pl.Ragdoll.RagdollMode then return end
		if pl.Ragdoll.RagdollModeTime then return end
		
		
		if key == IN_RELOAD and !pl.Ragdoll.RagdollMode and !IsValid( pl.Ragdoll.GrabbedObject ) and !pl.Ragdoll.Grab then
			pl.Ragdoll.Blocking = pl:Crouching() and RAGDOLL_BLOCK_CROUCH or RAGDOLL_BLOCK_NORMAL
		end
		
		pl.Ragdoll.NextTaunt = pl.Ragdoll.NextTaunt or 0	
		
		if key == IN_WALK and !pl.Ragdoll.RagdollMode and !pl.RagdollModeTime and !pl.Ragdoll.Blocking and !IsValid( pl.Ragdoll.GrabbedObject ) and pl.Ragdoll.NextTaunt < CurTime() then
			pl.Ragdoll.Stance = RAGDOLL_STANCE_TAUNT
			pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
			pl.Ragdoll.StanceDuration = CurTime() + 0.2
			pl.Ragdoll.RagdollModeTime = CurTime() + 0.2
			pl.Ragdoll.NextTaunt = CurTime() + 5
			RagdollFightApplyForce( pl.Ragdoll, 1 * pl:GetForward() * 0 - vector_up, 2800 )
			pl.Ragdoll:EmitSound( "physics/body/body_medium_break"..math.random(2,4)..".wav", 100, math.random( 100, 115 ) )
			return
		end
		
		//xray shit
		if key == IN_ATTACK and !pl.Ragdoll.Blocking and IsValid( pl.Ragdoll.GrabbedObject ) and pl.Ragdoll.GrabbedObject.IsRagdollFighter and pl.Ragdoll:HasPowerup( RAGDOLL_POWERUP_XRAY ) then
		
			local victim = pl.Ragdoll.GrabbedObject
			local me = pl.Ragdoll
			
			local xray_ind = math.random( 1, #RagdollFight.XRayStances )
			
			me.XRay = RAGDOLL_XRAY_ATTACKER
			victim.XRay = RAGDOLL_XRAY_VICTIM
			
			local xray_dir = pl.RagdollFightArena:GetDirVector( 1 )
			
			if xray_dir:Dot( pl:GetForward() ) < 0 then
				xray_dir = pl.RagdollFightArena:GetDirVector( 2 )
			end
			
			if xray_ind == 4 or xray_ind == 12 then
				xray_dir = pl.RagdollFightArena:GetDirVector( 2 )
			end
			
			local xray_ang = xray_dir:Angle()
			
			me.XRayIndex = xray_ind
			victim.XRayIndex = xray_ind
			
			me.XRayFixHeight = nil
			victim.XRayFixHeight = nil
			
			local fix_pos = pl.RagdollFightArena:GetPos() + vector_up * 36
			
			me.XRayFixHeight = fix_pos.z
					
			me.XRayVictim = victim
			victim.XRayAttacker = me
			
			me.XRayAngles = xray_ang
			victim.XRayAngles = xray_ang
			
			me.XRayOrigin = nil
			victim.XRayOrigin = nil
			
			me.XRayDamage = nil
			victim.XRayDamage = nil
			
			me.XRayDuration = 6
			victim.XRayDuration = me.XRayDuration
			
			me.XRayLerping = nil
			victim.XRayLerping = nil
			
			me.XRayTime = CurTime() + me.XRayDuration
			victim.XRayTime = CurTime() + victim.XRayDuration
			
			pl:SetLocalVelocity( vector_origin )
			victim:SetLocalVelocity( vector_origin )
			
			pl:SetMoveType( MOVETYPE_NONE )
			victim:GetOwner():SetMoveType( MOVETYPE_NONE )
			
			//we dont want to make slowmotion, so we are going make it look like one
			RagdollFightChangeDamping( me, 70, 70 * 1.5 )
			RagdollFightChangeDamping( victim, 70, 70 * 1.5 )
			
			//RagdollFightResetMass( victim )
			
			victim.WasThrown = nil
			me.GrabbedObject = nil
			victim.RagdollMode = false
			victim.RagdollModeTime = nil
			if me._Constraints then
				constraint.RemoveConstraints( me, "Weld" ) 
			end
			me.Grab = false
			victim.GrabbedBy = nil
			me.NextAttack = CurTime() + 1
			victim.NextAttack = CurTime() + 1
			
			local xray_tbl = RagdollFight.XRayStances[ xray_ind ]
			
			local send = {}
			
			for i=1, #xray_tbl do
				send[ i ] = xray_tbl[ i ].bone
			end
			
			net.Start( "RagdollFightSendXRay" )
				net.WriteEntity( victim )
				net.WriteEntity( pl.Ragdoll )
				net.WriteInt( victim.XRayDuration, 32 )
				net.WriteInt( #xray_tbl, 32 )
				net.WriteInt( xray_ind, 32 )
				net.WriteTable( send )
			net.Send( pl )
			
			net.Start( "RagdollFightSendXRay" )
				net.WriteEntity( victim )
				net.WriteEntity( pl.Ragdoll )
				net.WriteInt( victim.XRayDuration, 32 )
				net.WriteInt( #xray_tbl, 32 )
				net.WriteInt( xray_ind, 32 )
				net.WriteTable( send )
			net.Send( victim:GetOwner() )
			
			//send xray to spectators
			for k, v in pairs( pl.RagdollFightArena.Spectators ) do
				if v and v:IsValid() and v:Alive() then
					net.Start( "RagdollFightSendXRay" )
						net.WriteEntity( victim )
						net.WriteEntity( pl.Ragdoll )
						net.WriteInt( victim.XRayDuration, 32 )
						net.WriteInt( #xray_tbl, 32 )
						net.WriteInt( xray_ind, 32 )
						net.WriteTable( send )
					net.Send( v )
				end
			end
			
			
			pl.Ragdoll:ConsumeCharge( RAGDOLL_POWERUP_XRAY )
			
			return
		end
		
		local dur = 0.3
		
		if key == IN_ATTACK and !pl.Ragdoll.RagdollMode and !pl.Ragdoll.Blocking and !IsValid( pl.Ragdoll.GrabbedObject ) then
			
				if pl:OnGround() then
					if pl:Crouching() then
						if pl:GetVelocity():Length2DSqr() >= 22100 then
							dur = 0.6
							pl:SetGroundEntity( NULL )
							pl:SetLocalVelocity( pl:GetForward() * 1000 )
							pl.Ragdoll.Stance = RAGDOLL_STANCE_SLIDE
							pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
							pl.Ragdoll.StanceDuration = CurTime() + dur
							pl.Ragdoll.NextAttack = CurTime() + 1
							local use_charge = pl.Ragdoll:HasPowerup( RAGDOLL_POWERUP_HEAVYATTACK )// and pl:KeyDown( IN_SPEED )
							ActivateHitbox( pl.Ragdoll, false, false, true, true, RAGDOLL_ATTACK_CROUCH, 500, use_charge, RAGDOLL_DAMAGE_LEG_SLIDE, use_charge and 1.8 or nil )
							if use_charge then
								pl.Ragdoll:ConsumeCharge( RAGDOLL_POWERUP_HEAVYATTACK )
							end
						else
							pl.Ragdoll.Stance = RAGDOLL_STANCE_CROUCH_ATTACK
							pl.Ragdoll.StanceNum = pl.Ragdoll.LastStanceNum == 1 and 2 or 1 //RandomStanceNum( pl.Ragdoll.Stance )
							pl.Ragdoll.StanceDuration = CurTime() + dur
							pl.Ragdoll.NextAttack = CurTime() + dur
							ActivateHitbox( pl.Ragdoll, false, false, true, true, RAGDOLL_ATTACK_CROUCH, 100, nil, RAGDOLL_DAMAGE_FISTS )
						end
					else
						pl.Ragdoll.Stance = RAGDOLL_STANCE_ATTACK
						pl.Ragdoll.StanceNum = pl.Ragdoll.LastStanceNum == 1 and 2 or 1//RandomStanceNum( pl.Ragdoll.Stance )
						pl.Ragdoll.StanceDuration = CurTime() + dur
						pl.Ragdoll.NextAttack = CurTime() + dur
						ActivateHitbox( pl.Ragdoll, true, true, false, false, RAGDOLL_ATTACK_NORMAL, 100, nil, RAGDOLL_DAMAGE_FISTS )
					end
				else
					if pl:KeyDown( IN_FORWARD ) then//pl:GetVelocity():Length2DSqr() >= 36100
						dur = 0.5
						pl:SetGroundEntity( NULL )
						pl:SetLocalVelocity( pl:GetForward() * 400 )
						pl.Ragdoll.Stance = RAGDOLL_STANCE_JUMP_ATTACK_SPRINT
						pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
						pl.Ragdoll.StanceDuration = CurTime() + dur
						pl.Ragdoll.NextAttack = CurTime() + 1.1
						local use_charge = pl.Ragdoll:HasPowerup( RAGDOLL_POWERUP_HEAVYATTACK )// and pl:KeyDown( IN_SPEED )
						ActivateHitbox( pl.Ragdoll, false, false, true, true, RAGDOLL_ATTACK_NORMAL, 1000, use_charge, RAGDOLL_DAMAGE_LEG_HEAVY, use_charge and 1.8 or nil )
						if use_charge then
							pl.Ragdoll:ConsumeCharge( RAGDOLL_POWERUP_HEAVYATTACK )
						end
					else
						dur = 0.4
						pl.Ragdoll.Stance = RAGDOLL_STANCE_JUMP_ATTACK
						pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
						pl.Ragdoll.StanceDuration = CurTime() + dur
						pl.Ragdoll.NextAttack = CurTime() + dur
						ActivateHitbox( pl.Ragdoll, false, false, false, true, RAGDOLL_ATTACK_NORMAL, 500, nil, RAGDOLL_DAMAGE_FISTS )
					end
				end
				
				pl.Ragdoll.Attack = CurTime() + dur
				
		end
		
		if key == IN_ATTACK2 and !IsValid( pl.Ragdoll.GrabbedObject ) and !pl.Ragdoll.Blocking then
			pl.Ragdoll.Grab = true
			pl.Ragdoll.GrabTime = CurTime() + 1
			if pl:OnGround() then
				pl.Ragdoll.Stance = RAGDOLL_STANCE_GRAB
				pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
				pl.Ragdoll.StanceDuration = CurTime() + 0.2
				pl.Ragdoll.NextAttack = CurTime() + 0.4
			else
				pl.Ragdoll.Stance = RAGDOLL_STANCE_GRAB_JUMP
				pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
				pl.Ragdoll.StanceDuration = CurTime() + 0.3
				pl.Ragdoll.NextAttack = CurTime() + dur
			end
		end
		
	end

end
hook.Add( "KeyPress", "RagdollFightKeyPress", RagdollFightKeyPress )

local function RagdollFightKeyRelease( pl, key )
	
	if pl.Ragdoll and pl.Ragdoll:IsValid() then
	
		if key == IN_RELOAD and pl.Ragdoll.Blocking and !pl.Ragdoll.RagdollMode and !IsValid( pl.Ragdoll.GrabbedObject ) and !pl.Ragdoll.Grab then
			pl.Ragdoll.Blocking = nil
		end
	
		if key == IN_ATTACK2 then
		
			if IsValid( pl.Ragdoll.GrabbedObject ) and !pl.Ragdoll.RagdollMode and !pl.Ragdoll.RagdollModeTime then
				if pl.Ragdoll.GrabbedObject.IsRagdollFighter then
		
					local dur = 0.3
													
					if pl:OnGround() then
						if pl:Crouching() then
							pl.Ragdoll.Stance = RAGDOLL_STANCE_GRAB_ATTACK_BACKTHROW
							pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
							RagdollFightApplyForce( pl.Ragdoll.GrabbedObject, -1 * pl:GetForward() - vector_up , 7000, true )
							pl.Ragdoll.StanceDuration = CurTime() + dur
							pl.Ragdoll.GrabbedObject.WasThrown = 1.6
							pl.Ragdoll.NextAttack = CurTime() + 1
						else
							pl.Ragdoll.Stance = RAGDOLL_STANCE_GRAB_ATTACK_THROW
							pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
							RagdollFightApplyForce( pl.Ragdoll.GrabbedObject, pl:GetForward() + vector_up * 0.05 , 1000 )
							pl.Ragdoll.GrabbedObject.WasThrown = 0.2
							pl.Ragdoll.StanceDuration = CurTime() + dur
							pl.Ragdoll.NextAttack = CurTime() + 0
						end
					else
						pl:SetGroundEntity( NULL )
						pl:SetLocalVelocity( vector_up * -250 )
						pl.Ragdoll.Stance = RAGDOLL_STANCE_GRAB_ATTACK_SLAM
						pl.Ragdoll.StanceNum = RandomStanceNum( pl.Ragdoll.Stance )
						RagdollFightApplyForce( pl.Ragdoll.GrabbedObject, pl:GetForward() * 0.1 - vector_up , 18000, true )
						pl.Ragdoll.GrabbedObject.WasThrown = 1.3
						pl.Ragdoll.StanceDuration = CurTime() + dur
						pl.Ragdoll.NextAttack = CurTime() + 1
					end
					pl.Ragdoll.ThrowTime = CurTime() + 4
					pl.Ragdoll.GrabbedObject.NextGrab = CurTime() + 4
					RagdollFightResetMass( pl.Ragdoll.GrabbedObject )
				
				end
				pl.Ragdoll.GrabbedObject.GrabbedBy = nil
				pl.Ragdoll.GrabbedObject = nil
			end
			if pl.Ragdoll._Constraints then
				constraint.RemoveConstraints( pl.Ragdoll, "Weld" ) 
			end
			pl.Ragdoll.Grab = false
		end
		
	end
	
end
hook.Add( "KeyRelease", "RagdollFightKeyRelease", RagdollFightKeyRelease )

hook.Add( "AllowPlayerPickup", "RagdollFightAllowPlayerPickup", function( pl, ent )
	if pl.Ragdoll and pl.Ragdoll:IsValid() then
		return false
	end
end)
 
hook.Add( "PlayerSwitchFlashlight", "RagdollFightPlayerSwitchFlashlight", function( pl, enabled )
	if pl.Ragdoll and pl.Ragdoll:IsValid() then
		return false
	end
end)

hook.Add( "EntityTakeDamage", "RagdollFightEntityTakeDamage", function( pl, dmginfo )
	if pl.Ragdoll and pl.Ragdoll:IsValid() then
		return true
	end
end)
 
hook.Add( "PlayerSpawnProp", "RagdollFightPlayerSpawnProp", function( pl, model )
	if pl and pl.RagdollFightArena and pl.RagdollFightArena:IsValid() then return false end
end)

//command for making stances. gonna lock it behind IsAdmin, just to be sure
local offset_trace = { mask = MASK_SOLID_BRUSHONLY }
function RagdollFightSaveStance( pl, cmd, args )
	
	if not pl then return end
	if !pl:IsAdmin() then return end
	
	local ent = pl:GetEyeTrace().Entity
	
	local id = args and args[1] and tonumber(args[1]) or nil
	
	local remember = id and id == 1
	local override = id and id == 2 and IsValid( pl.RememberRag ) and pl.RememberRag
	
	if !IsValid( ent ) then return end
	if ent:GetClass() ~= "prop_ragdoll" then return end
	
	print"----------"
	print( pl.RememberRag )
	print( pl.RememberAng )
	
	print( "remember ", remember )
	print( "override ", override )
	
	local reference_bonename = "ValveBiped.Bip01_Pelvis"
	local reference_bone = ent:LookupBone( reference_bonename )
	
	if override then
		reference_bone = override:LookupBone( reference_bonename )
	end
	
	if not reference_bone then return end

	
	local reference_physbone_id = ent:TranslateBoneToPhysBone( reference_bone )
	local reference_physbone = ent:GetPhysicsObjectNum( reference_physbone_id )
	
	if override then
		reference_physbone_id = override:TranslateBoneToPhysBone( reference_bone )
		reference_physbone = override:GetPhysicsObjectNum( reference_physbone_id )
	end
	
	local tbl = "{\n"
	
	if reference_physbone then
		
		local ref_pos = reference_physbone:GetPos()
		local ref_angle = reference_physbone:GetAngles()
		
		if remember then
			offset_trace.start = ref_pos
			offset_trace.endpos = vector_up * - 200
			
			local tr = util.TraceLine( offset_trace )
			
			if tr.HitWorld then
				
				local diff = ref_pos - tr.HitPos
				diff = diff.z
				
				print( "OFFSET ", diff - 36  )
				
			end
			
		end
			
		for i=0, ent:GetPhysicsObjectCount() - 1 do

			//if i == reference_physbone_id then continue end
			
			local phys_bone = ent:GetPhysicsObjectNum( i )
			local rag_bone = ent:TranslatePhysBoneToBone( i )
			local bone_name = ent:GetBoneName( rag_bone )
			
			if phys_bone and phys_bone:IsValid() then
				
				local ignore = ""
				
				if phys_bone:IsMoveable() then 
					ignore = ", ignore = true"
				end
				
				local pos = reference_physbone:GetPos()
				local ang = pl:GetAngles()
				
				if pl.RememberAng then
					ang = pl.RememberAng
				end
				
				ang.p = 0
				
				local offset_pos, offset_ang = WorldToLocal( phys_bone:GetPos(), phys_bone:GetAngles(), pos, ang ) 
				
				tbl = tbl.."	[\""..bone_name.."\"] = { pos = Vector( "..offset_pos.x..", "..offset_pos.y..", "..offset_pos.z.." ), ang = Angle( "..offset_ang.p..", "..offset_ang.y..", "..offset_ang.r.." )"..ignore.." },\n"
				
				//print( bone_name )
				//print( offset_pos )
				//print( offset_ang )
				
			end
		
		end
	
	end
	
	if pl.RememberRag then
		pl.RememberRag = nil
		pl.RememberAng = nil
	end
	
	if remember then
		pl.RememberRag = ent
		local ang = pl:GetAngles()
		ang.p = 0
		pl.RememberAng = ang
	end
	
	tbl = tbl.."},"
	
	print(tbl)
	
	
end
concommand.Add( "rag_remember", RagdollFightSaveStance )

//small command for making xray weapons. gonna lock it behind IsAdmin, just to be sure
function RagdollFightSaveWeapon( pl, cmd, args )
	
	if not pl then return end
	if !pl:IsAdmin() then return end
	local tr = pl:GetEyeTrace()
	local ent = tr.Entity
	
	local id = args and args[1] and tonumber(args[1]) or nil
	
	local ragdoll = id and id == 1
	local weapon = id and id == 2
	
	if !IsValid( ent ) then return end
	
	if ragdoll then
		
		if tr.PhysicsBone then
			
			local bone = ent:TranslatePhysBoneToBone( tr.PhysicsBone )
			if bone then
				local bone_name = ent:GetBoneName( bone )
				local m = ent:GetBoneMatrix( bone )
				if m then
					local pos, ang = m:GetTranslation(), m:GetAngles()
					print( bone_name, pos, ang )
					if pl.RememberRagWep then
						table.Empty( pl.RememberRagWep )
					else
						pl.RememberRagWep = {}
					end
					pl.RememberRagWep.bone_name = bone_name
					pl.RememberRagWep.pos = pos
					pl.RememberRagWep.ang = ang
				end
			end
		
		end
	end
	
	if weapon then
		if pl.RememberRagWep then
			
			if ent:GetClass() == "prop_effect" then
				ent = ent.AttachedEntity
			end
			
			local pos, ang = ent:GetPos(), ent:GetAngles()
			
			local new_pos, new_ang = WorldToLocal( pos, ang, pl.RememberRagWep.pos, pl.RememberRagWep.ang )
			local text = "{ mdl = Model( \""..ent:GetModel().."\" ), bone = \""..pl.RememberRagWep.bone_name.."\", pos = Vector( "..new_pos.x..", "..new_pos.y..", "..new_pos.z.." ), ang = Angle( "..new_ang.p..", "..new_ang.y..", "..new_ang.r.." ) },"
			
			print("\n\n", text)
			
		end
	end
	
	
end
concommand.Add( "rag_remember_wep", RagdollFightSaveWeapon )

//take a drink everytime someone complains about why bot is not fighting back or something
local function RagdollFightAddBot( pl, cmd, args )
	
	if !pl:IsAdmin() then return end
	if game.SinglePlayer() then
		print( "It's not going to work, unless you host a local server!" )
		return
	end
	
	local arena = IsValid( pl.RagdollFightArena ) and pl.RagdollFightArena
	
	if arena then
	
		if arena:GetPlayerNum() < 2 then
		
			local free_slot = 1
			
			for i=1, 2 do
				if !IsValid( arena:GetPlayer( i ) ) then
					free_slot = i
					break
				end
			end
			
			local bot = player.CreateNextBot( pl:Nick().."'s friend" )
			
			if bot and bot:IsValid() then
				bot.RagdollFightBot = true
				arena:AddPlayer( free_slot, bot )
			end

		end
	else
		print( "You need to be inside an arena!" )
	end
	
end
concommand.Add( "rf_bot_add", RagdollFightAddBot )

local function RagdollFightBotToggleAttack( pl, cmd, args )
	
	if !pl:IsAdmin() then return end
	
	RAGDOLL_BOT_FORCE_ATTACK = RAGDOLL_BOT_FORCE_ATTACK or false
	RAGDOLL_BOT_FORCE_ATTACK = !RAGDOLL_BOT_FORCE_ATTACK
	
	print( "Ragdoll Fight bots will"..( RAGDOLL_BOT_FORCE_ATTACK and "" or " not").." attack" )
	
end
concommand.Add( "rf_bot_toggle_attack", RagdollFightBotToggleAttack )

local function RagdollFightBotToggleGrab( pl, cmd, args )
	
	if !pl:IsAdmin() then return end
	
	RAGDOLL_BOT_FORCE_GRAB = RAGDOLL_BOT_FORCE_GRAB or false
	RAGDOLL_BOT_FORCE_GRAB = !RAGDOLL_BOT_FORCE_GRAB
	
	print( "Ragdoll Fight bots will"..( RAGDOLL_BOT_FORCE_GRAB and "" or " not").." grab" )
	
end
concommand.Add( "rf_bot_toggle_grab", RagdollFightBotToggleGrab )

local function RagdollFightBotToggleJump( pl, cmd, args )
	
	if !pl:IsAdmin() then return end
	
	RAGDOLL_BOT_FORCE_JUMP = RAGDOLL_BOT_FORCE_JUMP or false
	RAGDOLL_BOT_FORCE_JUMP = !RAGDOLL_BOT_FORCE_JUMP
	
	print( "Ragdoll Fight bots will"..( RAGDOLL_BOT_FORCE_JUMP and "" or " not").." jump" )
	
end
concommand.Add( "rf_bot_toggle_jump", RagdollFightBotToggleJump )

local function RagdollFightBotToggleCrouch( pl, cmd, args )
	
	if !pl:IsAdmin() then return end
	
	RAGDOLL_BOT_FORCE_CROUCH = RAGDOLL_BOT_FORCE_CROUCH or false
	RAGDOLL_BOT_FORCE_CROUCH = !RAGDOLL_BOT_FORCE_CROUCH
	
	print( "Ragdoll Fight bots will"..( RAGDOLL_BOT_FORCE_CROUCH and "" or " not").." crouch" )
	
end
concommand.Add( "rf_bot_toggle_crouch", RagdollFightBotToggleCrouch )

local function RagdollFightBotToggleBlock( pl, cmd, args )
	
	if !pl:IsAdmin() then return end
	
	RAGDOLL_BOT_FORCE_BLOCK = RAGDOLL_BOT_FORCE_BLOCK or false
	RAGDOLL_BOT_FORCE_BLOCK = !RAGDOLL_BOT_FORCE_BLOCK
	
	print( "Ragdoll Fight bots will"..( RAGDOLL_BOT_FORCE_BLOCK and "" or " not").." block" )
	
end
concommand.Add( "rf_bot_toggle_block", RagdollFightBotToggleBlock )

local function RagdollFightBotToggleMirror( pl, cmd, args )
	
	if !pl:IsAdmin() then return end
	
	RAGDOLL_BOT_FORCE_MIRROR = RAGDOLL_BOT_FORCE_MIRROR or false
	RAGDOLL_BOT_FORCE_MIRROR = !RAGDOLL_BOT_FORCE_MIRROR
	
	print( "Ragdoll Fight bots will"..( RAGDOLL_BOT_FORCE_MIRROR and "" or " not").." mirror the player" )
	
end
concommand.Add( "rf_bot_toggle_mirror", RagdollFightBotToggleMirror )

//I dont think we need to call it clientside since they are just bots. Right?
//Also, I guess this is where you can try to make an AI, because I'm not gonna bother with it
hook.Add( "StartCommand", "RagdollFightBots", function( pl, cmd )
		
	if pl:IsBot() and pl.RagdollFightBot and IsValid( pl.RagdollFightArena ) and pl:Alive() then
		
		local arena = pl.RagdollFightArena
		
		cmd:ClearMovement()
		cmd:ClearButtons()
		
		//fix eye angles
		local pl1 = arena:GetPlayer( 1 )
		local pl2 = arena:GetPlayer( 2 )
		
		local rag1 = arena:GetRagdollFighter( 1 )
		local rag2 = arena:GetRagdollFighter( 2 )
		
		local enemy = pl == pl1 and pl2 or pl1
		
		if not pl.RagdollFightEnemy then
			pl.RagdollFightEnemy = enemy
		end
		
		local my_rag = pl == pl1 and rag1 or rag2
		local enemy_rag = pl == pl1 and rag2 or rag1
		
		local ang = arena:GetAngles()
		ang.p = 0
		
		if pl == pl1 then
		end
		
		if pl == pl2 then
			ang:RotateAroundAxis( arena:GetUp(), 180 )
		end
		
		if enemy and enemy:IsValid() and enemy ~= pl and rag1 and rag1:IsValid() and rag2 and rag2:IsValid() and enemy_rag and enemy_rag:IsValid() and pl:GetCollisionGroup() == COLLISION_GROUP_PLAYER then
			ang = ( enemy_rag:GetPos() - pl:GetPos() ):GetNormal():Angle()
		end
		
		ang.p = 0

		pl:SetEyeAngles( ang )
		cmd:SetViewAngles( ang )
		
		//some other stuff
		if pl.RagdollFightEnemy and pl.RagdollFightEnemy:IsValid() then
			
			pl.RF_NextAttack = pl.RF_NextAttack or 0
			pl.RF_NextJump = pl.RF_NextJump or 0
			pl.RF_UnGrab = pl.RF_UnGrab or 0
			
			//I guess there is better way to do that, but whatever
			if RAGDOLL_BOT_FORCE_MIRROR then
				
				if pl.RagdollFightEnemy:KeyDown( IN_ATTACK ) then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
				end
				
				if pl.RagdollFightEnemy:KeyDown( IN_ATTACK2 ) then
					cmd:SetButtons( cmd:GetButtons() + IN_ATTACK2 )
				end
				
				if pl.RagdollFightEnemy:KeyDown( IN_DUCK ) then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end
				
				if pl.RagdollFightEnemy:KeyDown( IN_JUMP ) then
					cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
				end
				
				if pl.RagdollFightEnemy:KeyDown( IN_RELOAD ) then
					cmd:SetButtons( cmd:GetButtons() + IN_RELOAD )
				end
				
				if pl.RagdollFightEnemy:KeyDown( IN_FORWARD ) then
					cmd:SetButtons( cmd:GetButtons() + IN_FORWARD )
				end
				
				if pl.RagdollFightEnemy:KeyDown( IN_WALK ) then
					cmd:SetButtons( cmd:GetButtons() + IN_WALK )
				end
				
				//these ones are reversed and done differently
				if pl.RagdollFightEnemy:KeyDown( IN_MOVELEFT ) then
					cmd:SetSideMove( pl.RagdollFightEnemy:GetVelocity():Length2D() ) 
				end
				
				if pl.RagdollFightEnemy:KeyDown( IN_MOVERIGHT ) then
					cmd:SetSideMove( -1 * pl.RagdollFightEnemy:GetVelocity():Length2D() ) 
				end
				
				
			else
				if RAGDOLL_BOT_FORCE_ATTACK then
					if pl.RF_NextAttack < CurTime() then
						cmd:SetButtons( cmd:GetButtons() + IN_ATTACK )
						pl.RF_NextAttack = CurTime() + 0.2
					end
				end

				if RAGDOLL_BOT_FORCE_JUMP then
					if pl.RF_NextJump < CurTime() then
						cmd:SetButtons( cmd:GetButtons() + IN_JUMP )
						pl.RF_NextJump = CurTime() + 0.2
					end
				end
				
				if RAGDOLL_BOT_FORCE_CROUCH then
					cmd:SetButtons( cmd:GetButtons() + IN_DUCK )
				end
				
				if RAGDOLL_BOT_FORCE_BLOCK then
					cmd:SetButtons( cmd:GetButtons() + IN_RELOAD )
				end
				
				if RAGDOLL_BOT_FORCE_GRAB then
					if pl.RF_UnGrab < CurTime() then
						pl.RF_UnGrab = CurTime() + 1
					else
						cmd:SetButtons( cmd:GetButtons() + IN_ATTACK2 )
					end
				end
			end
			
		end
	
	end
	
end )

end