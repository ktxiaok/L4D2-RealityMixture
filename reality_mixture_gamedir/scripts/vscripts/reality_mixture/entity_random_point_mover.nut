local ctx = this;

class EntityRandomPointMover
{
	_valid = true;

	_targetEnt = null;

	_pointPicker = null;

	_minInterval = null;
	_maxInterval = null;

	_activeTriggerMonitor = null;

	_moveCoroutineRef = null;

	/**
	 * args table:
	 * {
	 * 		Points: Enumerable<Vector|CBaseEntity>
	 * 		MinInterval: number
	 * 		MaxInterval: number
	 * 		(optional) ActiveTrigger: trigger
	 * }
	 */
	constructor(targetEnt, args)
	{
		local self = this;

		_targetEnt = targetEnt;
		_pointPicker = ctx.ShufflePicker(args.Points);
		_minInterval = args.MinInterval.tofloat();
		_maxInterval = args.MaxInterval.tofloat();
		_maxInterval = ctx.Max(_minInterval, _maxInterval);
		_moveCoroutineRef = ctx.AliveCoroutineRef();
		if ("ActiveTrigger" in args)
		{
			local monitorArgs = {
				StartTouchCallback = @(args) self._OnActiveTriggerStartTouch(args)
			};
			if ("ActiveTriggerFilter" in args)
			{
				monitorArgs.Filter <- args.ActiveTriggerFilter;
			}
			_activeTriggerMonitor = ctx.TriggerTouchingMonitor(args.ActiveTrigger, monitorArgs);
		}

		_TryCreateMoveCoroutine();

		ctx.AddEntityInvalidationListener(_targetEnt, @() self.IsValid());
	}

	function IsValid()
	{
		if (!_valid)
		{
			return false;
		}

		if (!_targetEnt.IsValid())
		{
			Kill();
		}

		return _valid;
	}

	function GetTargetEntity() { return _targetEnt; }

	function GetPoints() { return _pointPicker.GetItems(); }

	function GetMinInterval() { return _minInterval; }

	function GetMaxInterval() { return _maxInterval; }

	function Kill()
	{
		if (!_valid)
		{
			return;
		}

		_valid = false;
		_moveCoroutineRef.Kill();
		if (_activeTriggerMonitor)
		{
			_activeTriggerMonitor.Kill();
		}
	}

	function _TryCreateMoveCoroutine()
	{
		local coroutine = _moveCoroutineRef.Get();
		if (!coroutine)
		{
			local self = this;
			coroutine = ctx.Coroutine.Loop(@() self._Move());
			coroutine.Start();
			_moveCoroutineRef.Set(coroutine);
		}
	}

	function _Move()
	{
		if (!IsValid())
		{
			return null;
		}

		local point = _pointPicker.Pick();
		local pos = ctx.IsEntity(point) ? point.GetOrigin() : point;
		ctx.MoveEntityTo(_targetEnt, pos);
		if (_activeTriggerMonitor)
		{
			if (!_activeTriggerMonitor.HasTouchingEntity())
			{
				return null;
			}
		}
		local interval = RandomFloat(_minInterval, _maxInterval);
		return interval;
	}

	function _OnActiveTriggerStartTouch(args)
	{
		_TryCreateMoveCoroutine();
	}
}