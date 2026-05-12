local ctx = this;

EnsureModelPrecached("sprites/blueglow1.vmt");
EnsureModelPrecached("effects/combinemuzzle2.vmt");

_dissolverEnt <- InvalidValue;

function _GetDissolverEntity()
{
	if (!_dissolverEnt.IsValid())
	{
		_dissolverEnt = SpawnEntityFromTable("env_entity_dissolver", {});
	}
	return _dissolverEnt;
}

function DissolveEntity(ent, magnitude = 1, dissolveType = 0)
{
	local dissolver = _GetDissolverEntity();
	NetProps.SetPropInt(dissolver, "m_nMagnitude", magnitude);
	NetProps.SetPropInt(dissolver, "m_nDissolveType", dissolveType);
	DoEntFire("!caller", "Dissolve", "!activator", 0, ent, dissolver);
}