using UnityEngine;using UnityEngine.Events;
public class NXPMissionDirector:MonoBehaviour{
 public int requiredKills=8,requiredCores=3;public int kills,cores;public GameObject bossPrefab;public Transform bossSpawn;public UnityEvent onBossSpawn,onComplete;GameObject boss;
 public void EnemyKilled(){kills++;Check();}
 public void CoreCollected(){cores++;Check();}
 void Check(){if(!boss&&kills>=requiredKills&&cores>=requiredCores){boss=Instantiate(bossPrefab,bossSpawn.position,bossSpawn.rotation);onBossSpawn?.Invoke();}}
 public void BossKilled(){NXPProgression.I.AddXP(250);NXPProgression.I.AddCredits(150);onComplete?.Invoke();}
}