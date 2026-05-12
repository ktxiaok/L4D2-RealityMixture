local ctx = this;

ViewNames.HorrorCommon <- [];

function ViewNames::LoadHorrorCommon()
{
	local viewNames = HorrorCommon;
	viewNames.clear();
	foreach (name in GetViewNames())
	{
		if (StringStartsWith(name, "horror_common"))
		{
			viewNames.append(name);
		}
	}
}

ViewsLoaded + @() ctx.ViewNames.LoadHorrorCommon();

MaterialNames.FaceAnomalyCommon <- [
	"reality_mixture/sprites/anomalies/face_01.vmt"
];

SoundNames.InsanityNoise <- [
	"reality_mixture/player/insanity_noise_01.wav",
	"reality_mixture/player/insanity_noise_02.wav",
	"reality_mixture/player/insanity_noise_03.wav",
	"reality_mixture/player/insanity_noise_04.wav",
	"reality_mixture/player/insanity_noise_05.wav",
	"reality_mixture/player/insanity_noise_06.wav",
	"reality_mixture/player/insanity_noise_07.wav",
	"reality_mixture/player/insanity_noise_08.wav",
	"reality_mixture/player/insanity_noise_09.wav"
];
