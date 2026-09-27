using UnityEngine;
public class NXPDataCore:MonoBehaviour{
 public NXPMissionDirector mission;public ParticleSystem collectVFX;
 void OnTriggerEnter(Collider other){if(!other.CompareTag("Player"))return;mission.CoreCollected();NXPProgression.I.AddXP(20);NXPProgression.I.AddCredits(20);if(collectVFX)Instantiate(collectVFX,transform.position,Quaternion.identity);Destroy(gameObject);}
}