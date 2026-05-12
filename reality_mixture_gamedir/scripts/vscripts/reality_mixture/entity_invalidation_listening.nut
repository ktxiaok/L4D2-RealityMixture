local ctx = this;

_entityInvalidationListeners <- {}; // type: table<entity, array<function>>
_entityInvalidationCheckInterval <- 1;

function AddEntityInvalidationListener(ent, listener)
{
	if (!ent.IsValid())
	{
		listener();
		return;
	}

	local listeners;
	if (ent in _entityInvalidationListeners)
	{
		listeners = _entityInvalidationListeners[ent];
	}
	else
	{
		listeners = [];
		_entityInvalidationListeners[ent] <- listeners;
	}
	listeners.append(listener);
}

function RemoveEntityInvalidationListener(ent, listener)
{
	if (ent in _entityInvalidationListeners)
	{
		local listeners = _entityInvalidationListeners[ent];
		ArrayRemove(listeners, listener);
		if (listeners.len() == 0)
		{
			delete _entityInvalidationListeners[ent];
		}
	}
}

function CheckEntityInvalidation()
{
	local invalidEnts = [];
	local targetListeners = [];
	foreach (ent, listeners in _entityInvalidationListeners)
	{
		if (!ent.IsValid())
		{
			targetListeners.extend(listeners);
			invalidEnts.append(ent);
		}
	}
	foreach (listener in targetListeners)
	{
		try
		{
			listener.call(null);
		}
		catch (ex)
		{
			error(format("Exception occurred during calling an entity invalidation listener: %s\n", ex.tostring()));
		}
	}
	foreach (ent in invalidEnts)
	{
		delete _entityInvalidationListeners[ent];
	}
}

_entityInvalidationCheckCoroutine <- Coroutine.Loop(@() (ctx.CheckEntityInvalidation(), ctx._entityInvalidationCheckInterval));
_entityInvalidationCheckCoroutine.Start();