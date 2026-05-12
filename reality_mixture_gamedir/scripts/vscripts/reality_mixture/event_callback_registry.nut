local ctx = this;

_eventCallbackRegistries <- {}; // type: table<string, EventCallbackRegistry>

class EventCallbackRegistry
{
	_name = null;

	_callbacks = null;

	_callbackScope = null;

	constructor(name)
	{
		_name = name;
		_callbacks = [];
		_callbackScope = {};

		local self = this;
		_callbackScope[_name] <- @(args) self.Run(args);
	}

	static Get = function(name)
	{
		local registries = ctx._eventCallbackRegistries;
		if (name in registries)
		{
			return registries[name];
		}
		else
		{
			local registry = ctx.EventCallbackRegistry(name);
			registries[name] <- registry;
			registry.Collect();
			return registry;
		}
	};

	static GetAll = function()
	{
		foreach (name, registry in ctx._eventCallbackRegistries)
		{
			yield registry;
		}
	};

	static CollectAll = function()
	{
		foreach (registry in GetAll())
		{
			registry.Collect();
		}
	};

	function GetName() { return _name; }

	function Register(callback)
	{
		if (_callbacks.find(callback) != null)
		{
			return;
		}
		_callbacks.append(callback);
	}

	function Unregister(callback)
	{
		ctx.ArrayRemove(_callbacks, callback);
	}

	function Run(args)
	{
		local callbacks = clone _callbacks;
		foreach (callback in callbacks)
		{
			try
			{
				callback.call(null, args);
			}
			catch (ex)
			{
				error(format("Exception occurred during running a callback in an EventCallbackRegistry %s: %s\n", _name, ex.tostring()));
			}
		}
	}

	function Collect()
	{
		__CollectEventCallbacks(_callbackScope, "OnGameEvent_", "GameEventCallbacks", ::RegisterScriptGameEventListener);
	}
}