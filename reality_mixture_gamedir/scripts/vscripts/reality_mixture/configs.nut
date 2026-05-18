ConfigItem("InsanityMax", 						"float", 	3.0, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityDecayRate", 				"float", 	0.8, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityHorrorViewThreshold", 		"float", 	0.5, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityDamageThreshold", 			"float", 	1.5, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityHorrorViewDurationMin", 	"float", 	0.2, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityHorrorViewDurationMax", 	"float", 	1.0, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityHorrorViewIntervalMin", 	"float", 	0.3, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityHorrorViewIntervalMax", 	"float", 	1.3, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityDamageInterval", 			"float", 	0.5, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityDamageMax", 				"integer", 	10,		RangeConfigFilters.NonNegative);
ConfigItem("InsanityScreenFadeTime", 			"float", 	1.0, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityScreenFadeHold", 			"float", 	0.25, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityScreenFadeIntervalMin", 	"float", 	0.8, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityScreenFadeIntervalMax", 	"float", 	1.4, 	RangeConfigFilters.NonNegative);
ConfigItem("InsanityNoiseIntervalMin",			"float",	0.8,	RangeConfigFilters.NonNegative);
ConfigItem("InsanityNoiseIntervalMax",			"float",	2.0,	RangeConfigFilters.NonNegative);
ConfigItem("InsanityEyeDeflectionMax",			"float",	15.0,	RangeConfigFilters.NonNegative);
ConfigItem("InsanityEyeDeflectionIntervalMin",	"float", 	0.1,	RangeConfigFilters.NonNegative);
ConfigItem("InsanityEyeDeflectionIntervalMax",	"float",	0.6,	RangeConfigFilters.NonNegative);

ConfigItem("InsanitySpaceInsanityIncreaseRate", "float", 0.5, RangeConfigFilters.NonNegative);

ConfigItem("FaceAnomalyEffectRange", 			"float",	 	1000.0,		RangeConfigFilters.NonNegative);
ConfigItem("FaceAnomalyDirectEffectRange", 		"float",	 	200.0, 		RangeConfigFilters.NonNegative);
ConfigItem("FaceAnomalyEffectVisCosMin",		"float",		0.5,		RangeConfigFilter(0, 0.99));
ConfigItem("FaceAnomalyInsanityMagnitude", 		"float",	 	2.0, 		RangeConfigFilters.NonNegative);
ConfigItem("FaceAnomalyInsanityAttenuation", 	"float",	 	4.e-6, 		RangeConfigFilters.NonNegative);
ConfigItem("FaceAnomalyInfectedDamage",			"integer",		200,		RangeConfigFilters.NonNegative);

function ReloadConfigs()
{
	IncludeScript("reality_mixture/configs");
}