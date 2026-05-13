local effectTrigger = Ent("face_anomaly_04_effect_trigger");
::RealityMixture.FaceAnomaly(self, { EffectTrigger = effectTrigger });
::RealityMixture.EntityRandomPointMover(self, { Points = ::RealityMixture.FindEntitiesByName("face_anomaly_04_point_*"), MinInterval = 3, MaxInterval = 6, ActiveTrigger = effectTrigger });