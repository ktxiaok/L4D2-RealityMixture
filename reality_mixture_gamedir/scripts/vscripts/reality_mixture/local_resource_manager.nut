local ctx = this;

class LocalResourceManager
{
	static s_templateStringRegexp = regexp(@"(\{\{)|(\}\})|(\{[^\{\}]+\})");

	_resRootPath = null;
	_neutralCulture = null;

	_resTable = null; // type: table<Culture(string), table<ResourceKey, Resource>>

	constructor(args)
	{
		_resRootPath = args.ResourceRootPath;
		_neutralCulture = args.NeutralCulture;
		_resTable = { [_neutralCulture] = {} };
	}

	static GetPlayerCulture = function(player)
	{
		return Convars.GetClientConvarValue("cl_language", player.GetEntityIndex());
	};

	function GetResourceRootPath() { return _resRootPath; }

	function GetNeutralCulture() { return _neutralCulture; }

	function TryGetResource(key, culture = null)
	{
		if (culture == null)
		{
			culture = _neutralCulture;
		}

		if (culture in _resTable)
		{
			local resources = _resTable[culture];
			if (key in resources)
			{
				return resources[key];
			}
		}

		if (culture != _neutralCulture)
		{
			local resources = _resTable[_neutralCulture];
			if (key in resources)
			{
				return resources[key];
			}
		}

		return null;
	}

	function GetResource(key, culture = null)
	{
		local res = TryGetResource(key, culture);
		if (res == null)
		{
			throw format("Failed to get the local resource with key %s.", key.tostring());
		}
		return res;
	}

	function GetResourceByPlayer(key, player)
	{
		return GetResource(key, GetPlayerCulture(player));
	}

	function LoadResources(fileName, targetCulture = null)
	{
		if (targetCulture == null)
		{
			targetCulture = fileName;
		}

		local resources = null;
		if (targetCulture in _resTable)
		{
			resources = _resTable[targetCulture];
		}
		else
		{
			resources = {};
			_resTable[targetCulture] <- resources;
		}

		IncludeScript(_resRootPath + fileName, resources);
	}

	function BuildString(template, culture = null)
	{
		template = template.tostring();
		local len = template.len();
		local cursor = 0;
		local result = "";
		while (true)
		{
			if (cursor >= len)
			{
				break;
			}

			local groups = s_templateStringRegexp.capture(template, cursor);
			if (groups == null)
			{
				result += template.slice(cursor, len);
				break;
			}
			result += template.slice(cursor, groups[0].begin);
			if (groups[1].begin != groups[1].end)
			{
				result += "{";
			}
			else if (groups[2].begin != groups[2].end)
			{
				result += "}";
			}
			else
			{
				local key = template.slice(groups[3].begin + 1, groups[3].end - 1);
				local res = TryGetResource(key, culture);
				local content = res == null ? format("[%s]", key) : res.tostring();
				result += content;
			}
			cursor = groups[0].end;
		}
		return result;
	}

	function BuildStringByPlayer(template, player)
	{
		return BuildString(template, GetPlayerCulture(player));
	}
}

class LocalizedString
{
	_template = null;
	_resourceManager = null;
	_stringTable = null;

	constructor(template, localResourceManager)
	{
		_template = template;
		_resourceManager = localResourceManager;
		_stringTable = {};
	}

	function Get(culture)
	{
		if (culture in _stringTable)
		{
			return _stringTable[culture];
		}

		local str = _resourceManager.BuildString(_template, culture);
		_stringTable[culture] <- str;
		return str;
	}

	function GetByPlayer(player)
	{
		return Get(ctx.LocalResourceManager.GetPlayerCulture(player));
	}
}

LocalResourceManagerDefault <- LocalResourceManager({
	NeutralCulture = "english",
	ResourceRootPath = "reality_mixture/localization/"
});
LocalResourceManagerDefault.LoadResources("english");
LocalResourceManagerDefault.LoadResources("schinese");