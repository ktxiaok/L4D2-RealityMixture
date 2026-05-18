local entscope = this;

MaxPortalIndex <- 3;
FloorCount <- 3;
PossibleInfectedTypes <- [DirectorScript.ZOMBIE_HUNTER, DirectorScript.ZOMBIE_JOCKEY, DirectorScript.ZOMBIE_SMOKER];
WrongPathHintThreshold <- 5;

Path <- [];
TeleportDestinations <- [];
InfectedSpawnTargets <- [];
WrongPathCounter <- 0;

for (local i = 0; i < FloorCount; i++)
{
	Path.append(RandomInt(1, MaxPortalIndex));
}

for (local floor = 0; floor <= (FloorCount + 1); floor++)
{
	TeleportDestinations.append(Ent(format("teleport_dst_hallwaypuzzle_%d", floor)));
}

for (local floor = 1; floor < FloorCount; floor++)
{
	InfectedSpawnTargets.append(Ent(format("target_hallwaypuzzle_infected_spawn_%d", floor)));
}

function TeleportPlayer(player, dst)
{
	player.SetOrigin(dst.GetOrigin());
	player.SnapEyeAngles(dst.GetAngles());
}

function SpawnInfected(target)
{
	ZSpawn({ type = ::RealityMixture.ArrayRandomPick(PossibleInfectedTypes), pos = target.GetOrigin(), ang = target.GetAngles() });
}

function ShowWrongPathHint(player)
{
	ClientPrint(player, DirectorScript.HUD_PRINTTALK, ::RealityMixture.PrintColorOrange + ::RealityMixture.LocalResourceManagerDefault.GetResourceByPlayer("TakeWrongPathAgain", player));
}

function PortalTeleport(activator, floor, portalIndex)
{
	if (portalIndex == Path[floor - 1])
	{
		TeleportPlayer(activator, TeleportDestinations[floor + 1]);
	}
	else
	{
		TeleportPlayer(activator, TeleportDestinations[floor - 1]);

		WrongPathCounter++;
		if (WrongPathCounter > WrongPathHintThreshold)
		{
			ShowWrongPathHint(activator);
		}

		local infectedSpawnTargetIndex = floor - 2;
		if (infectedSpawnTargetIndex >= 0)
		{
			SpawnInfected(InfectedSpawnTargets[infectedSpawnTargetIndex]);
		}
	}
}

for (local floor = 1; floor <= FloorCount; floor++)
{
	for (local portalIndex = 1; portalIndex <= MaxPortalIndex; portalIndex++)
	{
		local portalTrigger = Ent(format("trigger_portal_hallwaypuzzle_%d_%d", floor, portalIndex));
		portalTrigger.ValidateScriptScope();
		local portalTriggerScope = portalTrigger.GetScriptScope();
		portalTriggerScope.Floor <- floor;
		portalTriggerScope.PortalIndex <- portalIndex;
		portalTriggerScope.Portal_OnStartTouch <- function()
		{
			if (activator && activator.IsValid() && activator.IsPlayer())
			{
				entscope.PortalTeleport(activator, Floor, PortalIndex);
			}
		};
		portalTrigger.ConnectOutput("OnStartTouch", "Portal_OnStartTouch");
	}
}
