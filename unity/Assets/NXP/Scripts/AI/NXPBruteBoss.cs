using UnityEngine;using UnityEngine.AI;
public class NXPBruteBoss:MonoBehaviour{
 public Transform target;public NavMeshAgent agent;public float slamRange=3.4f,slamDamage=28,chargeSpeed=9;float next;
 void Update(){if(!target)return;float d=Vector3.Distance(transform.position,target.position);agent.SetDestination(target.position);if(d<slamRange&&Time.time>next){next=Time.time+2.4f;target.GetComponent<NXPHealth>()?.Damage(slamDamage);}}
}