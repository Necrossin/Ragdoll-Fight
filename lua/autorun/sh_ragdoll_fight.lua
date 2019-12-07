AddCSLuaFile() 

RagdollFight = {}

for i = 1, 2 do
	util.PrecacheSound( "ambient/machines/slicer"..i..".wav" )
end
for i = 2, 4 do
	util.PrecacheSound( "physics/body/body_medium_break"..i..".wav" )
end
for i = 5, 7 do
	util.PrecacheSound( "physics/body/body_medium_impact_soft"..i..".wav" )
end
for i = 7, 9 do
	util.PrecacheSound( "vo/npc/male01/pain0"..i..".wav" )
end
for i = 2, 4 do
	util.PrecacheSound( "physics/wood/wood_strain"..i..".wav" )
end
for i = 2, 3 do
	util.PrecacheSound( "weapons/357/357_fire"..i..".wav" )
end
for i = 6, 7 do
	util.PrecacheSound( "weapons/shotgun/shotgun_fire"..i..".wav" )
end

for i = 1, 4 do
	util.PrecacheSound( "vehicles/v8/vehicle_impact_heavy"..i..".wav" )
end

util.PrecacheSound( "npc/antlion_guard/shove1.wav" )
util.PrecacheSound( "npc/headcrab/headbite.wav" )
util.PrecacheSound( "weapons/shotgun/shotgun_dbl_fire.wav" )
util.PrecacheSound( "ambient/alarms/train_horn_distant1.wav" )
util.PrecacheSound( "ambient/materials/cartrap_explode_impact1.wav" )
util.PrecacheSound( "ambient/materials/cartrap_explode_impact2.wav" )

util.PrecacheModel( "models/dav0r/camera.mdl" )


if SERVER then
	resource.AddFile( "materials/entities/ragdollfight_arena.png" )
	
	RagdollFight.Ragdolls = {}
end

RAGDOLL_STANCE_IDLE = 0
RAGDOLL_STANCE_ATTACK = 1
RAGDOLL_STANCE_JUMP_ATTACK = 2
RAGDOLL_STANCE_GRAB = 3
RAGDOLL_STANCE_CROUCH_ATTACK = 4
RAGDOLL_STANCE_GRAB_IDLE = 5
RAGDOLL_STANCE_GRAB_JUMP = 6
RAGDOLL_STANCE_GRAB_ATTACK_SLAM = 7
RAGDOLL_STANCE_GRAB_ATTACK_THROW = 8
RAGDOLL_STANCE_GRAB_ATTACK_BACKTHROW = 9
RAGDOLL_STANCE_JUMP_ATTACK_SPRINT = 10
RAGDOLL_STANCE_BLOCK = 11
RAGDOLL_STANCE_SLIDE = 12
RAGDOLL_STANCE_TAUNT = 13

RAGDOLL_BLOCK_NORMAL = 1
RAGDOLL_BLOCK_CROUCH = 2

RAGDOLL_ATTACK_NORMAL = 1
RAGDOLL_ATTACK_CROUCH = 2
RAGDOLL_ATTACK_ANY = 3

RAGDOLL_DAMAGE_FISTS = 3
RAGDOLL_DAMAGE_LEG = 4
RAGDOLL_DAMAGE_LEG_HEAVY = 7
RAGDOLL_DAMAGE_LEG_SLIDE = 7
RAGDOLL_DAMAGE_GRAB_THROW = 6//13
RAGDOLL_DAMAGE_XRAY = 35

RAGDOLL_POWERUP_BREAKER = 1
RAGDOLL_POWERUP_HEAVYATTACK = 2
RAGDOLL_POWERUP_XRAY = 3

RAGDOLL_XRAY_ATTACKER = 1
RAGDOLL_XRAY_VICTIM = 2

//I'm not gonna use convars, because these are gonna be reset anyway
RAGDOLL_BOT_FORCE_ATTACK = false
RAGDOLL_BOT_FORCE_GRAB = false
RAGDOLL_BOT_FORCE_JUMP = false
RAGDOLL_BOT_FORCE_CROUCH = false
RAGDOLL_BOT_FORCE_BLOCK = false
RAGDOLL_BOT_FORCE_MIRROR = false

include( "autorun/sv_ragdoll_fight.lua" )
include( "autorun/cl_ragdoll_fight.lua" )

include( "autorun/stances/sh_stances.lua" )
include( "autorun/stances/sh_xray_stances.lua" )


local function RagdollFightMove( pl, cmd )
	
	if pl.RagdollFightArena and pl.RagdollFightArena:IsValid() and pl:Alive() then
		local ang = pl.RagdollFightArena:GetAngles()
		ang:RotateAroundAxis( pl.RagdollFightArena:GetUp(), 90 )
		cmd:SetMoveAngles( ang )
		cmd:SetForwardSpeed( 0 )
		cmd:SetMaxSpeed( 200 ) 
		cmd:SetMaxClientSpeed( 200 ) 
	end
	
end
hook.Add( "Move", "RagdollFightMove", RagdollFightMove )

hook.Add( "PhysgunPickup", "RagdollFightPhysgunPickup", function( pl, ent )
	if ent:GetClass() == "ragdollfight_arena" then return false end
	if ent:GetClass() == "prop_ragdoll" and ent.IsRagdollFighter then return false end
end)


hook.Add( "PlayerNoClip", "RagdollFightPlayerNoClip", function( pl )
	if pl and pl.RagdollFightArena and pl.RagdollFightArena:IsValid() then return false end
end )

//thats a scary hook, without CollisionRulesChanged
local function RagdollFightShouldCollide( ent1, ent2 )
	if ent1:IsPlayer() and ent1.RagdollFightArena and ent1.RagdollFightArena:IsValid() and ent1:Alive() then
		local rag1 = ent1.RagdollFightArena:GetRagdollFighter( 1 )
		local rag2 = ent1.RagdollFightArena:GetRagdollFighter( 2 )
		if ent2 and ent2:IsValid() and ( ent2 == rag1 or ent2 == rag2 ) then
			return false
		end
	end
	if ent2:IsPlayer() and ent2.RagdollFightArena and ent2.RagdollFightArena:IsValid() and ent2:Alive() then
		local rag1 = ent2.RagdollFightArena:GetRagdollFighter( 1 )
		local rag2 = ent2.RagdollFightArena:GetRagdollFighter( 2 )
		if ent1 and ent1:IsValid() and ( ent1 == rag1 or ent1 == rag2 ) then
			return false
		end
	end
end
hook.Add( "ShouldCollide", "RagdollFightShouldCollide", RagdollFightShouldCollide )
