local targetMapNames = {
	reality_mixture_test = true,
	reality_mixture_m1_entrance = true,
	reality_mixture_m2_pipes = true
};

local mapName = Director.GetMapName();
if (mapName in targetMapNames)
{
	if (!("RealityMixture" in getroottable()))
	{
		::RealityMixture <- {};
		IncludeScript("reality_mixture/common", ::RealityMixture);

		local mapScope = {};
		::RealityMixture.MapScope <- mapScope;
		IncludeScript(format("reality_mixture/map/%s", mapName), mapScope);
	}

	::RealityMixture.PrecacheAssets();

	local mapOptions = {};
	::DirectorScript.MapScript.MapOptions <- mapOptions;
	IncludeScript("reality_mixture/map/default_map_options", mapOptions);
	IncludeScript(format("reality_mixture/map/%s_map_options", mapName), mapOptions);

	printl("reality_mixture scriptedmode_addon loaded.");
}