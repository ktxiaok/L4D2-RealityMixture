local effectTrigger = Ent("face_anomaly_07_effect_trigger");
::RealityMixture.FaceAnomaly(self, { EffectTrigger = effectTrigger, DirectEffectRange = 100 });
::RealityMixture.EntityRandomPointMover(self, { Points = ::RealityMixture.FindEntitiesByName("face_anomaly_07_point_*"), MinInterval = 3, MaxInterval = 6, ActiveTrigger = effectTrigger });