using UnityEngine;
[RequireComponent(typeof(CharacterController))]
public class NXPPlayerController : MonoBehaviour {
 public float moveSpeed=5.5f, dashSpeed=13f, dashTime=.18f; public Transform cameraTransform; CharacterController cc; Vector2 input; float dash;
 void Awake(){cc=GetComponent<CharacterController>();}
 public void SetMove(Vector2 v)=>input=Vector2.ClampMagnitude(v,1);
 public void Dash(){if(dash<=0)dash=dashTime;}
 void Update(){Vector3 f=Vector3.ProjectOnPlane(cameraTransform.forward,Vector3.up).normalized,r=Vector3.ProjectOnPlane(cameraTransform.right,Vector3.up).normalized; Vector3 m=f*input.y+r*input.x; float s=dash>0?dashSpeed:moveSpeed; cc.Move(m*s*Time.deltaTime); if(m.sqrMagnitude>.02f) transform.forward=Vector3.Slerp(transform.forward,m,14*Time.deltaTime); dash-=Time.deltaTime;}
}