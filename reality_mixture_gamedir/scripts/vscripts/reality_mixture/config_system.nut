local ctx = this;

class ConfigFilter
{
	static FallbackValue = ctx.EmptyObject();

	constructor()
	{

	}

	function Filter(value, configItem)
	{
		local expectedType = configItem.GetItemType();
		local currentType = typeof value;

		if (currentType == expectedType)
		{
			return value;
		}
		else if (expectedType == "bool")
		{
			return value ? true : false;
		}
		else if (expectedType == "integer" && currentType == "float")
		{
			return value.tointeger();
		}
		else if (expectedType == "float" && currentType == "integer")
		{
			return value.tofloat();
		}
		else if (expectedType == "string")
		{
			return value.tostring();
		}
		else
		{
			return FallbackValue;
		}
	}
}

DefaultConfigFilter <- ConfigFilter();

class RangeConfigFilter extends ConfigFilter
{
	_min = null;
	_max = null;

	constructor(min, max)
	{
		base.constructor();

		_min = min;
		_max = max;
	}

	function GetMin() { return _min; }

	function GetMax() { return _max; }

	function Filter(value, configItem)
	{
		value = base.Filter(value, configItem);
		if (_min != null && value < _min)
		{
			value = _min;
		}
		else if (_max != null && value > _max)
		{
			value = _max;
		}
		return base.Filter(value, configItem);
	}
}

RangeConfigFilters <- {
	NonNegative = RangeConfigFilter(0, null)
}

_configItems <- {}; // type: table<string, ConfigItem>

ConfigItems <- {
	function Get(name)
	{
		return ctx._configItems[name];
	}

	function GetValue(name)
	{
		return Get(name).Get();
	}

	function GetAll()
	{
		foreach (name, configItem in ctx._configItems)
		{
			yield configItem;
		}
	}

	function UnsetAll()
	{
		foreach (configItem in GetAll())
		{
			configItem.Unset();
		}
	}
};

class ConfigItem
{
	_name = null;
	_itemType = null;
	_isSet = false;
	_value = null;
	_defaultValue = null;
	_filter = ctx.DefaultConfigFilter;

	constructor(name, itemType, defaultValue, filter = null)
	{
		_name = name;
		_itemType = itemType;
		if (filter != null)
		{
			_filter = filter;
		}
		_defaultValue = FilterValue(defaultValue);
		if (_defaultValue == ctx.ConfigFilter.FallbackValue)
		{
			throw format("Invalid default value for ConfigItem %s: %s", _name, defaultValue.tostring());
		}

		if (_name in ctx._configItems)
		{
			printl(format("Overwriting ConfigItem %s.", _name));
		}
		ctx._configItems[_name] <- this;
	}

	function GetName() { return _name; }

	function GetItemType() { return _itemType; }

	function IsSet() { return _isSet; }

	function GetDefault() { return _defaultValue; }

	function GetFilter() { return _filter; }

	function Get()
	{
		return _isSet ? _value : _defaultValue;
	}

	function Set(value)
	{
		value = FilterValue(value);
		if (value == ConfigFilter.FallbackValue)
		{
			Unset();
			return;
		}
		_value = value;
		_isSet = true;
	}

	function Unset()
	{
		_value = null;
		_isSet = false;
	}

	function FilterValue(value)
	{
		try
		{
			return _filter.Filter.call(_filter, value, this);
		}
		catch (ex)
		{
			error(format("Exception occurred during calling the filter of a ConfigItem %s: %s\n", _name, ex.tostring()));
			return ctx.ConfigFilter.FallbackValue;
		}
	}
}