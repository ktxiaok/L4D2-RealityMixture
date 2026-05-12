local ctx = this;

class FaceAnomaly
{
	_valid = true;

	_hostEnt = null;
	_sprite = ctx.InvalidValue;
	_hostEffectTrigger = null;

	_effectTriggerStartTouchCallback = null;
	_effectTriggerMonitor = null;
	_infectedEffectTriggerMonitor = null;

	_effectCoroutineRef = null;
	_infectedEffectCoroutineRef = null;

	_directEffectRange = null;
	_directEffectRangeSqr = null;

	constructor(hostEnt, args = null)
	{
		local self = this;

		_hostEnt = hostEnt;
		if (args)
		{
			if ("EffectTrigger" in args)
			{
				_hostEffectTrigger = args.EffectTrigger;
			}
			if ("DirectEffectRange" in args)
			{
				_directEffectRange = args.DirectEffectRange;
			}
		}
		if (args && "SpriteMaterial" in args)
		{
			SetSpriteMaterial(args.SpriteMaterial);
		}
		else
		{
			SetDefaultSprite();
		}
		if (_directEffectRange == null)
		{
			_directEffectRange = ctx.ConfigItems.GetValue("FaceAnomalyDirectEffectRange");
		}
		_directEffectRangeSqr = _directEffectRange * _directEffectRange;

		_effectCoroutineRef = ctx.AliveCoroutineRef();
		_infectedEffectCoroutineRef = ctx.AliveCoroutineRef();

		_hostEnt.ValidateScriptScope();
		local hostEntScope = _hostEnt.GetScriptScope();
		hostEntScope.FaceAnomaly <- this;
		hostEntScope.SetPosition <- @(pos) FaceAnomaly.SetPosition(pos);

		local effectTrigger = _hostEffectTrigger;
		if (effectTrigger == null)
		{
			local effectRange = ctx.ConfigItems.GetValue("FaceAnomalyEffectRange");
			effectTrigger = SpawnEntityFromTable("script_trigger_multiple", {
				spawnflags = ctx.SF_TRIGGER_ALLOW_CLIENTS,
				origin = _hostEnt.GetOrigin(),
				extent = Vector(effectRange, effectRange, effectRange),
				allowincap = 1
			});
			ctx.SetEntityParent(effectTrigger, _hostEnt);
		}
		effectTrigger.ValidateScriptScope();
		local effectTriggerScope = effectTrigger.GetScriptScope();
		_effectTriggerStartTouchCallback = @(args) self._OnEffectTriggerStartTouch(args);
		if ("FaceAnomalyEffectTriggerMonitor" in effectTriggerScope)
		{
			_effectTriggerMonitor = effectTriggerScope.FaceAnomalyEffectTriggerMonitor;
			_effectTriggerMonitor.AddStartTouchCallback(effectTriggerStartTouchCallback);
		}
		if (_effectTriggerMonitor == null)
		{
			_effectTriggerMonitor = ctx.TriggerTouchingMonitor(effectTrigger, {
				Filter = @(ent) ctx.IsAliveSurvivor(ent),
				StartTouchCallback = _effectTriggerStartTouchCallback
			});
			effectTriggerScope.FaceAnomalyEffectTriggerMonitor <- _effectTriggerMonitor;
		}

		local infectedEffectTrigger = SpawnEntityFromTable("script_trigger_multiple", {
			spawnflags = ctx.SF_TRIGGER_ALLOW_CLIENTS | ctx.SF_TRIGGER_ALLOW_NPCS,
			origin = _hostEnt.GetOrigin(),
			extent = Vector(_directEffectRange, _directEffectRange, _directEffectRange)
		});
		ctx.SetEntityParent(infectedEffectTrigger, _hostEnt);
		_infectedEffectTriggerMonitor = ctx.TriggerTouchingMonitor(infectedEffectTrigger, {
			Filter = @(ent) ctx.IsInfectedEntity(ent),
			StartTouchCallback = @(args) self._OnInfectedEffectTriggerStartTouch(args)
		});

		ctx.AddEntityInvalidationListener(_hostEnt, @() self.IsValid());
	}

	function IsValid()
	{
		if (!_valid)
		{
			return false;
		}
		if (!_hostEnt.IsValid())
		{
			_valid = false;
			OnKilled();
		}
		return _valid;
	}

	function GetHostEntity() { return _hostEnt; }

	function GetPosition() { return _hostEnt.GetOrigin(); }

	function SetPosition(pos)
	{
		_hostEnt.SetOrigin(pos);
	}

	function GetSpriteMaterialName()
	{
		if (!_sprite.IsValid())
		{
			return null;
		}

		return _sprite.GetModelName();
	}

	function SetSpriteMaterial(material)
	{
		if (material == null)
		{
			if (_sprite.IsValid())
			{
				_sprite.Kill();
				_sprite = ctx.InvalidValue;
			}
			return;
		}

		if (!_sprite.IsValid())
		{
			_sprite = SpawnEntityFromTable("env_sprite", {
				spawnflags = ctx.SF_SPRITE_STARTON,
				rendermode = ctx.kRenderWorldGlow,
				scale = 0.5,
				origin = _hostEnt.GetOrigin()
			});
			ctx.SetEntityParent(_sprite, _hostEnt);
		}

		_sprite.SetModel(material);
	}

	function IsEntityVisible(ent, rough = false)
	{
		local entPos = "EyePosition" in ent ? ent.EyePosition() : ent.GetOrigin();
		local traceTable = {
			start = GetPosition(),
			end = entPos,
			mask = rough ? ctx.MASK_OPAQUE : ctx.MASK_OPAQUE_AND_NPCS,
			ignore = ent
		};
		if (TraceLine(traceTable))
		{
			return !traceTable.hit;
		}
		return false;
	}

	function SetDefaultSprite()
	{
		SetSpriteMaterial(ctx.GetMaterialName("FaceAnomalyCommon"));
	}

	function OnKilled()
	{
		_effectCoroutineRef.Kill();
		_infectedEffectCoroutineRef.Kill();

		if (_hostEffectTrigger)
		{
			_effectTriggerMonitor.RemoveStartTouchCallback(_effectTriggerStartTouchCallback);
		}
		else
		{
			local effectTrigger = _effectTriggerMonitor.GetTrigger();
			if (effectTrigger.IsValid())
			{
				effectTrigger.Kill();
			}
	    }
		local infectedEffectTrigger = _infectedEffectTriggerMonitor.GetTrigger();
		if (infectedEffectTrigger.IsValid())
		{
			infectedEffectTrigger.Kill();
		}
		if (_sprite.IsValid())
		{
			_sprite.Kill();
		}
		if (_hostEnt.IsValid())
		{
			_hostEnt.Kill();
		}
	}

	function _TryCreateEffectCoroutine()
	{
		local coroutine = _effectCoroutineRef.Get();
		if (!coroutine)
		{
			local self = this;
			coroutine = ctx.Coroutine.Loop(@() self._EffectUpdate(coroutine.GetDeltaTime()));
			coroutine.Start();
			_effectCoroutineRef.Set(coroutine);
		}
	}

	function _TryCreateInfectedEffectCoroutine()
	{
		local coroutine = _infectedEffectCoroutineRef.Get();
		if (!coroutine)
		{
			local self = this;
			coroutine = ctx.Coroutine.Loop(@() self._InfectedEffectUpdate() ? 0.5 : null);
			coroutine.Start();
			_infectedEffectCoroutineRef.Set(coroutine);
		}
	}

	function _OnEffectTriggerStartTouch(args)
	{
		if (!IsValid())
		{
			return;
		}
		_TryCreateEffectCoroutine();
	}

	function _OnInfectedEffectTriggerStartTouch(args)
	{
		if (!IsValid())
		{
			return;
		}
		_TryCreateInfectedEffectCoroutine();
	}

	function _EffectUpdate(deltaTime)
	{
		if (!IsValid())
		{
			return false;
		}

		local targets = _effectTriggerMonitor.GetTouchingEntities();
		if (targets.len() == 0)
		{
			return false;
		}

		local visCosMin = ctx.ConfigItems.GetValue("FaceAnomalyEffectVisCosMin");
		local insanityMagnitude = ctx.ConfigItems.GetValue("FaceAnomalyInsanityMagnitude");
		local insanityAtt = ctx.ConfigItems.GetValue("FaceAnomalyInsanityAttenuation");
		local pos = GetPosition();
		foreach (target in targets)
		{
			local targetPos = target.EyePosition();
			local displacement = pos - targetPos;
			local distanceSqr = displacement.LengthSqr();
			if (distanceSqr > _directEffectRangeSqr)
			{
				if (!IsPlayerABot(target) && IsEntityVisible(target))
				{
					local distance = sqrt(distanceSqr);
					local displacementNorm = displacement * (1.0 / distance);
					local eyeDir = target.EyeAngles().Forward();
					local visibility = eyeDir.Dot(displacementNorm);
					if (visibility > visCosMin)
					{
						visibility = (visibility - visCosMin) / (1 - visCosMin);
						local insanityController = ctx.InsanityController.TryGetOrCreate(target);
						if (insanityController)
						{
							insanityController.SuppressInsanityDecay(0.5);
							local insanityRate = visibility * insanityMagnitude / (distanceSqr * insanityAtt + 1);
							insanityController.IncreaseInsanity(insanityRate * deltaTime);
						}
					}
				}
			}
			else
			{
				if (IsEntityVisible(target, true))
				{
					local insanityController = ctx.InsanityController.TryGetOrCreate(target);
					if (insanityController)
					{
						insanityController.SuppressInsanityDecay(0.5);
						insanityController.IncreaseInsanity(insanityMagnitude * deltaTime);
					}
				}
			}
		}

		return true;
	}

	function _InfectedEffectUpdate()
	{
		if (!IsValid())
		{
			return false;
		}

		local targets = _infectedEffectTriggerMonitor.GetTouchingEntities();
		if (targets.len() == 0)
		{
			return false;
		}

		local damage = ctx.ConfigItems.GetValue("FaceAnomalyInfectedDamage");
		foreach (target in targets)
		{
			if (IsEntityVisible(target, true))
			{
				target.TakeDamage(damage, 0, null);
			}
		}

		return true;
	}
}