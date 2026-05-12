local ctx = this;

_workingCoroutines <- [];

class Coroutine
{
	_started = false;
	_paused = false;
	_dead = false;

	_action = null;

	_exception = null;

	_onDead = null;

	_autoKilledOnNewRound = false;

	_waitTime = null;
	_waitCoroutine = null;

	_startTimestamp = null;
	_deltaTimeBase = 0.0;

	static _NoException = ctx.EmptyObject();

	constructor(action)
	{
		_action = action;
		_exception = _NoException;
	}

	static Delay = function(action, delay)
	{
		return ctx.Coroutine(function()
		{
			yield delay;
			action();
		}());
	};

	static DoThenWait = function(action)
	{
		return ctx.Coroutine(function()
	    {
			yield action();
		}());
	};

	static Loop = function(action)
	{
		return ctx.Coroutine(function()
		{
			while (true)
			{
				yield action();
			}
		}());
	};

	function IsDead() { return _dead; }

	function GetOnDead() { return _onDead; }

	function SetOnDead(onDead)
	{
		_onDead = onDead;
		if (_dead)
		{
			_CallOnDead();
		}
	}

	function HasException() { return _exception != _NoException; }

	function GetException() { return HasException() ? _exception : null; }

	function IsAutoKilledOnNewRound() { return _autoKilledOnNewRound; }

	function SetAutoKilledOnNewRound(val) { _autoKilledOnNewRound = val; }

	function GetWaitTime() { return _waitTime; }

	function GetWaitCoroutine() { return _waitCoroutine; }

	function GetDeltaTime()
	{
		local deltaTime = _deltaTimeBase;
		if (!_paused && _startTimestamp != null)
		{
			deltaTime += Time() - _startTimestamp;
		}
		return deltaTime;
	}

	function IsPaused() { return _paused; }

	function SetPaused(paused)
	{
		if (paused != _paused)
		{
			_paused = paused;
			if (paused)
			{
				if (_startTimestamp != null)
				{
					_deltaTimeBase += Time() - _startTimestamp;
				}
			}
			else
			{
				_startTimestamp = Time();
			}
		}
	}

	function Start()
	{
		if (_dead || _started)
		{
			return;
		}

		_started = true;

		ctx._workingCoroutines.append(this);

		_Update();
	}

	function Kill()
	{
		if (_dead)
		{
			return;
		}

		_dead = true;
		_CallOnDead();
	}

	function _Update()
	{
		if (_paused)
		{
			return;
		}

		local needExecute = false;
		if (_waitTime != null)
		{
			if (GetDeltaTime() >= _waitTime)
			{
				needExecute = true;
				_waitTime = null;
			}
		}
		else if (_waitCoroutine)
		{
			if (_waitCoroutine.IsDead())
			{
				needExecute = true;
				_waitCoroutine = null;
			}
		}
		else
		{
			needExecute = true;
		}

		if (!needExecute)
		{
			return;
		}

		while (true)
		{
			local result = null;
			local executed = false;
			try
			{
				if (_action.getstatus() != "dead")
				{
					result = (@() resume _action).call(this);
					executed = true;
				}
			}
			catch (ex)
			{
				_exception = ex;
				error(format("Exception occured during executing the action of a Coroutine: %s\n", ex.tostring()));
			}

			if (executed)
			{
				_deltaTimeBase = 0.0;
				_startTimestamp = Time();
			}
			if (HasException())
			{
				Kill();
			}
			if (_dead)
			{
				return;
			}

			if (!result)
			{
				Kill();
				return;
			}
			if (result == true)
			{
				return;
			}
			if (ctx.IsNumber(result))
			{
				_waitTime = result.tofloat();
			}
			else if (result instanceof ctx.Coroutine)
			{
				if (result.IsDead())
				{
					continue;
				}
				_waitCoroutine = result;
			}

			break;
		}
	}

	function _CallOnDead()
	{
		if (_onDead)
		{
			try
			{
				_onDead.call(null);
			}
			catch (ex)
			{
				error(format("Exception ocurred during calling the OnDead of a Coroutine: %s\n", ex.tostring()));
			}
		}
	}
}

class AliveCoroutineRef
{
	_coroutineRef = null;

	constructor(coroutine = null)
	{
		Set(coroutine);
	}

	function IsNull()
	{
		return Get() == null;
	}

	function Kill()
	{
		local coroutine = Get();
		if (coroutine)
		{
			coroutine.Kill();
			Set(null);
		}
	}

	function Get()
	{
		local coroutine = _coroutineRef;
		if (coroutine)
		{
			if (coroutine.IsDead())
			{
				_coroutineRef = null;
				return null;
			}
			else
			{
				return coroutine;
			}
		}
		else
		{
			return null;
		}
	}

	function Set(coroutine)
	{
		if (coroutine)
		{
			_coroutineRef = coroutine.weakref();
		}
		else
		{
			_coroutineRef = null;
		}
	}
}

function _UpdateCoroutines()
{
	local coroutines = _workingCoroutines;
	local waitCoroutineTable = {}; // type: table<Coroutine, array<Coroutine>>
	for (local i = 0; i < coroutines.len();)
	{
		local c = coroutines[i];
		c._Update();

		local waitCoroutine = c.GetWaitCoroutine();
		if (waitCoroutine)
		{
			local waitingCoroutines = null;
			if (waitCoroutine in waitCoroutineTable)
			{
				waitingCoroutines = waitCoroutineTable[waitCoroutine];
			}
			else
			{
				waitingCoroutines = [];
				waitCoroutineTable[waitCoroutine] <- waitingCoroutines;
			}
			waitingCoroutines.append(c);
		}

		if (c.IsDead())
		{
			coroutines.remove(i);
			if (c in waitCoroutineTable)
			{
				local waitingCoroutines = waitCoroutineTable[c];
				foreach (waitingCoroutine in waitingCoroutines)
				{
					waitingCoroutine._Update();
				}
			    delete waitCoroutineTable[c];
			}
		}
		else
		{
			i++;
		}
	}
}

_coroutineUpdateInterval <- 0.1;
_coroutineUpdateEnt <- InvalidValue;

function _CreateCoroutineUpdateEntity()
{
	if (!_coroutineUpdateEnt.IsValid())
	{
		local ent = SpawnEntityFromTable("info_target", {});
		ent.ValidateScriptScope();
		ent.GetScriptScope().Think <- function()
		{
			ctx._UpdateCoroutines();
			return ctx._coroutineUpdateInterval;
		}
		AddThinkToEnt(ent, "Think");
		_coroutineUpdateEnt = ent;
	}
}

EventCallbackRegistry.Get("OnGameEvent_round_start").Register(@(args) ctx._CreateCoroutineUpdateEntity());

EventCallbackRegistry.Get("OnGameEvent_round_start_pre_entity").Register(function(args)
{
	local coroutines = _workingCoroutines;
	local count = coroutines.len();
	for (local i = 0; i < count; i++)
	{
		local coroutine = coroutines[i];
		if (coroutine.IsAutoKilledOnNewRound())
		{
			coroutine.Kill();
		}
	}
}.bindenv(ctx));