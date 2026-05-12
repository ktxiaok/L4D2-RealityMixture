local ctx = this;

class InsanitySpace
{
	_trigger = null;
	_triggerMonitor = null;

	_coroutineRef = null;

	constructor(trigger)
	{
		local self = this;

		_trigger = trigger;
		_coroutineRef = ctx.AliveCoroutineRef();

		_trigger.ValidateScriptScope();
		_trigger.GetScriptScope().InsanitySpace <- this;

		_triggerMonitor = ctx.TriggerTouchingMonitor(_trigger, {
			Filter = IsApplicableEntity,
			StartTouchCallback = @(args) self._OnStartTouch(args)
		})
	}

	static IsApplicableEntity = function(ent)
	{
		return ent.IsPlayer() && ent.IsSurvivor() && !ctx.IsPlayerDead(ent);
	};

	function IsValid()
	{
		return _trigger.IsValid() && _triggerMonitor.IsValid();
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
		coroutine.Start();
		_coroutineRef.Set(coroutine);
	}

	function _OnStartTouch(args)
	{
		_TryCreateCoroutine();
	}

	function _Update(deltaTime)
	{
		if (!IsValid())
		{
			return false;
		}

		local touchingEntities = _triggerMonitor.GetTouchingEntities();
		if (touchingEntities.len() == 0)
		{
			return false;
		}

		foreach (ent in touchingEntities)
		{
			local insanityController = ctx.InsanityController.TryGetOrCreate(ent);
			if (insanityController)
			{
				insanityController.SuppressInsanityDecay(0.5);
				insanityController.IncreaseInsanity(ctx.ConfigItems.GetValue("InsanitySpaceInsanityIncreaseRate") * deltaTime);
			}
		}

		return true;
	}
}