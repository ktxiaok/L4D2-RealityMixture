local ctx = this;

class TriggerHintMessageDisplayer
{
	_valid = true;

	_trigger = null;

	_localizedMessage = null;

	_displayOnChatCoroutineRefTable = null; // type: table<userid(int), AliveCoroutineRef>

	constructor(trigger, args)
	{
		local self = this;

		_trigger = trigger;

		_trigger.ValidateScriptScope();
		local triggerScope = _trigger.GetScriptScope();
		if ("TriggerHintMessageDisplayer" in triggerScope)
		{
			throw "A TriggerHintMessageDisplayer has been already created in this trigger.";
		}
		triggerScope.TriggerHintMessageDisplayer <- this;

		_localizedMessage = ctx.LocalizedString(args.Message, ctx.LocalResourceManagerDefault);
		_displayOnChatCoroutineRefTable = {};

		triggerScope.OnStartTouch_DisplayHintMessage <- function()
		{
			if (activator && activator.IsPlayer())
			{
				self.DisplayOnChat(activator);
			}
		};
		_trigger.ConnectOutput("OnStartTouch", "OnStartTouch_DisplayHintMessage");

		triggerScope.OnTrigger_DisplayHintMessage <- function()
		{
			if (activator && activator.IsPlayer())
			{
				self.DisplayOnCenter(activator);
			}
		};
		_trigger.ConnectOutput("OnTrigger", "OnTrigger_DisplayHintMessage");

		ctx.AddEntityInvalidationListener(_trigger, @() self.IsValid());
	}

	function IsValid()
	{
		if (!_valid)
		{
			return false;
		}

		if (!_trigger.IsValid())
		{
			_valid = false;
			OnKilled();
		}

		return _valid;
	}

	function GetTrigger() { return _trigger; }

	function DisplayOnChat(player = null)
	{
		if (player)
		{
			_TryCreateDisplayOnChatCoroutine(player);
		}
		else
		{
			foreach (player in ctx.GetSurvivors())
			{
				_TryCreateDisplayOnChatCoroutine(player);
			}
		}
	}

	function ForceDisplayOnChat(player = null)
	{
		local function DisplayToPlayer(player)
	    {
			ClientPrint(player, DirectorScript.HUD_PRINTTALK, ctx.PrintColorOrange + _localizedMessage.GetByPlayer(player));
		}

		if (player)
		{
			DisplayToPlayer(player);
		}
		else
		{
			foreach (player in ctx.GetSurvivors())
			{
				DisplayToPlayer(player);
			}
		}
	}

	function DisplayOnCenter(player = null)
	{
		local function DisplayToPlayer(player)
		{
			ClientPrint(player, DirectorScript.HUD_PRINTCENTER, _localizedMessage.GetByPlayer(player));
		}

		if (player)
		{
			DisplayToPlayer(player);
		}
		else
		{
			foreach (player in ctx.GetSurvivors())
			{
				DisplayToPlayer(player);
			}
		}
	}

	function OnKilled()
	{
		foreach (userid, coroutineRef in _displayOnChatCoroutineRefTable)
		{
			coroutineRef.Kill();
		}
	}

	function _TryCreateDisplayOnChatCoroutine(player)
	{
		local self = this;
		local userid = player.GetPlayerUserId();

		local coroutineRef = null;
		if (userid in _displayOnChatCoroutineRefTable)
		{
			coroutineRef = _displayOnChatCoroutineRefTable[userid];
		}
		else
		{
			coroutineRef = ctx.AliveCoroutineRef();
			_displayOnChatCoroutineRefTable[userid] <- coroutineRef;
		}

		local coroutine = coroutineRef.Get();
		if (!coroutine)
		{
			coroutine = ctx.Coroutine.DoThenWait(function()
			{
				local player = GetPlayerFromUserID(userid);
				if (player)
				{
					self.ForceDisplayOnChat(player);
					return 5;
				}
			});
			coroutine.SetAutoKilledOnNewRound(true);
			coroutine.Start();
			coroutineRef.Set(coroutine);
		}
	}
}