ZombieSpawnCount <- 10;
ZombieSpawnPointPair <- ::RealityMixture.ToArray(::RealityMixture.FindEntitiesByName("point_zombie_spawn_01"));

function SpawnZombies()
{
	local count = ZombieSpawnCount;
	local p1 = ZombieSpawnPointPair[0].GetOrigin();
	local p2 = ZombieSpawnPointPair[1].GetOrigin();
	local dp = p2 - p1;
	for (local i = 0; i < count; i++)
	{
		ZSpawn({ type = 0, pos = p1 + dp * RandomFloat(0, 1), ang = QAngle(0, RandomFloat(0, 360), 0) });
	}
}