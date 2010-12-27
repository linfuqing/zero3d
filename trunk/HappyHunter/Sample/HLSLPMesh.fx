//==============================================================
// Desc: Ч���ļ�
//==============================================================

//--------------------------------------------------------------
// ȫ�ֱ���
//--------------------------------------------------------------
float4x4 matWorldViewProj:WORLDVIEWPROJECTION;
float4 MaterialAmbient:MATERIALAMBIENT = {0.1f, 0.1f, 0.1f, 1.0f};
float4 MaterialDiffuse:MATERIALDIFFUSE = {0.8f, 0.8f, 0.8f, 1.0f};
float4 vecLightDir:LIGHTDIRECTION = {-1.0f, -1.0f, -1.0f, 1.0f};

//--------------------------------------------------------------
// ���������
//--------------------------------------------------------------
texture ColorMap;
sampler ColorMapSampler = sampler_state
{
   Texture = <ColorMap>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;   
};

//--------------------------------------------------------------
// ������Ⱦ������ṹ
//--------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Pos  	 : POSITION;
    float4 Diffuse	 : COLOR;
    float2 Tex  	 : TEXCOORD0;
};

//--------------------------------------------------------------
//������Ⱦ������ṹ
//--------------------------------------------------------------
struct PS_OUTPUT
{
    float4 Color  : COLOR;
};

//---------------------------------------------------------
// �Ӻ���, �������ϵ��
//---------------------------------------------------------
float3 Diffuse(float3 Normal)
{
    float CosTheta;
    CosTheta = max(0.0f, dot(Normal, vecLightDir.xyz));
    return (CosTheta);
}

//--------------------------------------------------------------
//  ������Ⱦ��������
//--------------------------------------------------------------
VS_OUTPUT VS(float4 Pos : POSITION, float3 Normal : NORMAL, float3 Tex : TEXCOORD0)
{
   VS_OUTPUT Out = (VS_OUTPUT)0;
   
   //��������任
   Out.Pos = mul(Pos, matWorldViewProj);
   Out.Tex = Tex.xy;
   
   //�������
   Out.Diffuse.xyz = MaterialAmbient.xyz + Diffuse(Normal) * MaterialDiffuse.xyz;
   Out.Diffuse.w = 1.0f;
      
   return Out;
}

//--------------------------------------------------------------
// Desc: ������Ⱦ��������
//--------------------------------------------------------------
PS_OUTPUT PS(float2 Tex: TEXCOORD0, float4 Diffuse : COLOR)
{
    PS_OUTPUT Out_ps = (PS_OUTPUT)0;
    
    //��ɫ�������
    float4 color     = tex2D(ColorMapSampler, Tex);

    //������ɫ
    Out_ps.Color = color * Diffuse;
    
    return Out_ps;
}


//--------------------------------------------------------------
// Desc: ����
//--------------------------------------------------------------
technique t0
{
    pass P0
    {
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}

