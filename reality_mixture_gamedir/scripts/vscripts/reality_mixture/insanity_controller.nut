local ctx = this;

local ScopeSlotName_InsanityController = UniqueString("insanityController");

class InsanityController
{
	_valid = true;

	_targetEnt = null;

	_coroutineRef = null;
	_screenFadeCoroutineRef = null;
	_eyeDeflectionCoroutineRef = null;
	_noiseCoroutineRef = null;
	_horrorViewCoroutineRef = null;
	_damageCoroutineRef = null;

	_insanity = 0.0;
	_insanityDecaySuppressionTimer = null;

	_horrorViewPicker = null;

	constructor(targetEnt)
	{
		_targetEnt = targetEnt;
		_coroutineRef = ctx.AliveCoroutineRef();
		_screenFadeCoroutineRef = ctx.AliveCoroutineRef();
		_eyeDeflectionCoroutineRef = ctx.AliveCoroutineRef();
		_noiseCoroutineRef = ctx.AliveCoroutineRef();
		_horrorViewCoroutineRef = ctx.AliveCoroutineRef();
		_damageCoroutineRef = ctx.AliveCoroutineRef();
		_horrorViewPicker = ctx.ShufflePicker(ctx.ViewNames.HorrorCommon);

		_targetEnt.ValidateScriptScope();
		local targetEntScope = _targetEnt.GetScriptScope();
		if (ScopeSlotName_InsanityController in targetEntScope)
		{
			targetEntScope[ScopeSlotName_InsanityController].Kill();
		}
		targetEntScope[ScopeSlotName_InsanityController] <- this;

		local self = this;
		ctx.AddEntityInvalidationListener(_targetEnt, @() self.Kill());
	}

	static TryCreate = function(targetEnt)
	{
		if (!IsApplicableTargetEntity(targetEnt))
		{
			return null;
		}
		return ctx.InsanityController(targetEnt);
	}

	static TryGetOrCreate = function(targetEnt)
	{
		if (!IsApplicableTargetEntity(targetEnt))
		{
			return null;
		}
		local targetEntScope = targetEnt.GetScriptScope();
		if (targetEntScope && ScopeSlotName_InsanityController in targetEntScope)
		{
			return targetEntScope[ScopeSlotName_InsanityController];
		}
		return ctx.InsanityController(targetEnt);
	};

	static IsApplicableTargetEntity = function(ent)
	{
		return ctx.IsAliveSurvivor(ent);
	};

	function IsValid()
	{
		if (!_valid)
		{
			return false;
		}
		if (!_targetEnt.IsValid() || !IsApplicableTargetEntity(_targetEnt))
		{
			Kill();
		}
		return _valid;
	}

	function GetTargetEntity() { return _targetEnt; }

	function GetInsanity() { return _insanity; }

	function SetInsanity(insanity)
	{
		_insanity = ctx.Clamp(insanity, 0, ctx.ConfigItems.GetValue("InsanityMax")).tofloat();
		if (_insanity > 0)
		{
			_TryCreateCoroutine();
		}
	}

	function IsInsanityDecaySuppressed()
	{
		return _insanityDecaySuppressionTimer != null;
	}

	function IncreaseInsanity(increment, max = null)
	{
		local insanity = _insanity;
		if (max != null && insanity >= max)
		{
			return;
		}
		insanity += increment;
		if (max != null && insanity > max)
		{
			insanity = max;
		}
		SetInsanity(insanity);
	}

	function SuppressInsanityDecay(duration)
	{
		if (duration < 0)
		{
			return;
		}
		if (_insanityDecaySuppressionTimer == null || duration > _insanityDecaySuppressionTimer)
		{
			_insanityDecaySuppressionTimer = duration;
			_TryCreateCoroutine();
		}
	}

	function Kill()
	{
		if (!_valid)
		{
			return;
		}

		_valid = false;
		_coroutineRef.Kill();
		if (_targetEnt.IsValid())
		{
			local targetEntScope = _targetEnt.GetScriptScope();
			if (targetEntScope && ScopeSlotName_InsanityController in targetEntScope)
			{
				delete targetEntScope[ScopeSlotName_InsanityController];
			}
		}
	}

	function _TryCreateCoroutine()
	{
		local coroutine = _coroutineRef.Get();
		if (coroutine)
		{
			return;
		}

		local self = this;
		coroutine = ctx.Coroutine.Loop(@() self._Update(coroutine.GetDeltaTime()));
		coroutine.SetOnDead(function()
		{
			if (self._targetEnt.IsValid())
			{
				self._SetEyeDeflection(0);
			}
		});
		coroutine.Start();
		_coroutineRef.Set(coroutine);
	}

	function _Update(deltaTime)
	{
		if (!IsValid())
		{
			return false;
		}

		if (_insanityDecaySuppressionTimer != null)
		{
			_insanityDecaySuppressionTimer -= deltaTime;
			if (_insanityDecaySuppressionTimer <= 0)
			{
				_insanityDecaySuppressionTimer = null;
			}
		}

		if (!IsInsanityDecaySuppressed())
		{
			_insanity -= ctx.ConfigItems.GetValue("InsanityDecayRate") * deltaTime;
		}

		if (_insanity <= 0)
		{
			_insanity = 0.0;

			return _insanityDecaySuppressionTimer != null;
		}

		local maxInsanity = ctx.ConfigItems.GetValue("InsanityMax");
		if (_insanity > maxInsanity)
		{
			_insanity = maxInsanity;
		}

		local self = this;

		local intensity = _insanity / maxInsanity;

		local screenFadeCoroutine = _screenFadeCoroutineRef.Get();
		if (!screenFadeCoroutine)
		{
			local alpha = (255 * ctx.Max(intensity, 0.4)).tointeger();
			local fadeTime = ctx.ConfigItems.GetValue("InsanityScreenFadeTime");
			local fadeHold = ctx.ConfigItems.GetValue("InsanityScreenFadeHold");
			local minInterval = ctx.ConfigItems.GetValue("InsanityScreenFadeIntervalMin");
			local maxInterval = ctx.ConfigItems.GetValue("InsanityScreenFadeIntervalMax");
			maxInterval = ctx.Max(minInterval, maxInterval);
			local currentMaxInterval = minInterval + ctx.Max(0.5, 1 - intensity) * (maxInterval - minInterval);
			local interval = RandomFloat(minInterval, currentMaxInterval);
			screenFadeCoroutine = ctx.Coroutine.DoThenWait(function()
			{
				ScreenFade(self._targetEnt, 255, 0, 0, alpha, fadeTime, fadeHold, ctx.FFADE_IN | ctx.FFADE_MODULATE);
				return interval;
			});
			screenFadeCoroutine.Start();
			_screenFadeCoroutineRef.Set(screenFadeCoroutine);
		}

		local eyeDeflectionCoroutine = _eyeDeflectionCoroutineRef.Get();
		if (!eyeDeflectionCoroutine)
		{
			local maxDeflection = ctx.ConfigItems.GetValue("InsanityEyeDeflectionMax");
			local currentMaxDeflection = maxDeflection * intensity;
			local deflection = RandomFloat(-currentMaxDeflection, currentMaxDeflection);
			local minInterval = ctx.ConfigItems.GetValue("InsanityEyeDeflectionIntervalMin");
			local maxInterval = ctx.ConfigItems.GetValue("InsanityEyeDeflectionIntervalMax");
			maxInterval = ctx.Max(minInterval, maxInterval);
			local currentMaxInterval = minInterval + ctx.Max(0.5, 1 - intensity) * (maxInterval - minInterval);
			local interval = RandomFloat(minInterval, currentMaxInterval);
			eyeDeflectionCoroutine = ctx.Coroutine.DoThenWait(function()
			{
				self._SetEyeDeflection(deflection);
				return interval;
			});
			eyeDeflectionCoroutine.Start();
			_eyeDeflectionCoroutineRef.Set(eyeDeflectionCoroutine);
		}

		local horrorViewThreshold = ctx.ConfigItems.GetValue("InsanityHorrorViewThreshold");
		if (_insanity > horrorViewThreshold)
		{
			local intensity = (_insanity - horrorViewThreshold) / (maxInsanity - horrorViewThreshold);

			local horrorViewCoroutine = _horrorViewCoroutineRef.Get();
			if (!horrorViewCoroutine)
			{
				local minDuration = ctx.ConfigItems.GetValue("InsanityHorrorViewDurationMin");
				local maxDuration = ctx.ConfigItems.GetValue("InsanityHorrorViewDurationMax");
				maxDuration = ctx.Max(minDuration, maxDuration);
				local minInterval = ctx.ConfigItems.GetValue("InsanityHorrorViewIntervalMin");
				local maxInterval = ctx.ConfigItems.GetValue("InsanityHorrorViewIntervalMax");
				maxInterval = ctx.Max(minInterval, maxInterval);
				local duration = minDuration + intensity * (maxDuration - minDuration);
				local interval = minInterval + (1 - intensity) * (maxInterval - minInterval);
				horrorViewCoroutine = ctx.Coroutine.DoThenWait(function()
				{
					local viewController = ctx.ViewController.TryGetOrCreate(self._targetEnt);
					if (viewController)
					{
						local viewName = self._horrorViewPicker.Pick();
						if (viewName)
						{
							viewController.Activate(viewName, duration);
							self._PlayNoise();
							return duration + interval;
						}
					}
				});
				horrorViewCoroutine.Start();
				_horrorViewCoroutineRef.Set(horrorViewCoroutine);
			}

			local noiseCoroutine = _noiseCoroutineRef.Get();
			if (!noiseCoroutine)
			{
				local minInterval = ctx.ConfigItems.GetValue("InsanityNoiseIntervalMin");
				local maxInterval = ctx.ConfigItems.GetValue("InsanityNoiseIntervalMax");
				maxInterval = ctx.Max(minInterval, maxInterval);
				local currentMaxInterval = minInterval + ctx.Max(0.5, 1 - intensity) * (maxInterval - minInterval);
				local interval = RandomFloat(minInterval, currentMaxInterval);
				noiseCoroutine = ctx.Coroutine.DoThenWait(function()
				{
					self._PlayNoise();
					return interval;
				});
				noiseCoroutine.Start();
				_noiseCoroutineRef.Set(noiseCoroutine);
			}
		}

		local damageThreshold = ctx.ConfigItems.GetValue("InsanityDamageThreshold");
		if (_insanity > damageThreshold)
		{
			local damageCoroutine = _damageCoroutineRef.Get();
			if (!damageCoroutine)
			{
				local maxDamage = ctx.ConfigItems.GetValue("InsanityDamageMax");
				local intensity = (_insanity - damageThreshold) / (maxInsanity - damageThreshold);
				local damage = (intensity * maxDamage).tointeger();
				if (damage > 0)
				{
					local interval = ctx.ConfigItems.GetValue("InsanityDamageInterval");
					damageCoroutine = ctx.Coroutine.DoThenWait(function()
					{
						ctx.TakeDamageConvertToBuffer(self._targetEnt, damage);
						return interval;
					});
					damageCoroutine.Start();
					_damageCoroutineRef.Set(damageCoroutine);
				}
			}
		}

		return true;
	}

	function _PlayNoise()
	{
		EmitSoundOnClient("RealityMixture.Player.InsanityNoise", _targetEnt);
	}

	function _SetEyeDeflection(angle)
	{
		local eyeAngles = _targetEnt.EyeAngles();
		eyeAngles.z = angle;
		_targetEnt.SnapEyeAngles(eyeAngles);
	}
}

EventCallbackRegistry.Get("OnGameEvent_player_spawn").Register(function(args)
{
	local player = GetPlayerFromUserID(args.userid);
	InsanityController.TryCreate(player);
}.bindenv(ctx));