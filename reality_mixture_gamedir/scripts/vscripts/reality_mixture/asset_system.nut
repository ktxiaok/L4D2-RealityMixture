local ctx = this;

MaterialNames <- {}.setdelegate(ctx);
ModelNames <- {}.setdelegate(ctx);
SoundNames <- {}.setdelegate(ctx);
ViewNames <- {}.setdelegate(ctx);

_assetRandomPickTable <- {}; // type: table<array, ShufflePicker>

function RandomPickAsset(assetArray)
{
	local picker = null;
	if (assetArray in _assetRandomPickTable)
	{
		picker = _assetRandomPickTable[assetArray];
	}
	else
	{
		picker = ShufflePicker(assetArray);
		_assetRandomPickTable[assetArray] <- picker;
	}
	return picker.Pick();
}

EventCallbackRegistry.Get("OnGameEvent_round_start_pre_entity").Register(function(args)
{
	_assetRandomPickTable.clear();
}.bindenv(ctx));

function GetAssetName(assetType, key)
{
	local assetTable = this[assetType + "Names"];
	local entry = assetTable[key];
	local entryType = type(entry);
	if (entryType == "array")
	{
		return RandomPickAsset(entry);
	}
	else
	{
		return entry;
	}
}

function GetMaterialName(key)
{
	return GetAssetName("Material", key);
}

function GetModelName(key)
{
	return GetAssetName("Model", key);
}

function GetSoundName(key)
{
	return GetAssetName("Sound", key);
}

_precacheModels <- Set();
_precacheSounds <- Set();

function EnsureModelPrecached(name)
{
	if (type(name) != "string")
	{
		throw "The argument must be a string.";
	}
	_precacheModels.Add(name);
}

function EnsureModelsPrecached(names)
{
	foreach (name in names)
	{
		EnsureModelPrecached(name);
	}
}

function EnsureSoundPrecached(name)
{
	if (type(name) != "string")
	{
		throw "The argument must be a string.";
	}
	_precacheSounds.Add(name);
}

function EnsureSoundsPrecached(names)
{
	foreach (name in names)
	{
		EnsureSoundPrecached(name);
	}
}

function PrecacheAssets()
{
	foreach (model in _precacheModels.Enumerate())
	{
		PrecacheModel(model);
	}
	foreach (sound in _precacheSounds.Enumerate())
	{
		PrecacheSound(sound);
	}

	local function PrecacheAssetTable(assetTable, precacheFunc)
	{
		foreach (key, entry in assetTable)
		{
			local entryType = type(entry);
			if (entryType == "array")
			{
				foreach (asset in entry)
				{
					precacheFunc(asset);
				}
			}
			else
			{
				precacheFunc(entry);
			}
		}
	}

	PrecacheAssetTable(MaterialNames, PrecacheModel);
	PrecacheAssetTable(ModelNames, PrecacheModel);
	PrecacheAssetTable(SoundNames, PrecacheSound);
}

NullModelName <- "models/props_doors/null.mdl";
EnsureModelPrecached(NullModelName);