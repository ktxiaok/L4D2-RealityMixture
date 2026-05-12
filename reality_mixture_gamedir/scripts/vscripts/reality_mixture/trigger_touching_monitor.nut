local ctx = this;

class TriggerTouchingMonitor
{
	_valid = true;

	_trigger = null;

	_touchingEntities = null;

	_filter = null;

	_startTouchCallbacks = null;
	_startTouchFuncName = null;

	_endTouchCallbacks = null;
	_endTouchFuncName = null;

	constructor(trigger, args = null)
	{
		local self = this;

		_trigger = trigger;
		_touchingEntities = [];
		_startTouchCallbacks = [];
		_endTouchCallbacks = [];
		if (args)
		{
			if ("Filter" in args)
			{
				_filter = args.Filter;
			}
			if ("StartTouchCallback" in args)
			{
				AddStartTouchCallback(args.StartTouchCallback);
			}
			if ("EndTouchCallback" in args)
			{
				AddEndTouchCallback(args.EndTouchCallback);
			}
		}

		_trigger.ValidateScriptScope();
		local triggerScope = _trigger.GetScriptScope();
		_startTouchFuncName = ctx.GetUniqueSlotName(triggerScope, "TouchingMonitor_StartTouch");
		_endTouchFuncName = ctx.GetUniqueSlotName(triggerScope, "TouchingMonitor_EndTouch");
		triggerScope[_startTouchFuncName] <- @() self._OnStartTouch(activator);
		triggerScope[_endTouchFuncName] <- @() self._OnEndTouch(activator);
		_trigger.ConnectOutput("OnStartTouch", _startTouchFuncName);
		_trigger.ConnectOutput("OnEndTouch", _endTouchFuncName);

		for (local ent = Entities.First(); ent; ent = Entities.Next(ent))
		{
			if (_trigger.IsTouching(ent))
			{
				_OnStartTouch(ent);
			}
		}
	}

	function GetTrigger() { return _trigger; }

	function GetFilter() { return _filter; }

	function IsValid()
	{
		if (!_valid)
		{
			return false;
		}

		if (!_trigger.IsValid())
		{
			Kill();
		}
		return _valid;
	}

	function HasTouchingEntity()
	{
		CheckTouchingEntities();
		return _touchingEntities.len() > 0;
	}

	function GetTouchingEntities()
	{
		CheckTouchingEntities();
		return clone _touchingEntities;
	}

	function CheckTouchingEntities()
	{
		local touchingEntities = clone _touchingEntities;
		local endTouchEntities = [];
		foreach (ent in touchingEntities)
		{
			if (!ent.IsValid() || !_Filter(ent) || !_trigger.IsTouching(ent))
			{
				endTouchEntities.append(ent);
			}
		}
		foreach (ent in endTouchEntities)
		{
			_OnEndTouch(ent);
		}
	}

	function AddStartTouchCallback(callback)
	{
		ctx.ArrayAddNonduplicate(_startTouchCallbacks, callback);
		foreach (activator in GetTouchingEntities())
		{
			_RunStartTouchCallback(callback, activator);
		}
	}

	function RemoveStartTouchCallback(callback)
	{
		ctx.ArrayRemove(_startTouchCallbacks, callback);
	}

	function AddEndTouchCallback(callback)
	{
		ctx.ArrayAddNonduplicate(_endTouchCallbacks, callback);
	}

	function RemoveEndTouchCallback(callback)
	{
		ctx.ArrayRemove(_endTouchCallbacks, callback);
	}

	function Kill()
	{
		if (!_valid)
		{
			return;
		}

		_valid = false;
		_touchingEntities.clear();
		if (_trigger.IsValid())
		{
			local triggerScope = _trigger.GetScriptScope();
			if (triggerScope)
			{
				if (_startTouchFuncName in triggerScope)
				{
					_trigger.DisconnectOutput("OnStartTouch", _startTouchFuncName);
					delete triggerScope[_startTouchFuncName];
				}
				if (_endTouchFuncName in triggerScope)
				{
					_trigger.DisconnectOutput("OnEndTouch", _endTouchFuncName);
					delete triggerScope[_endTouchFuncName];
				}
			}
		}
	}

	function _OnStartTouch(activator)
	{
		if (!IsValid())
		{
			return;
		}
		if (activator && activator.IsValid() && _Filter(activator) && _touchingEntities.find(activator) == null)
		{
			_touchingEntities.append(activator);
			_RunStartTouchCallbacks(activator);
		}
	}

	function _OnEndTouch(activator)
	{
		if (!IsValid())
		{
			return;
		}
		if (activator && ctx.ArrayRemove(_touchingEntities, activator))
		{
			_RunEndTouchCallbacks(activator);
		}
	}

	function _Filter(ent)
	{
		if (!_filter)
		{
			return true;
		}

		try
		{
			return _filter.call(null, ent);
		}
		catch (ex)
		{
			error(format("Exception occurred during calling TriggerTouchingMonitor.Filter: %s\n", ex.tostring()));
		}

		return false;
	}

	function _RunStartTouchCallbacks(activator)
	{
		local callbacks = clone _startTouchCallbacks;
		foreach (callback in callbacks)
		{
			_RunStartTouchCallback(callback, activator);
		}
	}

	function _RunEndTouchCallbacks(activator)
	{
		local callbacks = clone _endTouchCallbacks;
		foreach (callback in callbacks)
		{
			_RunEndTouchCallback(callback, activator);
		}
	}

	function _RunStartTouchCallback(callback, activator)
	{
		try
		{
			callback.call(null, { Monitor = this, Activator = activator });
		}
		catch (ex)
		{
			error(format("Exception occurred during calling a StartTouchCallback of a TriggerTouchingMonitor: %s\n", ex.tostring()));
		}
	}

	function _RunEndTouchCallback(callback, activator)
	{
		try
		{
			callback.call(null, { Monitor = this, Activator = activator });
		}
		catch (ex)
		{
			error(format("Exception occurred during calling an EndTouchCallback of a TriggerTouchingMonitor: %s\n", ex.tostring()));
		}
	}
}