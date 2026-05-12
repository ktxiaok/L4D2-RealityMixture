local effectTrigger = Ent("face_anomaly_05_effect_trigger");
::RealityMixture.FaceAnomaly(self, { EffectTrigger = effectTrigger, DirectEffectRange = 100 });
::RealityMixture.EntityRandomPointMover(self, { Points = ::RealityMixture.FindEntitiesByName("face_anomaly_05_point_*"), MinInterval = 1, MaxInterval = 4, ActiveTrigger = effectTrigger });