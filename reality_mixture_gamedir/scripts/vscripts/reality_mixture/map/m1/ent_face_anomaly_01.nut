local effectTrigger = Ent("face_anomaly_01_effect_trigger");
::RealityMixture.FaceAnomaly(self, { EffectTrigger = effectTrigger });
::RealityMixture.EntityRandomPointMover(self, { Points = ::RealityMixture.FindEntitiesByName("face_anomaly_01_point_*"), MinInterval = 1, MaxInterval = 4, ActiveTrigger = effectTrigger });