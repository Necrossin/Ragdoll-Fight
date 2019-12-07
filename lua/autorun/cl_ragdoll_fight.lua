AddCSLuaFile() 

if CLIENT then

surface.CreateFont( "RagdollFightDefault", {
	font	= "Helvetica",
	size	= 22,
	weight	= 800
} )

surface.CreateFont( "RagdollFightDefaultTitle", {
	font	= "Helvetica",
	size	= 32,
	weight	= 800
} )

surface.CreateFont( "RagdollFightRoundNumber", {
	font	= "Helvetica",
	size	= 52,
	weight	= 800
} )

surface.CreateFont( "RagdollFightBigMessage", {
	font	= "Helvetica",
	size	= 150,
	weight	= 800
} )

surface.CreateFont( "RagdollFightMedMessage", {
	font	= "Helvetica",
	size	= 65,
	weight	= 800
} )

surface.CreateFont( "RagdollFightSmallMessage", {
	font	= "Helvetica",
	size	= 50,
	weight	= 800
} )

surface.CreateFont( "RagdollFightChargeDesc", {
	font	= "Helvetica",
	size	= 18,
	weight	= 800
} )


net.Receive( "RagdollFightUpdateRagdoll", function( len )

	if !IsValid( LocalPlayer() ) then return end
	
	local rag_id = net.ReadInt( 32 )
	local rag = Entity( rag_id )
	if rag and rag:IsValid() then
		LocalPlayer().Ragdoll = rag
	end
	
	
end)

local function RagdollFightCreateMove( cmd )

	local pl = LocalPlayer()
	local arena = IsValid( pl.RagdollFightArena ) and pl.RagdollFightArena
	
	if arena and pl:Alive() then
		local pl1 = arena:GetPlayer( 1 )
		local pl2 = arena:GetPlayer( 2 )
		
		local rag1 = arena:GetRagdollFighter( 1 )
		local rag2 = arena:GetRagdollFighter( 2 )
		
		local enemy = pl == pl1 and pl2 or pl1
		
		local my_rag = pl == pl1 and rag1 or rag2
		local enemy_rag = pl == pl1 and rag2 or rag1
		
		local ang = arena:GetAngles()
		ang.p = 0
		
		if pl == pl1 then
			
		end
		
		if pl == pl2 then
			ang:RotateAroundAxis( arena:GetUp(), 180 )
		end
		
		if enemy and enemy:IsValid() and enemy ~= pl and rag1 and rag1:IsValid() and rag2 and rag2:IsValid() and enemy_rag and enemy_rag:IsValid() and pl:GetCollisionGroup() == COLLISION_GROUP_PLAYER then// and pl:GetMoveType() ~= MOVETYPE_NONE then
			ang = ( enemy_rag:GetPos() - pl:GetPos() ):GetNormal():Angle()
		end
		
		ang.p = 0

		cmd:SetViewAngles( ang )
	end
	
end
hook.Add( "CreateMove", "RagdollFightCreateMove", RagdollFightCreateMove )

hook.Add( "OnSpawnMenuOpen", "RagdollFightOnSpawnMenuOpen", function()
	local pl = LocalPlayer()
	if pl and pl.RagdollFightArena and pl.RagdollFightArena:IsValid() then return false end
end )

hook.Add( "DrawDeathNotice", "RagdollFightDrawDeathNotice", function()
	local pl = LocalPlayer()
	if pl and pl.RagdollFightArena and pl.RagdollFightArena:IsValid() then return false end
	if pl and pl.RagdollFightSpectator and pl.RagdollFightArenaSpectator and pl.RagdollFightArenaSpectator:IsValid() then return end
end )

net.Receive( "RagdollFightSendXRay", function( len )
	
	local pl = LocalPlayer()
	
	if !IsValid( pl ) then return end
	
	if pl.XRayTable then
		table.Empty( pl.XRayTable )
	else
		pl.XRayTable = {}
	end
	
	local enemy_rag = net.ReadEntity()
	local attacker_rag = net.ReadEntity()
	local xray_dur = net.ReadInt( 32 )
	local xray_num = net.ReadInt( 32 )
	local xray_ind = net.ReadInt( 32 )
	local xray_bones = net.ReadTable()
	
	
	pl.XRayTable.enemy_rag = enemy_rag
	pl.XRayTable.attacker_rag = attacker_rag
	pl.XRayTable.xray_dur = xray_dur
	pl.XRayTable.xray_time = CurTime() + xray_dur
	pl.XRayTable.xray_num = xray_num
	pl.XRayTable.xray_ind = xray_ind
	pl.XRayTable.xray_bones = xray_bones
	pl.XRayTable.xray_zoom = 0
	pl.XRayTable.xray_zoom_goal = 0
	pl.XRayTable.xray_zoom_dist = 60
	
end )

local bloody = Material( "models/skeleton/skeleton_bloody" )
local skeleton = Model( "models/player/skeleton.mdl" )
local zombie = Model( "models/player/zombie_fast.mdl" )
local skull = Model( "models/Gibs/HGIBS.mdl" )
local flesh = Material("models/flesh")

local bone_gibs = {
	[ "ValveBiped.Bip01_Head1" ] = { mdl = Model( "models/gibs/hgibs_scapula.mdl" ), scale = function() return math.Rand( 0.2, 0.7 ) end, spacing = function() return math.Rand( 2, 5 ) end, am = 6 },
	[ "ValveBiped.Bip01_Spine2" ] = { mdl = Model( "models/gibs/hgibs_rib.mdl" ), scale = function() return math.Rand( 0.6, 0.8 ) end, spacing = function() return math.Rand( 2, 6 ) end, am = 5 },
	[ "ValveBiped.Bip01_Spine1" ] = { mdl = Model( "models/gibs/hgibs_rib.mdl" ), scale = function() return math.Rand( 0.4, 0.9 ) end, spacing = function() return math.Rand( 2, 6 ) end, am = 5 },
	[ "ValveBiped.Bip01_Pelvis" ] = { mdl = Model( "models/gibs/hgibs_scapula.mdl" ), scale = function() return math.Rand( 0.7, 1 ) end, spacing = function() return math.Rand( 5, 13 ) end, am = 5 },
	[ "ValveBiped.Bip01_R_Calf" ] = { mdl = Model( "models/gibs/hgibs_scapula.mdl" ), scale = function() return math.Rand( 0.3, 0.5 ) end, spacing = function() return math.Rand( 2, 3 ) end, am = 4 },
	[ "ValveBiped.Bip01_L_Calf" ] = { mdl = Model( "models/gibs/hgibs_scapula.mdl" ), scale = function() return math.Rand( 0.3, 0.5 ) end, spacing = function() return math.Rand( 2, 3 ) end, am = 4 },
}

local function CreateDummy( self )
	
	if IsValid( self.Dummy ) then 
		self.CreateDummyNextFrame = false
		return 
	end
	
	if not self.CreateDummyNextFrame then
		self.CreateDummyNextFrame = true
		return
	end
	
	local pl = LocalPlayer()
	
	self.Dummy = ClientsideModel( self.OriginalModel, RENDERGROUP_BOTH )//RENDER_GROUP_OPAQUE_ENTITY
	if self.Dummy then
		self.Dummy:SetPos( self:GetPos() )
		self.Dummy:SetAngles( self:GetAngles() )
		self.Dummy:SetParent( self )
		self.Dummy:SetNoDraw( true )
		
		pl.RagdollFightDummies = pl.RagdollFightDummies or {}

		table.insert( pl.RagdollFightDummies, self.Dummy )		
	end
	
end

local function DrawMask( self, pos, ang, cur_xray, cur_move )
	
	if self.Dummy and self.Dummy:IsValid() then
	
		self.Dummy:SetModel( skull )

		self.Dummy:SetParent()
		
		self.Dummy:SetPos( pos )
		self.Dummy:SetAngles( ang )
		
		local scale = 2.75
		
		if RagdollFight.XRayStances[ cur_xray ] and RagdollFight.XRayStances[ cur_xray ][ cur_move ] and RagdollFight.XRayStances[ cur_xray ][ cur_move ].xray_whole then
			scale = 25
		end
		
		self.Dummy:SetModelScale( scale, 0 )
		self.Dummy:SetupBones()
		
		self.Dummy:DrawModel()
		
	end
	
end

local function DrawWeapons( self, attacker, cur_xray, cur_move )

	if self.Dummy and self.Dummy:IsValid() and attacker and RagdollFight.XRayStances[ cur_xray ] and RagdollFight.XRayStances[ cur_xray ][ cur_move ] and RagdollFight.XRayStances[ cur_xray ][ cur_move ].weapon then
		
		local weps = RagdollFight.XRayStances[ cur_xray ][ cur_move ].weapon
		
		for i = 1, #weps do
			
			local tbl = weps[i]
			if tbl then
				
				local ent = attacker
				
				if tbl.victim then
					ent = self
				end
				
				local bone = ent:LookupBone( tbl.bone )
				if bone then
					
					local m = ent:GetBoneMatrix( bone )
					if m then
						
						local bone_pos, bone_ang = m:GetTranslation(), m:GetAngles()
						local new_pos, new_ang = LocalToWorld( tbl.pos, tbl.ang, bone_pos, bone_ang )
						
						if new_pos and new_ang then
							self.Dummy:SetModel( tbl.mdl )

							self.Dummy:SetParent()
							
							self.Dummy:SetPos( new_pos )
							self.Dummy:SetAngles( new_ang )
							
							self.Dummy:SetModelScale( 1, 0 )
							self.Dummy:SetupBones()
							self.Dummy:DrawModel()
							
							if tbl.attach_effect then
								self.Dummy.NextEffect = self.Dummy.NextEffect or 0
								if self.Dummy.NextEffect < CurTime() then
									local att = self.Dummy:LookupAttachment( tbl.attach_effect.att )
									if att then
										local att2 = self.Dummy:GetAttachment( att )
										if att2.Pos and att2.Ang then
											local effectdata = EffectData() 
												effectdata:SetOrigin( att2.Pos ) 
												effectdata:SetAttachment( att ) 
												effectdata:SetAngles( att2.Ang ) 
												effectdata:SetScale( tbl.attach_effect.scale or 1 )
											util.Effect( tbl.attach_effect.eff_name, effectdata ) 
										end
									end
									self.Dummy.NextEffect = CurTime() + 5
								end
							end
						end
					end
				end
			end
			
		end
	
	end
	
end

local function CollideCallback( particle, hitpos, hitnormal )
	if not particle.HitAlready then
		particle.HitAlready = true
		util.Decal( math.random( 3 ) == 3 and "Blood" or "Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal )
	end
end

local function DrawChunks( self, bone_name, m, cur_move, cur_xray )
	if self.Dummy and self.Dummy:IsValid() then
		if bone_gibs[ bone_name ] then
			
			//reset chunk data
			
			local pos = m:GetTranslation()
			local ang = m:GetAngles()
			
			if self.PrevMove ~= cur_move then
				self.ChunkTime = CurTime() + 0.32
				self.PrevMove = cur_move
				self.Dummy.NextEffect = 0
				if RagdollFight.XRayStances[ cur_xray ] and RagdollFight.XRayStances[ cur_xray ][ cur_move ] and RagdollFight.XRayStances[ cur_xray ][ cur_move ].client_sound then
					RagdollFight.XRayStances[ cur_xray ][ cur_move ].client_sound()
				end
			end
			
			if self.ChunkTime and self.ChunkTime < CurTime() then
			
				self.ChunkTime = nil
				
				if self.ChunkTableStatic then
					table.Empty( self.ChunkTableStatic )
				else
					self.ChunkTableStatic = {}
				end
				
				for i = 1, bone_gibs[ bone_name ].am do
					self.ChunkTableStatic[ i ] = { offset = VectorRand() * bone_gibs[ bone_name ].spacing(), ang = VectorRand():Angle(), scale = bone_gibs[ bone_name ].scale() }
				end
				
			
				if self.ChunkTable then
					table.Empty( self.ChunkTable )
				else
					self.ChunkTable = {}
				end
				
				if self.Emitter then
					self.Emitter:Finish()
				end
				
				self.Emitter = ParticleEmitter( pos, true ) 
				
				local dir = vector_origin
				local pl = LocalPlayer()
				
				if pl.XRayTable.attacker_rag and pl.XRayTable.attacker_rag:IsValid() then
					dir = ( pos - pl.XRayTable.attacker_rag:LocalToWorld( pl.XRayTable.attacker_rag:OBBCenter() ) ):GetNormal() * 35
				end
				
				for i = 1, bone_gibs[ bone_name ].am do
					
					self.ChunkTable[ i ] = self.Emitter:Add( "Decals/flesh/Blood"..math.random(1,5),pos + VectorRand() * bone_gibs[ bone_name ].spacing() )
					local pos2 = pos + VectorRand() * bone_gibs[ bone_name ].spacing() / 3
					self.ChunkTable[ i ]:SetPos( pos2 )
					self.ChunkTable[ i ]:SetAngles( ( pos - pos2 ):GetNormal():Angle() )
					self.ChunkTable[ i ]:SetVelocity(VectorRand() * 93 + dir)
					self.ChunkTable[ i ]:SetAngleVelocity( VectorRand():Angle() * math.Rand( -1, 1 ) ) 
					self.ChunkTable[ i ]:SetDieTime( 2 )
					self.ChunkTable[ i ]:SetGravity( vector_up * - 100 )
					self.ChunkTable[ i ]:SetStartSize( 0 )
					self.ChunkTable[ i ]:SetCollideCallback( CollideCallback )
					self.ChunkTable[ i ]:SetEndSize( 0 )
					self.ChunkTable[ i ].ModelSize = bone_gibs[ bone_name ].scale()
					self.ChunkTable[ i ].AngRand = VectorRand():Angle()
					self.ChunkTable[ i ]:SetStartAlpha( 1 )
					self.ChunkTable[ i ]:SetEndAlpha( 1 )
					self.ChunkTable[ i ]:SetCollide( true )
					self.ChunkTable[ i ]:SetBounce( 40 )
					self.ChunkTable[ i ]:SetAirResistance( 222 )
					
				end

			end
			
			//dynamic ones
			for i = 1, bone_gibs[ bone_name ].am do
				
				if self.ChunkTable and self.ChunkTable[ i ] then

					self.Dummy:SetModel( bone_gibs[ bone_name ].mdl )
					self.Dummy:SetParent()
					self.Dummy:SetPos( self.ChunkTable[ i ]:GetPos() )

					self.Dummy:SetAngles( self.ChunkTable[ i ]:GetAngles() + self.ChunkTable[ i ].AngRand )
					
					self.Dummy:SetModelScale( self.ChunkTable[ i ].ModelSize, 0 )//self.ChunkTable[ i ]:GetStartSize()
					self.Dummy:SetupBones()
					
					render.ModelMaterialOverride( bloody )
					self.Dummy:DrawModel()
					render.ModelMaterialOverride( )
				
				end
			end
			
			//static
			for i = 1, bone_gibs[ bone_name ].am do
				
				if self.ChunkTableStatic and self.ChunkTableStatic[ i ] then
				
					self.Dummy:SetModel( bone_gibs[ bone_name ].mdl )
					self.Dummy:SetParent()
					self.Dummy:SetPos( pos + self.ChunkTableStatic[ i ].offset + ang:Forward() * 3 )
					self.Dummy:SetAngles( ang + self.ChunkTableStatic[ i ].ang )
					
					self.Dummy:SetModelScale( self.ChunkTableStatic[ i ].scale * 1.1, 0 )
					self.Dummy:SetupBones()
					
					render.ModelMaterialOverride( bloody )
					self.Dummy:DrawModel()
					render.ModelMaterialOverride( )
				
				end
			end
			
		end
	end
end

local function DrawSkeleton( self, delta )
	
	if self.Dummy and self.Dummy:IsValid() then
	
		/*self.Dummy:SetupBones()
		self.Dummy:SetModel( zombie )

		self.Dummy:SetParent( self )
		self.Dummy:AddEffects( EF_BONEMERGE )
		
		self.Dummy:SetModelScale( 1, 0 )
		//render.ModelMaterialOverride( bloody )
		render.SetBlend( math.Clamp( delta ^ 0.9, 0.9, 1 ) )
		//render.CullMode( MATERIAL_CULLMODE_CW )
		self.Dummy:DrawModel()
		//render.CullMode( MATERIAL_CULLMODE_CCW )
		render.SetBlend( 1 )
		//render.ModelMaterialOverride( )*/
		
		
		self.Dummy:SetupBones()
		self.Dummy:SetModel( skeleton )

		self.Dummy:SetParent( self )
		self.Dummy:AddEffects( EF_BONEMERGE )
		
		self.Dummy:SetModelScale( 1, 0 )
		render.ModelMaterialOverride( bloody )
		self.Dummy:DrawModel()
		render.ModelMaterialOverride( )
	
	end

end


local function DrawInsides( self )
	
	if self.Dummy and self.Dummy:IsValid() then
	
		self.Dummy:SetModel( self.OriginalModel )

		self.Dummy:SetParent( self )
		self.Dummy:AddEffects( EF_BONEMERGE )
		
		self.Dummy:SetModelScale( 1, 0 )
		render.ModelMaterialOverride( flesh )
		
		render.CullMode( MATERIAL_CULLMODE_CW )
		self.Dummy:SetupBones()
		self.Dummy:DrawModel()
		render.CullMode( MATERIAL_CULLMODE_CCW )
		
		render.ModelMaterialOverride( )
	
	end

end




local function RagdollFightRagdollDraw( self )

	if not self.OriginalModel then
		self.OriginalModel = self:GetModel()
	end
	
	CreateDummy( self )
	
	local pl = LocalPlayer()

	//xray draw
	if pl.XRayTable and pl.XRayTable.xray_time and pl.XRayTable.enemy_rag and pl.XRayTable.enemy_rag == self then
		
		local bones = pl.XRayTable.xray_bones
					
		local bone_name = bones[ pl.XRayTable.cur_move ]
		local bone = self:LookupBone( bone_name )
		
		if bone then
			local m = self:GetBoneMatrix( bone )
				if m then
				local bone_pos = m:GetTranslation()
				local bone_ang = m:GetAngles()
					if bone_pos and bone_ang then
		
						local delta = 1
						
						if pl.XRayTable.xray_zoom_time and pl.XRayTable.xray_zoom_time > CurTime() then
							delta = math.Clamp( ( pl.XRayTable.xray_zoom_time - CurTime() ) / ( pl.XRayTable.xray_zoom_time_dur ), 0, 1 )
						end
		
						local normal = EyeAngles():Forward()
						local distance = normal:Dot( bone_pos )
						
						local ang = EyeAngles()
						ang:RotateAroundAxis( ang:Right(), 90 )
												
						//insides
						render.ClearStencil()
						render.SetStencilEnable( true )
						
						render.SetStencilWriteMask( 1 )
						render.SetStencilTestMask( 1 )
						
						render.SetStencilFailOperation( STENCIL_REPLACE )
						render.SetStencilPassOperation( STENCIL_ZERO )
						render.SetStencilZFailOperation( STENCIL_ZERO )
						render.SetStencilCompareFunction( STENCIL_NEVER )
						render.SetStencilReferenceValue( 1 )

						DrawMask( self, bone_pos, bone_ang, pl.XRayTable.xray_ind, pl.XRayTable.cur_move )

						render.SetStencilFailOperation( STENCIL_ZERO )
						render.SetStencilPassOperation( STENCIL_REPLACE )
						render.SetStencilZFailOperation( STENCIL_ZERO )
						render.SetStencilCompareFunction( STENCIL_EQUAL )
						
						render.SetStencilEnable( false )
						
						render.SetStencilEnable( true )
						render.SetStencilReferenceValue( 1 )
						
						render.OverrideDepthEnable( true, false )
						DrawInsides( self )
						render.OverrideDepthEnable( false, false )
						
						DrawSkeleton( self, delta )
						
						render.SetStencilEnable( false )
						
						
						//normal ragdoll outside of mask area
						render.ClearStencil()
						render.SetStencilEnable( true )
						
						render.SetStencilWriteMask( 1 )
						render.SetStencilTestMask( 1 )
						
						render.SetStencilFailOperation( STENCIL_REPLACE )
						render.SetStencilPassOperation( STENCIL_ZERO )
						render.SetStencilZFailOperation( STENCIL_ZERO )
						render.SetStencilCompareFunction( STENCIL_NEVER )
						render.SetStencilReferenceValue( 1 )
						
						render.OverrideDepthEnable( true, true )						
						self:SetupBones()
						self:DrawModel()
						render.OverrideDepthEnable( false, false )
						
						render.SetStencilReferenceValue( 2 )
						
						DrawMask( self, bone_pos, bone_ang, pl.XRayTable.xray_ind, pl.XRayTable.cur_move, pl.XRayTable.xray_ind )
						
						render.SetStencilFailOperation( STENCIL_KEEP )
						render.SetStencilPassOperation( STENCIL_REPLACE )
						render.SetStencilZFailOperation( STENCIL_KEEP )
						render.SetStencilCompareFunction( STENCIL_EQUAL )
						
						render.SetStencilEnable( false )
						
						render.SetStencilEnable( true )
						render.SetStencilReferenceValue( 1 )
						
						self:SetupBones()
						self:DrawModel()
						
						//and dissapearing part of ragdoll inside mask area
						render.SetStencilReferenceValue( 2 )

						DrawChunks( self, bone_name, m, pl.XRayTable.cur_move or 1, bone_pos, bone_ang )
						
						render.SetBlend( delta ^ 3.5 )// delta ^ 2
						self:SetupBones()
						self:DrawModel()
						render.SetBlend( 1 )
						
						render.SetStencilEnable( false )
						
						if pl.XRayTable.attacker_rag then
							DrawWeapons( self, pl.XRayTable.attacker_rag, pl.XRayTable.xray_ind, pl.XRayTable.cur_move )
						end
						
					end
				end
		end
	else
		self:DrawModel()
	end	

end

local cam_offset = Vector( -200, 0, 75 )
local zero_ang = Angle( 0, 0, 0 )
local cur_viewpos
local last_arena

local function RagdollFightCalcView( pl, origin, angles, fov, znear, zfar )
	
	local arena = pl.RagdollFightSpectator and IsValid( pl.RagdollFightArenaSpectator ) and pl.RagdollFightArenaSpectator or IsValid( pl.RagdollFightArena ) and pl.RagdollFightArena
	
	if arena and pl:Alive() then
	
		local pl1 = arena:GetPlayer( 1 )
		local pl2 = arena:GetPlayer( 2 )
		local enemy = pl == pl1 and pl2 or pl1
		
		local rag1 = arena:GetRagdollFighter( 1 )
		local rag2 = arena:GetRagdollFighter( 2 )
		
		if rag1 and rag1:IsValid() and not rag1.SetRenderOverride then
			rag1.RenderOverride = RagdollFightRagdollDraw
			rag1.SetRenderOverride = true
		end
		
		if rag2 and rag2:IsValid() and not rag2.SetRenderOverride then
			rag2.RenderOverride = RagdollFightRagdollDraw
			rag2.SetRenderOverride = true
		end
		
		local my_rag = pl == pl1 and rag1 or rag2
		
		if pl.RagdollFightSpectator then
			my_rag = rag1 or rag2
		end
		
		local enemy_rag = pl == pl1 and rag2 or rag1
		
		if pl.RagdollFightSpectator then
			my_rag = rag2 or rag1
		end
		
		local my_pos = my_rag and my_rag:IsValid() and my_rag:GetPos() or pl:GetShootPos()
		local enemy_pos = arena:GetPos() + arena:GetUp() * 75
		
		if enemy and enemy:IsValid() and enemy ~= pl and enemy_rag and enemy_rag:IsValid() then
			enemy_pos = enemy_rag:GetPos()
		end
		
		local max_dist = 390
		local dist = my_pos:Distance( enemy_pos )
		
		local my_pos_loc = arena:WorldToLocal( my_pos )
		local enemy_pos_loc = arena:WorldToLocal( enemy_pos )
		
		local dir = my_pos + enemy_pos
		
		local vec_center = ( my_pos_loc + enemy_pos_loc ) / 2

		vec_center.y = -1* math.min( 200, math.max( dist, 100 ) ) //zoom
		vec_center.z = math.max( 45, vec_center.z ) //height
		
		local add_z = 0
		
		if pl.XRayTable and pl.XRayTable.xray_time then
			if pl.XRayTable.xray_time > CurTime() then
			
				local mini_dur = pl.XRayTable.xray_dur / pl.XRayTable.xray_num
				local xray_lerp_dur = math.min( mini_dur / 3, 0.15 )
				
				if not pl.XRayTable.cur_move then
				
					pl.XRayTable.cur_move = 1
					pl.XRayTable.xray_zoom_goal = pl.XRayTable.xray_zoom_dist
					pl.XRayTable.xray_zoom = 0
					
					if not pl.XRayTable.xray_zoom_time then
						pl.XRayTable.xray_zoom_time = CurTime() + mini_dur * 0.65
						pl.XRayTable.xray_zoom_time_dur = mini_dur * 0.65
					end
					
				end
				
				if ( pl.XRayTable.xray_time - pl.XRayTable.xray_dur + pl.XRayTable.cur_move * mini_dur ) < CurTime() and pl.XRayTable.cur_move < pl.XRayTable.xray_num then
					pl.XRayTable.cur_move = math.Clamp( pl.XRayTable.cur_move + 1, 1, pl.XRayTable.xray_num )
					pl.XRayTable.xray_zoom_goal = pl.XRayTable.xray_zoom_dist
					
					if not pl.XRayTable.xray_zoom_time then
						pl.XRayTable.xray_zoom_time = CurTime() + mini_dur * 0.65
						pl.XRayTable.xray_zoom_time_dur = mini_dur * 0.65
					end
					
				end
				
				
				local rag = pl.XRayTable.enemy_rag
				local bones = pl.XRayTable.xray_bones
				
				local zoom = 1
				
				if rag and rag:IsValid() and bones and bones[ pl.XRayTable.cur_move ] then
					
					local bone_name = bones[ pl.XRayTable.cur_move ]
					local bone = rag:LookupBone( bone_name )
					
					
					if RagdollFight.XRayStances[ pl.XRayTable.xray_ind ] and RagdollFight.XRayStances[ pl.XRayTable.xray_ind ][ pl.XRayTable.cur_move ] and RagdollFight.XRayStances[ pl.XRayTable.xray_ind ][ pl.XRayTable.cur_move ].zoom_mul then
						zoom = RagdollFight.XRayStances[ pl.XRayTable.xray_ind ][ pl.XRayTable.cur_move ].zoom_mul
					end
					
					if bone then
						local m = rag:GetBoneMatrix( bone )
						if m then
							local bone_pos = m:GetTranslation()
							if bone_pos then
								local bone_pos_loc = arena:WorldToLocal( bone_pos )
								local delta = 1 - ( pl.XRayTable.xray_zoom_goal - pl.XRayTable.xray_zoom ) / pl.XRayTable.xray_zoom_dist
								
								vec_center = LerpVector( delta, vec_center, bone_pos_loc )
								vec_center.y = -1* math.min( 200, math.max( dist, 100 ) ) //zoom
								vec_center.z = math.max( 5, vec_center.z ) //height
							end
						end					
					end
					
				end
				
				local rate = FrameTime() * 100
				
				if pl.XRayTable.xray_zoom_time then
					if pl.XRayTable.xray_zoom_time >= CurTime() then
						rate = FrameTime() * 250
					else
						pl.XRayTable.xray_zoom_goal = 0
						pl.XRayTable.xray_zoom_time = nil
					end
				
				end
				
				pl.XRayTable.xray_zoom = math.Approach( pl.XRayTable.xray_zoom, pl.XRayTable.xray_zoom_goal, rate )
				
				vec_center.y = vec_center.y + pl.XRayTable.xray_zoom * zoom
			else
				pl.XRayTable = nil
			end
		end
		
		
		local pos, ang = arena:GetPos(), arena:GetAngles()

		local newpos, newang = LocalToWorld( vec_center, zero_ang, pos, ang )
		newang:RotateAroundAxis( arena:GetUp(), 90 )
		
		if not cur_viewpos or last_arena ~= arena then
			last_arena = arena
			cur_viewpos = newpos
		end
		
		cur_viewpos = LerpVector( FrameTime()*3, cur_viewpos, newpos )

		return { origin = newpos, angles = newang, drawviewer = true }
		
	end
end
hook.Add( "CalcView", "RagdollFightCalcView", RagdollFightCalcView )

local hide_stuff = {
	CHudHealth = true,
	CHudBattery = true,
	CHudCrosshair = true,
}

hook.Add( "HUDShouldDraw", "RagdollFightHUDShouldDraw", function( name )
	local pl = LocalPlayer()
	if pl and pl.RagdollFightArena and pl.RagdollFightArena:IsValid() then
		if hide_stuff[ name ] then 
			return false
		end
	end
	if pl and pl.RagdollFightSpectator and pl.RagdollFightArenaSpectator and pl.RagdollFightArenaSpectator:IsValid() then 
		if hide_stuff[ name ] then 
			return false
		end
	end
end )

hook.Add( "HUDDrawTargetID", "RagdollFightHUDDrawTargetID", function( )
	local pl = LocalPlayer()
	if pl and pl.RagdollFightArena and pl.RagdollFightArena:IsValid() then return false end
	if pl and pl.RagdollFightSpectator and pl.RagdollFightArenaSpectator and pl.RagdollFightArenaSpectator:IsValid() then return false end
end )
	
	
end