local entscope = this;

SoundNames <- [
	"reality_mixture/ambient/door_bang_01.wav",
	"reality_mixture/ambient/door_bang_02.wav",
	"reality_mixture/ambient/door_bang_03.wav",
	"reality_mixture/ambient/door_bang_04.wav",
	"reality_mixture/ambient/door_knock_01.wav",
	"reality_mixture/ambient/door_knock_02.wav"
];
MinInterval <- 3;
MaxInterval <- 6;
SoundLevel <- 80;
MinPitch <- 80;
MaxPitch <- 120;
PlayTargets <- ::RealityMixture.ToArray(::RealityMixture.FindEntitiesByName("hallwaypuzzle_sound_point*"));

_soundPicker <- ::RealityMixture.ShufflePicker(SoundNames);
_playCoroutineRef <- ::RealityMixture.AliveCoroutineRef();

function Enable()
{
	_TryCreatePlayCoroutine();
}

function Disable()
{
	_playCoroutineRef.Kill();
}

function Precache()
{
	foreach (sound in SoundNames)
	{
		PrecacheSound(sound);
	}
}

function _TryCreatePlayCoroutine()
{
	local coroutine = _playCoroutineRef.Get();
	if (!coroutine)
	{
		coroutine = ::RealityMixture.Coroutine.Loop(@() entscope._PlayCoroutineLoop());
		coroutine.SetAutoKilledOnNewRound(true);
		coroutine.Start();
		_playCoroutineRef.Set(coroutine);
	}
}

function _PlayCoroutineLoop()
{
	if (!self.IsValid())
	{
		return null;
	}

	local target = ::RealityMixture.ArrayRandomPick(PlayTargets);
	if (target.IsValid())
	{
		EmitAmbientSoundOn(_soundPicker.Pick(), 1, SoundLevel, RandomInt(MinPitch, MaxPitch), target);
	}
	return RandomFloat(MinInterval, MaxInterval);
}

::RealityMixture.AddEntityInvalidationListener(self, @() entscope.Disable());