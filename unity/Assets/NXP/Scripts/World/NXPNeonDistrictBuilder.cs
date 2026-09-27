using UnityEngine;
public class NXPNeonDistrictBuilder:MonoBehaviour{
 public Material road,sidewalk,building,neonCyan,neonPink,metal;public GameObject playerPrefab,soldierPrefab,spiderPrefab,corePrefab,bossPrefab;
 GameObject Box(string n,Vector3 p,Vector3 s,Material m){var g=GameObject.CreatePrimitive(PrimitiveType.Cube);g.name=n;g.transform.SetPositionAndRotation(p,Quaternion.identity);g.transform.localScale=s;if(m)g.GetComponent<Renderer>().sharedMaterial=m;g.isStatic=true;return g;}
 void Start(){Build();}
 [ContextMenu("Build Neon District")]
 public void Build(){Box("Wet_Asphalt",new(0,-.15f,0),new(28,.3f,52),road);Box("Walk_L",new(-18,.05f,0),new(8,.4f,52),sidewalk);Box("Walk_R",new(18,.05f,0),new(8,.4f,52),sidewalk);
 for(int i=0;i<8;i++){float z=-21+i*6.2f;Box("Building_L_"+i,new(-20,2.5f,z),new(8,5+(i%3)*2,5),building);Box("Building_R_"+i,new(20,2.5f,z+2),new(8,6+((i+1)%3)*2,5),building);Box("Neon_L_"+i,new(-15.8f,3,z),new(.15f,1.1f,2.4f),i%2==0?neonPink:neonCyan);Box("Neon_R_"+i,new(15.8f,3,z+2),new(.15f,1.1f,2.4f),i%2==0?neonCyan:neonPink);}
 for(int i=0;i<9;i++){float x=(i%3-1)*5.5f,z=-18+(i/3)*14;Box("Barrier_"+i,new(x,.55f,z),new(2.8f,1.1f,.7f),metal);}
 if(playerPrefab)Instantiate(playerPrefab,new Vector3(0,1,-20),Quaternion.identity);
 for(int i=0;i<6;i++)if(soldierPrefab)Instantiate(soldierPrefab,new Vector3(Random.Range(-8,8),1,Random.Range(-12,18)),Quaternion.identity);
 for(int i=0;i<2;i++)if(spiderPrefab)Instantiate(spiderPrefab,new Vector3(Random.Range(-8,8),.6f,Random.Range(-8,18)),Quaternion.identity);
 for(int i=0;i<3;i++)if(corePrefab)Instantiate(corePrefab,new Vector3(Random.Range(-7,7),1,Random.Range(-5,20)),Quaternion.identity);
 }}