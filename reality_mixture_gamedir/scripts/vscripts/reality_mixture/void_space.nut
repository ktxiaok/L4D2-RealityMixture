local ctx = this;

const VoidSpaceDissolveMagnitude = 6;
const VoidSpaceDissolveType = 0;

class VoidSpace
{
	_triggerEnt = null;

	constructor(triggerEnt)
	{
		_triggerEnt = triggerEnt;

		_triggerEnt.ValidateScriptScope();
		local triggerEntScope = _triggerEnt.GetScriptScope();
		triggerEntScope.VoidSpace_OnStartTouch <- function()
		{
			if (activator && activator.IsValid())
			{
				VoidSpace.AffectEntity(activator);
			}
		};
		_triggerEnt.ConnectOutput("OnStartTouch", "VoidSpace_OnStartTouch");
		triggerEntScope.VoidSpace <- this;
	}

	function GetTrigger() { return _triggerEnt; }

	function AffectEntity(ent)
	{
		local self = this;

		ent.SetVelocity(Vector(0.0, 0.0, 0.0));

		if (ent.IsPlayer() && ent.IsSurvivor())
		{
			local coroutine = ctx.Coroutine(function()
			{
				local animatingData = ctx.GetEntityAnimatingData(ent);

				local fatalDamageCoroutine = ctx.TakeFatalDamage(ent);
				if (fatalDamageCoroutine)
				{
					yield fatalDamageCoroutine;
					animatingData = ctx.GetEntityAnimatingData(ent);
				}

				if (ent.IsValid())
				{
					local deathModel = Entities.FindByClassnameWithin(null, "survivor_death_model", ent.GetOrigin(), 50.0);
					if (deathModel)
					{
						NetProps.SetPropInt(deathModel, "m_nRenderMode", 10);
					}
				}

				local dummyProp = SpawnEntityFromTable("prop_dynamic_override", { solid = 0, model = ctx.NullModelName });
				ctx.SetEntityAnimatingData(dummyProp, animatingData);
				self._DissolveEntity(dummyProp);
			}());
			coroutine.SetAutoKilledOnNewRound(true);
			coroutine.Start();
		}
		else if (ctx.IsInfectedEntity(ent))
		{
			ctx.SetInfectedDeathDissolveMagnitude(ent, VoidSpaceDissolveMagnitude);
			ctx.SetInfectedDeathDissolveType(ent, VoidSpaceDissolveType);
			ctx.TakeFatalDamage(ent);
		}
		else
		{
			local entClassname = ent.GetClassname();

			if (entClassname == "prop_physics")
			{
				ent.SetVelocity(Vector(RandomFloat(-100, 100), RandomFloat(-100, 100), RandomFloat(-100, 50)));
			}
			else if (entClassname == "molotov_projectile")
			{
				StopSoundOn("Molotov.Loop", ent);
			}
			if (ctx.StringEndsWith(entClassname, "projectile"))
			{
				ent.SetVelocity(Vector(0, 0, 50));
			}

			NetProps.SetPropInt(ent, "movetype", ctx.MOVETYPE_FLY);

			_DissolveEntity(ent);
		}
	}

	function _DissolveEntity(ent)
	{
		ctx.DissolveEntity(ent, VoidSpaceDissolveMagnitude, VoidSpaceDissolveType);
	}
}