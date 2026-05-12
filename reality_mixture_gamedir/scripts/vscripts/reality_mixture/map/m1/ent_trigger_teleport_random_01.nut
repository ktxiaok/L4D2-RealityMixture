TeleportDestinations <- ::RealityMixture.ToArray(::RealityMixture.FindEntitiesByName("teleport_dst_04_*"));

local dstPicker = ::RealityMixture.ShufflePicker(TeleportDestinations);

function OnStartTouch_Teleport()
{
	if (activator && activator.IsPlayer())
	{
		::RealityMixture.TeleportPlayer(activator, dstPicker.Pick());
	}
}

self.ConnectOutput("OnStartTouch", "OnStartTouch_Teleport");