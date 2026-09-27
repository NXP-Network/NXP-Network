using UnityEngine;using UnityEngine.AI;
[RequireComponent(typeof(NavMeshAgent))]
public class NXPEnemyAI:MonoBehaviour{
 public Transform target;public float attackRange=2.2f,damage=8,attackDelay=1f;NavMeshAgent agent;float next;
 void Awake(){agent=GetComponent<NavMeshAgent>();}
 void Update(){if(!target)return;float d=Vector3.Distance(transform.position,target.position);if(d>attackRange){agent.isStopped=false;agent.SetDestination(target.position);}else{agent.isStopped=true;transform.LookAt(new Vector3(target.position.x,transform.position.y,target.position.z));if(Time.time>=next){next=Time.time+attackDelay;target.GetComponent<NXPHealth>()?.Damage(damage);}}}
}