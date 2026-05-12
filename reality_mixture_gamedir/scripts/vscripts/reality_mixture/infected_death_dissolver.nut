local ctx = this;

const DefaultInfectedDeathDissolveMagnitude = 1;
const DefaultInfectedDeathDissolveType = 3;

local ScopeSoltName_InfectedDeathDissolverEnabled = UniqueString("infectedDeathDissolverEnabled");
local ScopeSlotName_InfectedDeathDissolveMagnitude = UniqueString("infectedDeathDissolveMagnitude");
local ScopeSlotName_InfectedDeathDissolveType = UniqueString("infectedDeathDissolveType");

function IsInfectedDeathDissolverEnabled(infected)
{
	local infectedScope = infected.GetScriptScope();
	if (!infectedScope || !(ScopeSoltName_InfectedDeathDissolverEnabled in infectedScope))
	{
		return true;
	}
	return infectedScope[ScopeSoltName_InfectedDeathDissolverEnabled];
}

function SetInfectedDeathDissolverEnabled(infected, enabled)
{
	infected.ValidateScriptScope();
	infected.GetScriptScope()[ScopeSoltName_InfectedDeathDissolverEnabled] <- enabled;
}

function GetInfectedDeathDissolveMagnitude(infected)
{
	local infectedScope = infected.GetScriptScope();
	if (!infectedScope || !(ScopeSlotName_InfectedDeathDissolveMagnitude in infectedScope))
	{
		return DefaultInfectedDeathDissolveMagnitude;
	}
	return infectedScope[ScopeSlotName_InfectedDeathDissolveMagnitude];
}

function SetInfectedDeathDissolveMagnitude(infected, magnitude)
{
	infected.ValidateScriptScope();
	infected.GetScriptScope()[ScopeSlotName_InfectedDeathDissolveMagnitude] <- magnitude;
}

function GetInfectedDeathDissolveType(infected)
{
	local infectedScope = infected.GetScriptScope();
	if (!infectedScope || !(ScopeSlotName_InfectedDeathDissolveType in infectedScope))
	{
		return DefaultInfectedDeathDissolveType;
	}
	return infectedScope[ScopeSlotName_InfectedDeathDissolveType];
}

function SetInfectedDeathDissolveType(infected, dissolveType)
{
	infected.ValidateScriptScope();
	infected.GetScriptScope()[ScopeSlotName_InfectedDeathDissolveType] <- dissolveType;
}

function InfectedDeathDissolve(infected)
{
	local dissolveMagnitude = GetInfectedDeathDissolveMagnitude(infected);
	local dissolveType = GetInfectedDeathDissolveType(infected);

	if (infected.IsPlayer())
	{
		local prop = CreatePropDynamicFromEntity(infected);
		DissolveEntity(prop, dissolveMagnitude, dissolveType);
	}
	else
	{
		NetProps.SetPropInt(infected, "m_nRenderFX", 6);
		DissolveEntity(infected, dissolveMagnitude, dissolveType);
	}

	local ragdollFader = SpawnEntityFromTable("func_ragdoll_fader", {
		origin = infected.GetOrigin()
	});
	NetProps.SetPropInt(ragdollFader, "m_Collision.m_nSolidType", 2);
	NetProps.SetPropVector(ragdollFader, "m_Collision.m_vecMins", Vector(-100.0, -100.0, -100.0));
	NetProps.SetPropVector(ragdollFader, "m_Collision.m_vecMaxs", Vector(100.0, 100.0, 100.0));
	DoEntFire("!caller", "Kill", "", 0.5, null, ragdollFader);
}

EventCallbackRegistry.Get("OnGameEvent_player_death").Register(function(args)
{
	local infected = null;
	if ("userid" in args)
	{
		local player = GetPlayerFromUserID(args.userid);
		if (!player.IsSurvivor())
		{
			infected = player;
		}
	}
	else
	{
		local ent = Ent(args.entityid);
		if (IsInfectedEntity(ent))
		{
			infected = ent;
		}
	}
	if (infected && IsInfectedDeathDissolverEnabled(infected))
	{
		InfectedDeathDissolve(infected);
	}
}.bindenv(ctx));