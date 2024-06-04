using System.Collections;
using System.Collections.Generic;
using UnityEngine;


// This is a legacy script that allows similar functionality to the snowtracks
// script if the object being rendered onto was terrain
public class TerrainScript : MonoBehaviour
{
    private Terrain terrain;
    public Shader _drawShader;

    private RenderTexture _splatMap;
    private Material _drawMaterial, _snowMaterial;

    [Range(1, 500)]
    public float _brushSize;
    [Range(0, 1)]
    public float _brushStrength;

    public GameObject trailObject;

    private RaycastHit _hit;

    // Start is called before the first frame update
    void Start()
    {
        _drawMaterial = new Material(_drawShader);
        _drawMaterial.SetVector("_Color", Color.red);

        terrain = GetComponent<Terrain>();
        _snowMaterial = terrain.materialTemplate;

        _splatMap = new RenderTexture(terrain.terrainData.heightmapResolution, terrain.terrainData.heightmapResolution, 0, RenderTextureFormat.ARGBFloat);
        _snowMaterial.SetTexture("_Splat", _splatMap);
    }

    // Update is called once per frame
    void Update()
    {
        TerrainCollider terrainCollider = GetComponent<TerrainCollider>();

        Ray ray = new Ray(trailObject.transform.position + Vector3.up * 500, Vector3.down);
        if (terrainCollider.Raycast(ray, out _hit, float.MaxValue))
        {
            // Convert hit.point to terrain local coordinates
            Vector3 terrainLocalPos = _hit.point - terrain.transform.position;
            Vector3 normalizedPos = new Vector3(
                terrainLocalPos.x / terrain.terrainData.size.x,
                0,
                terrainLocalPos.z / terrain.terrainData.size.z
            );

            _drawMaterial.SetVector("_Coordinate", new Vector4(normalizedPos.x, normalizedPos.z, 0, 0));
            _drawMaterial.SetFloat("_Strength", _brushStrength);
            _drawMaterial.SetFloat("_Size", _brushSize);

            RenderTexture temp = RenderTexture.GetTemporary(_splatMap.width, _splatMap.height, 0, RenderTextureFormat.ARGBFloat);
            Graphics.Blit(_splatMap, temp);
            Graphics.Blit(temp, _splatMap, _drawMaterial);
            RenderTexture.ReleaseTemporary(temp);
        }
    }
}
