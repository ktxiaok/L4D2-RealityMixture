local ctx = this;

// MoveTypes
// Warning: Most of these MoveTypes are called by the engine, safe ones to use are: 0, 2, 4, 5, 8.
MOVETYPE_NONE <- 0; // never moves
MOVETYPE_ISOMETRIC <- 1; // For players -- in TF2 commander view, etc.
MOVETYPE_WALK <- 2; // Player only - moving on the ground
MOVETYPE_STEP <- 3; // gravity, special edge handling -- monsters use this
MOVETYPE_FLY <- 4; // No gravity, but still collides with stuff
MOVETYPE_FLYGRAVITY <- 5; // flies through the air + is affected by gravity
MOVETYPE_VPHYSICS <- 6; // uses VPHYSICS for simulation
MOVETYPE_PUSH <- 7; // no clip to world, push and crush
MOVETYPE_NOCLIP <- 8; // No gravity, no collisions, still do velocity/avelocity
MOVETYPE_LADDER <- 9; // Used by players only when going onto a ladder
MOVETYPE_OBSERVER <- 10; // Observer movement, depends on player's observer mode
MOVETYPE_CUSTOM <- 11; // Allows the entity to describe its own physics

// Render Modes
kRenderNormal <- 0; // src
kRenderTransColor <- 1; // c*a+dest*(1-a)
kRenderTransTexture <- 2; // src*a+dest*(1-a)
kRenderGlow <- 3; // src*a+dest -- No Z buffer checks -- Fixed size in screen space
kRenderTransAlpha <- 4; // src*srca+dest*(1-srca)
kRenderTransAdd <- 5; // src*a+dest
kRenderEnvironmental <- 6; // not drawn, used for environmental effects
kRenderTransAddFrameBlend <- 7; // use a fractional frame value to blend between animation frames
kRenderTransAlphaAdd <- 8; // src + dest*(1-a)
kRenderWorldGlow <- 9; // Same as kRenderGlow but not fixed size in screen space
kRenderNone <- 10; // Don't render.

// contents flags are seperate bits
// a given brush can contribute multiple content bits
// multiple brushes can be in a single leaf
// lower bits are stronger, and will eat weaker brushes completely
CONTENTS_EMPTY <- 0; // No contents

CONTENTS_SOLID <- 0x1; // an eye is never valid in a solid
CONTENTS_WINDOW <- 0x2; // translucent, but not watery (glass)
CONTENTS_AUX <- 0x4;
CONTENTS_GRATE <- 0x8; // alpha-tested "grate" textures.  Bullets/sight pass through, but solids don't
CONTENTS_SLIME <- 0x10;
CONTENTS_WATER <- 0x20;
CONTENTS_BLOCKLOS <- 0x40; // block AI line of sight
CONTENTS_OPAQUE <- 0x80; // things that cannot be seen through (may be non-solid though)
LAST_VISIBLE_CONTENTS <- 0x80;

ALL_VISIBLE_CONTENTS <- (LAST_VISIBLE_CONTENTS | (LAST_VISIBLE_CONTENTS-1));

CONTENTS_TESTFOGVOLUME <- 0x100;
CONTENTS_UNUSED <- 0x200;

// unused
// NOTE: If it's visible, grab from the top + update LAST_VISIBLE_CONTENTS
// if not visible, then grab from the bottom.
CONTENTS_UNUSED6 <- 0x400;

CONTENTS_TEAM1 <- 0x800; // per team contents used to differentiate collisions
CONTENTS_TEAM2 <- 0x1000; // between players and objects on different teams

// ignore CONTENTS_OPAQUE on surfaces that have SURF_NODRAW
CONTENTS_IGNORE_NODRAW_OPAQUE <- 0x2000;

// hits entities which are MOVETYPE_PUSH (doors, plats, etc.)
CONTENTS_MOVEABLE <- 0x4000;

// remaining contents are non-visible, and don't eat brushes
CONTENTS_AREAPORTAL <- 0x8000;

CONTENTS_PLAYERCLIP <- 0x10000;
CONTENTS_MONSTERCLIP <- 0x20000;

// currents can be added to any other contents, and may be mixed
CONTENTS_CURRENT_0 <- 0x40000;
CONTENTS_CURRENT_90 <- 0x80000;
CONTENTS_CURRENT_180 <- 0x100000;
CONTENTS_CURRENT_270 <- 0x200000;
CONTENTS_CURRENT_UP <- 0x400000;
CONTENTS_CURRENT_DOWN <- 0x800000;

CONTENTS_ORIGIN <- 0x1000000; // removed before bsping an entity

CONTENTS_MONSTER <- 0x2000000; // should never be on a brush, only in game
CONTENTS_DEBRIS <- 0x4000000;
CONTENTS_DETAIL <- 0x8000000; // brushes to be added after vis leafs
CONTENTS_TRANSLUCENT <- 0x10000000;	// auto set if any surface has trans
CONTENTS_LADDER <- 0x20000000;
CONTENTS_HITBOX <- 0x40000000; // use accurate hitboxes on trace

// -----------------------------------------------------
// spatial content masks - used for spatial queries (traceline,etc.)
// -----------------------------------------------------
MASK_ALL <- (0xFFFFFFFF);
// everything that is normally solid
MASK_SOLID <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_MONSTER|CONTENTS_GRATE);
// everything that blocks player movement
MASK_PLAYERSOLID <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_PLAYERCLIP|CONTENTS_WINDOW|CONTENTS_MONSTER|CONTENTS_GRATE);
// blocks npc movement
MASK_NPCSOLID <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTERCLIP|CONTENTS_WINDOW|CONTENTS_MONSTER|CONTENTS_GRATE);
// water physics in these contents
MASK_WATER <- (CONTENTS_WATER|CONTENTS_MOVEABLE|CONTENTS_SLIME);
// everything that blocks lighting
MASK_OPAQUE <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_OPAQUE);
// everything that blocks lighting, but with monsters added.
MASK_OPAQUE_AND_NPCS <- (MASK_OPAQUE|CONTENTS_MONSTER);
// everything that blocks line of sight for AI
MASK_BLOCKLOS <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_BLOCKLOS);
// everything that blocks line of sight for AI plus NPCs
MASK_BLOCKLOS_AND_NPCS <- (MASK_BLOCKLOS|CONTENTS_MONSTER);
// everything that blocks line of sight for players
MASK_VISIBLE <- (MASK_OPAQUE|CONTENTS_IGNORE_NODRAW_OPAQUE);
// everything that blocks line of sight for players, but with monsters added.
MASK_VISIBLE_AND_NPCS <- (MASK_OPAQUE_AND_NPCS|CONTENTS_IGNORE_NODRAW_OPAQUE);
// bullets see these as solid
MASK_SHOT <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_HITBOX);
// non-raycasted weapons see this as solid (includes grates)
MASK_SHOT_HULL <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_MONSTER|CONTENTS_WINDOW|CONTENTS_DEBRIS|CONTENTS_GRATE);
// hits solids (not grates) and passes through everything else
MASK_SHOT_PORTAL <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_MONSTER);
// everything normally solid, except monsters (world+brush only)
MASK_SOLID_BRUSHONLY <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_GRATE);
// everything normally solid for player movement, except monsters (world+brush only)
MASK_PLAYERSOLID_BRUSHONLY <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_PLAYERCLIP|CONTENTS_GRATE);
// everything normally solid for npc movement, except monsters (world+brush only)
MASK_NPCSOLID_BRUSHONLY <- (CONTENTS_SOLID|CONTENTS_MOVEABLE|CONTENTS_WINDOW|CONTENTS_MONSTERCLIP|CONTENTS_GRATE);
// just the world, used for route rebuilding
MASK_NPCWORLDSTATIC <- (CONTENTS_SOLID|CONTENTS_WINDOW|CONTENTS_MONSTERCLIP|CONTENTS_GRATE);
// These are things that can split areaportals
MASK_SPLITAREAPORTAL <- (CONTENTS_WATER|CONTENTS_SLIME);

// UNDONE: This is untested, any moving water
MASK_CURRENT <- (CONTENTS_CURRENT_0|CONTENTS_CURRENT_90|CONTENTS_CURRENT_180|CONTENTS_CURRENT_270|CONTENTS_CURRENT_UP|CONTENTS_CURRENT_DOWN);

// Trigger spawnflags
SF_TRIGGER_ALLOW_CLIENTS				<- 0x01;	// Players can fire this trigger
SF_TRIGGER_ALLOW_NPCS					<- 0x02;	// NPCS can fire this trigger
SF_TRIGGER_ALLOW_PUSHABLES				<- 0x04;	// Pushables can fire this trigger
SF_TRIGGER_ALLOW_PHYSICS				<- 0x08;	// Physics objects can fire this trigger
SF_TRIGGER_ONLY_PLAYER_ALLY_NPCS		<- 0x10;	// *if* NPCs can fire this trigger, this flag means only player allies do so
SF_TRIGGER_ONLY_CLIENTS_IN_VEHICLES		<- 0x20;	// *if* Players can fire this trigger, this flag means only players inside vehicles can
SF_TRIGGER_ALLOW_ALL					<- 0x40;	// Everything can fire this trigger EXCEPT DEBRIS!
SF_TRIGGER_ONLY_CLIENTS_OUT_OF_VEHICLES	<- 0x200;	// *if* Players can fire this trigger, this flag means only players outside vehicles can
SF_TRIG_PUSH_ONCE						<- 0x80;	// trigger_push removes itself after firing once
SF_TRIG_PUSH_AFFECT_PLAYER_ON_LADDER	<- 0x100;	// if pushed object is player on a ladder, then this disengages them from the ladder (HL2only)
SF_TRIG_TOUCH_DEBRIS 					<- 0x400;	// Will touch physics debris objects
SF_TRIGGER_ONLY_NPCS_IN_VEHICLES		<- 0X800;	// *if* NPCs can fire this trigger, only NPCs in vehicles do so (respects player ally flag too)
SF_TRIGGER_DISALLOW_BOTS                <- 0x1000;  // Bots are not allowed to fire this trigger

// Sprite spawnflags
SF_SPRITE_STARTON	<- 0x0001;
SF_SPRITE_ONCE		<- 0x0002;

// ScreenFade flags
FFADE_IN <- 0x0001; // Just here so we don't pass 0 into the function
FFADE_OUT <- 0x0002; // Fade out (not in)
FFADE_MODULATE <- 0x0004; // Modulate (don't blend)
FFADE_STAYOUT <- 0x0008; // ignores the duration, stays faded out until new ScreenFade message received
FFADE_PURGE <- 0x0010; // Purges all other fades, replacing them with this one

// Print Color Codes
PrintColorBeige <- "\x01";
PrintColorOrange <- "\x04";
PrintColorBrightGreen <- "\x03";
PrintColorOliveGreen <- "\x05";

class EmptyObject
{

}

InvalidValue <- {
	function IsValid() { return false; }
};

IdxToStr <- (class
{
	function _get(idx)
	{
		return idx.tostring();
	}
})();

function ArrayRemove(array, element)
{
	local idx = array.find(element);
	if (idx != null)
	{
		array.remove(idx);
		return true;
	}
	return false;
}

function ArrayAddNonduplicate(array, element)
{
	if (array.find(element) != null)
	{
		return false;
	}
	array.append(element);
	return true;
}

function ToArray(items)
{
	local t = typeof items;
	if (t == "array")
	{
		return items;
	}
	local array = [];
	foreach (item in items)
	{
		array.append(item);
	}
	return array;
}

function ToNewArray(items)
{
	local array = ToArray(items);
	if (array == items)
	{
		array = clone array;
	}
	return array;
}

function StringStartsWith(str1, str2)
{
	local len1 = str1.len();
	local len2 = str2.len();
	if (len1 < len2)
	{
		return false;
	}
	if (len1 == len2)
	{
		return str1 == str2;
	}
	return str1.slice(0, len2) == str2;
}

function StringEndsWith(str1, str2)
{
	local len1 = str1.len();
	local len2 = str2.len();
	if (len1 < len2)
	{
		return false;
	}
	if (len1 == len2)
	{
		return str1 == str2;
	}
	return str1.slice(len1 - len2, len1) == str2;
}

function IsNumber(obj)
{
	local t = typeof obj;
	return t == "integer" || t == "float";
}

function GetUniqueSlotName(table, prefix)
{
	if (!(prefix in table))
	{
		return prefix;
	}
	local i = 1;
	while (true)
	{
		local name = format("%s_%d", prefix, i);
		if (!(name in table))
		{
			return name;
		}
		i++;
	}
}

function Select(enumerable, selector)
{
	foreach (item in enumerable)
	{
		yield selector(item);
	}
}

function Where(enumerable, predicate)
{
	foreach (item in enumerable)
	{
		if (predicate(item))
		{
			yield item;
		}
	}
}

function ArrayRandomPick(array)
{
	return array[RandomInt(0, array.len() - 1)];
}

function ArrayRandomPickMultiple(array, count)
{
	local lastIdx = array.len() - 1;
	local tempArray = clone array;
	for (local i = 0; i < count; i++)
	{
		local pickIdx = RandomInt(i, lastIdx);
		yield tempArray[pickIdx];
		if (pickIdx != i)
		{
			local temp = tempArray[i];
			tempArray[i] = tempArray[pickIdx];
			tempArray[pickIdx] = temp;
		}
	}
}

function Shuffle(array)
{
	local lastIdx = array.len() - 1;
	for (local i = 0; i < lastIdx; i++)
	{
		local pickIdx = RandomInt(i, lastIdx);
		if (pickIdx != i)
		{
			local temp = array[i];
			array[i] = array[pickIdx];
			array[pickIdx] = temp;
		}
	}
	return array;
}

function Clamp(val, min, max)
{
	if (val < min)
	{
		return min;
	}
	if (val > max)
	{
		return max;
	}
	return val;
}

function Min(a, b)
{
	return a < b ? a : b;
}

function Max(a, b)
{
	return a > b ? a : b;
}

class Set
{
	_elements = null;

	constructor()
	{
		_elements = {};
	}

	function GetCount() { return _elements.len(); }

	function Add(obj)
	{
		if (obj in _elements)
		{
			return false;
		}
		_elements[obj] <- true;
		return true;
	}

	function Remove(obj)
	{
		if (obj in _elements)
		{
			delete _elements[obj];
			return true;
		}
		return false;
	}

	function Contains(obj)
	{
		return obj in _elements;
	}

	function Clear()
	{
		_elements.clear();
	}

	function Enumerate()
	{
		foreach (element, temp in _elements)
		{
			yield element;
		}
	}
}

class Event
{
	_handlers = null;

	constructor()
	{
		_handlers = [];
	}

	function _add(handler)
	{
		ctx.ArrayAddNonduplicate(_handlers, handler);
		return this;
	}

	function _sub(handler)
	{
		ctx.ArrayRemove(_handlers, handler);
		return this;
	}

	function Invoke(...)
	{
		local handlers = clone _handlers;
		local args = [null];
		args.extend(vargv);
		foreach (handler in handlers)
		{
			try
			{
				handler.acall(args);
			}
			catch (ex)
			{
				error(format("Exception occurred during invoking one of handlers of an Event: %s\n", ex.tostring()));
			}
		}
	}
}

class ShufflePicker
{
	_items = null;
	_cursor = 0;

	constructor(items)
	{
		items = ctx.ToNewArray(items);
		if (items.len() > 0)
		{
			_items = items;
			if (_items.len() > 1)
			{
				local pickIdx = RandomInt(0, _items.len() - 1);
				if (pickIdx != 0)
				{
					local temp = _items[0];
					_items[0] = _items[pickIdx];
					_items[pickIdx] = temp;
				}
			}
		}
	}

	function GetItems()
	{
		if (_items)
		{
			foreach (item in _items)
			{
				yield item;
			}
		}
	}

	function Pick()
	{
		if (!_items)
		{
			return null;
		}

		local lastIdx = _items.len() - 1;
		if (lastIdx == 0)
		{
			return _items[0];
		}
		if (_cursor >= lastIdx)
		{
			local item = _items[lastIdx];
			_cursor = 0;
			return item;
		}
		local pickIdx = RandomInt(_cursor, _cursor == 0 ? lastIdx - 1 : lastIdx);
		local item = _items[pickIdx];
		if (pickIdx != _cursor)
		{
			local temp = _items[_cursor];
			_items[_cursor] = _items[pickIdx];
			_items[pickIdx] = temp;
		}
		_cursor++;
		return item;
	}
}

function IsEntity(obj)
{
	if ("CBaseEntity" in getroottable())
	{
		return obj instanceof ::CBaseEntity;
	}
	return false;
}

function FindEntitiesByName(name)
{
	for (local ent = null; ent = Entities.FindByName(ent, name);)
	{
		yield ent;
	}
}

function SetEntityParent(ent, parentEnt)
{
	if (parentEnt)
	{
		DoEntFire("!caller", "SetParent", "!activator", 0, parentEnt, ent);
	}
	else
	{
		DoEntFire("!caller", "ClearParent", "", 0, null, ent);
	}
}

function GetEntityAnimatingData(ent)
{
	local data = {};
	data.Origin <- ent.GetOrigin();
	data.Angles <- ent.GetAngles();
	data.ModelName <- ent.GetModelName();
	if ("GetSequence" in ent)
	{
		data.Sequence <- ent.GetSequence();
	}
	return data;
}

function SetEntityAnimatingData(ent, data)
{
	if ("Origin" in data)
	{
		ent.SetOrigin(data.Origin);
	}
	if ("Angles" in data)
	{
		ent.SetAngles(data.Angles);
	}
	if ("ModelName" in data)
	{
		ent.SetModel(data.ModelName);
	}
	if ("SetSequence" in ent && "Sequence" in data)
	{
		ent.SetSequence(data.Sequence);
	}
}

function CreateRagdollFromPlayer(player)
{
	local ragdoll = SpawnEntityFromTable("cs_ragdoll", {});
	NetProps.SetPropVector(ragdoll, "m_vecOrigin", player.GetOrigin());
	NetProps.SetPropVector(ragdoll, "m_vecRagdollOrigin", player.GetOrigin());
	NetProps.SetPropInt(ragdoll, "m_nModelIndex", NetProps.GetPropInt(player, "m_nModelIndex"));
	NetProps.SetPropInt(ragdoll, "m_iTeamNum", NetProps.GetPropInt(player, "m_iTeamNum"));
	NetProps.SetPropEntity(ragdoll, "m_hPlayer", player);
	NetProps.SetPropInt(ragdoll, "m_iDeathPose", NetProps.GetPropInt(player, "m_nSequence"));
	NetProps.SetPropInt(ragdoll, "m_iDeathFrame", NetProps.GetPropInt(player, "m_flAnimTime"));
	NetProps.SetPropInt(ragdoll, "m_nForceBone", NetProps.GetPropInt(player, "m_nForceBone"));
	NetProps.SetPropInt(ragdoll, "m_ragdollType", 4);
	NetProps.SetPropInt(ragdoll, "m_survivorCharacter", NetProps.GetPropInt(player, "m_survivorCharacter"));
	NetProps.SetPropEntity(player, "m_hRagdoll", ragdoll);

	// local ragdoll = SpawnEntityFromTable("prop_ragdoll", { model = player.GetModelName() });
	// NetProps.SetPropVector(ragdoll, "m_vecOrigin", player.GetOrigin());
	// NetProps.SetPropVector(ragdoll, "m_ragPos", player.GetOrigin());
	// NetProps.SetPropInt(ragdoll, "m_nForceBone", NetProps.GetPropInt(player, "m_nForceBone"));

	return ragdoll;
}

function CreatePropDynamicFromEntity(ent)
{
	local prop = SpawnEntityFromTable("prop_dynamic_override", { solid = 0, model = NullModelName });
	SetEntityAnimatingData(prop, GetEntityAnimatingData(ent));
	return prop;
}

function GetFatalDamage(ent)
{
	local damage = ent.GetHealth() + 1;
	if ("GetHealthBuffer" in ent)
	{
		damage += ent.GetHealthBuffer().tointeger() + 1;
	}
	return damage;
}

function TakeFatalDamage(ent, damageType = 0, attacker = null)
{
	ent.TakeDamage(GetFatalDamage(ent), damageType, attacker);
	if (ent.IsValid())
	{
		if (ent.IsPlayer())
		{
			if (!IsPlayerDead(ent))
			{
				local maxTryCount = 30;
				local tryCount = 0;
				local function ShouldTakeDamage()
				{
					return tryCount < maxTryCount && ent.IsValid() && !IsPlayerDead(ent);
				}

				local coroutine = Coroutine(function()
				{
					while (true)
					{
					    ent.TakeDamage(GetFatalDamage(ent), damageType, attacker);
						tryCount++;
						if (ShouldTakeDamage())
						{
							yield 0.2;
							if (ShouldTakeDamage())
							{
								continue;
							}
						}
						break;
					}
			    }.bindenv(ctx)());
				coroutine.SetAutoKilledOnNewRound(true);
				coroutine.Start();
				if (!coroutine.IsDead())
				{
					return coroutine;
				}
			}
		}
	}
	return null;
}

function TakeDamageConvertToBuffer(player, damage, damageType = 0, attacker = null)
{
	if (player.IsIncapacitated())
	{
		player.TakeDamage(damage, damageType, attacker);
		return;
	}

	local health = player.GetHealth() - 1;
	if (health <= 0)
	{
		player.TakeDamage(damage, damageType, attacker);
		return;
	}
	player.SetHealthBuffer(player.GetHealthBuffer() + Min(health, damage));
	player.TakeDamage(damage, damageType, attacker);
}

function IsPlayerDead(player)
{
	return player.IsDead() || player.IsDying();
}

function IsInfectedEntity(ent)
{
	if (ent.IsPlayer() && !ent.IsSurvivor())
	{
		return true;
	}
	local classname = ent.GetClassname();
	return classname == "infected" || classname == "witch";
}

function IsAliveSurvivor(ent)
{
	return ent.IsPlayer() && ent.IsSurvivor() && !IsPlayerDead(ent);
}

function GetPlayers()
{
	for (local player = null; player = Entities.FindByClassname(player, "player");)
	{
		yield player;
	}
}

function GetSurvivors()
{
	foreach (player in GetPlayers())
	{
		if (player.IsSurvivor())
		{
			yield player;
		}
	}
}

function GetAliveSurvivors()
{
	foreach (survivor in GetSurvivors())
	{
		if (!IsPlayerDead(survivor))
		{
			yield survivor;
		}
	}
}

function MoveEntityTo(ent, pos)
{
	local entScope = ent.GetScriptScope();
	if (entScope)
	{
		if ("MoveTo" in entScope)
		{
			entScope.MoveTo(pos);
			return;
		}
		if ("SetPosition" in entScope)
		{
			entScope.SetPosition(pos);
			return;
		}
	}
	ent.SetOrigin(pos);
}

function TeleportPlayer(player, target)
{
	if (target instanceof Vector)
	{
		player.SetOrigin(target);
	}
	else if (IsEntity(target))
	{
		player.SetOrigin(target.GetOrigin());
		player.SnapEyeAngles(target.GetAngles());
	}
}