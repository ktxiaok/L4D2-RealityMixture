local effectTrigger = Ent("face_anomaly_effect_trigger_02");
::RealityMixture.FaceAnomaly(self, { EffectTrigger = effectTrigger });
::RealityMixture.EntityRandomPointMover(self, { Points = ::RealityMixture.FindEntitiesByName("face_anomaly_02_point_*"), MinInterval = 1, MaxInterval = 4, ActiveTrigger = effectTrigger });