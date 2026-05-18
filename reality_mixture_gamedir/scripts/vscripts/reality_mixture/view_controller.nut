local ctx = this;

local viewcontrolNameRegexp = regexp("^viewcontrol_(.+)$");

_views <- {}; // type: table<string, viewcontrol>
ViewsLoaded <- Event();

function LoadViews()
{
	_views.clear();
	for (local ent = Entities.First(); ent; ent = Entities.Next(ent))
	{
		local entName = ent.GetName();
		local captures = viewcontrolNameRegexp.capture(entName);
		if (captures)
		{
			local capture = captures[1];
			local name = entName.slice(capture.begin, capture.end);
			_views[name] <- ent;
		}
	}
	ViewsLoaded.Invoke();
}

function GetViewNames()
{
	foreach (name, viewcontrol in _views)
	{
		yield name;
	}
}

function TryGetViewcontrol(name)
{
	if (name in _views)
	{
		local ent = _views[name];
		if (ent.IsValid())
		{
			return ent;
		}
		else
		{
			delete _views[name];
		}
	}
	return null;
}

EventCallbackRegistry.Get("OnGameEvent_round_start").Register(@(args) ctx.LoadViews());

local ScopeSlotName_ViewController = UniqueString("viewController");

class ViewController
{
	_valid = true;

	_targetEnt = null;

	_coroutineRef = null;

	constructor(targetEnt)
	{
		_targetEnt = targetEnt;
		_coroutineRef = ctx.AliveCoroutineRef();

		_targetEnt.ValidateScriptScope();
		local targetEntScope = _targetEnt.GetScriptScope();
		if (ScopeSlotName_ViewController in targetEntScope)
		{
			targetEntScope[ScopeSlotName_ViewController].Kill();
		}
		targetEntScope[ScopeSlotName_ViewController] <- this;

		local self = this;
		ctx.AddEntityInvalidationListener(_targetEnt, @() self.Kill());
	}

	static TryCreate = function(targetEnt)
	{
		if (!IsApplicableTargetEntity(targetEnt))
		{
			return null;
		}
		return ctx.ViewController(targetEnt);
	}

	static TryGet = function(targetEnt)
	{
		local targetEntScope = targetEnt.GetScriptScope();
		if (targetEntScope && ScopeSlotName_ViewController in targetEntScope)
		{
			return targetEntScope[ScopeSlotName_ViewController];
		}

		return null;
	};

	static TryGetOrCreate = function(targetEnt)
	{
		if (!IsApplicableTargetEntity(targetEnt))
		{
			return null;
		}

		local viewController = TryGet(targetEnt);
		if (viewController)
		{
			return viewController;
		}
		
		return ctx.ViewController(targetEnt);
	}

	static IsApplicableTargetEntity = function(ent)
	{
		return ent.IsPlayer() && ent.IsSurvivor() && !ent.IsDead();
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

	function IsActive()
	{
		if (_coroutineRef.Get())
		{
			return true;
		}
		return false;
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
			if (targetEntScope && ScopeSlotName_ViewController in targetEntScope)
			{
				delete targetEntScope[ScopeSlotName_ViewController];
			}
		}
	}

	function Activate(viewName, duration)
	{
		if (_targetEnt.IsDying())
		{
			return;
		}

		local viewcontrol = ctx.TryGetViewcontrol(viewName);
		if (!viewcontrol)
		{
			return;
		}

		_coroutineRef.Kill();
		local targetEnt = _targetEnt;
		local function IsInvalid()
		{
			return !targetEnt.IsValid() || !viewcontrol.IsValid();
		}
		local coroutine = ctx.Coroutine.DoThenWait(function()
		{
			DoEntFire("!caller", "Enable", "", 0, targetEnt, viewcontrol);
			return duration;
		});
		coroutine.SetOnDead(function()
		{
			if (IsInvalid())
			{
				return;
			}
			DoEntFire("!caller", "Disable", "", 0, targetEnt, viewcontrol);
		});
		coroutine.Start();
		_coroutineRef.Set(coroutine);
	}

	function Deactivate()
	{
		_coroutineRef.Kill();
	}
}

EventCallbackRegistry.Get("OnGameEvent_player_spawn").Register(function(args)
{
	local player = GetPlayerFromUserID(args.userid);
	ViewController.TryCreate(player);
}.bindenv(ctx));

EventCallbackRegistry.Get("OnGameEvent_player_death").Register(function(args)
{
	if ("userid" in args)
	{
		local player = GetPlayerFromUserID(args.userid);
		local viewController = ViewController.TryGet(player);
		if (viewController && viewController.IsActive())
		{
			viewController.Deactivate();

			local viewcontrol = SpawnEntityFromTable("point_viewcontrol_multiplayer", {
				origin = player.GetOrigin(),
				angles = player.GetAngles()
			});
			EntFireByHandle(viewcontrol, "AddPlayer", "", 0, player);
			EntFireByHandle(viewcontrol, "Enable");
			EntFireByHandle(viewcontrol, "Disable", "", 0.5);
			EntFireByHandle(viewcontrol, "Kill", "", 1);
		}
	}
}.bindenv(ctx));