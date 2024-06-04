using System.Collections;
using System.Collections.Generic;
using Unity.Burst.CompilerServices;
using UnityEngine;

// a script to make tracks in the snow through the use of a renderTexture
public class SnowTrackMaker : MonoBehaviour
{
    // the shader to draw the tracks. Note this is NOT the snowShader, but
    // a separate intermediate shader.
    public Shader _drawShader;

    public float regenSpeed; // the speed with which the snow will regenerate

    private RenderTexture _splatMap; // the splatmap that will map our divots
    private Material _snowMaterial, _drawMaterial; // materials

    [Range(1, 500)]
    public float _brushSize; // size of the brush
    [Range(0, 1)]
    public float _brushStrength; // strength of the brush

    public GameObject[] trailObjects; // objects that will cause tracks. 
    // for the purposes of the diorama, these are in the two front wheels


    private RaycastHit _hit;
    // Start is called before the first frame update
    void Start()
    {
        // sent information in the drawShader
        _drawMaterial = new Material(_drawShader);
        _drawMaterial.SetVector("_Color", Color.red);
        _drawMaterial.SetFloat("RegenSpeed", regenSpeed);

        // get the material from the meshrenderer
        _snowMaterial = GetComponent<MeshRenderer>().material;

        // create a rendertexture for the splatmap
        _splatMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        _snowMaterial.SetTexture("_Splat", _splatMap);
    }

    // Update is called once per frame
    void Update()
    {
        foreach (GameObject trailObject in trailObjects) {
            if (Physics.Raycast(trailObject.transform.position, Vector3.down, out _hit))
            {
                // set coords and update parameters for drawing
                _drawMaterial.SetVector("_Coordinate", new Vector4(_hit.textureCoord.x, _hit.textureCoord.y, 0, 0));
                _drawMaterial.SetFloat("_Strength", _brushStrength); // these are done each hit so that these variables can be changed at runtime
                _drawMaterial.SetFloat("_Size", _brushSize);

                // create a temporary renderTexture for processing
                RenderTexture temp = RenderTexture.GetTemporary(_splatMap.width, _splatMap.height, 0, RenderTextureFormat.ARGBFloat);
                // Copy the existing splatmap to the temporary texture, effectively combining the two
                Graphics.Blit(_splatMap, temp);
                // Recopy the new combined map back to the splatmap, applying the brush
                Graphics.Blit(temp, _splatMap, _drawMaterial);
                // release the temporary texture
                RenderTexture.ReleaseTemporary(temp); 
            }
        }
        // update regen speed
        _drawMaterial.SetFloat("_RegenSpeed", regenSpeed);
    }

}
