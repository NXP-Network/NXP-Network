using UnityEngine;
public class NXPGraphicsBootstrap:MonoBehaviour{
 [Header("Ultra target")]public bool ultra=true;public Light keyLight;public ReflectionProbe reflectionProbe;
 void Start(){Application.targetFrameRate=60;if(ultra)QualitySettings.SetQualityLevel(QualitySettings.names.Length-1,true);if(keyLight){keyLight.shadows=LightShadows.Soft;keyLight.shadowStrength=.85f;}reflectionProbe?.RenderProbe();}
}