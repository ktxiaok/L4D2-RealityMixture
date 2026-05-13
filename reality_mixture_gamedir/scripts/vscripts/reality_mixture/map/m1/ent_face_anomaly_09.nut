local effectTrigger = Ent("face_anomaly_09_effect_trigger");
::RealityMixture.FaceAnomaly(self, { EffectTrigger = effectTrigger });
::RealityMixture.EntityRandomPointMover(self, { Points = ::RealityMixture.FindEntitiesByName("face_anomaly_09_point_*"), MinInterval = 3, MaxInterval = 6, ActiveTrigger = effectTrigger });