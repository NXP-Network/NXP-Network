using UnityEngine;
public class NXPWeapon : MonoBehaviour { public Camera aimCamera; public Transform muzzle; public ParticleSystem muzzleFlash; public float damage=24,range=70,fireRate=.13f; public LayerMask hitMask; float next;
 public void Fire(){if(Time.time<next)return;next=Time.time+fireRate;muzzleFlash?.Play();if(Physics.Raycast(aimCamera.ViewportPointToRay(new Vector3(.5f,.5f)),out var h,range,hitMask))h.collider.GetComponentInParent<NXPHealth>()?.Damage(damage);}
}