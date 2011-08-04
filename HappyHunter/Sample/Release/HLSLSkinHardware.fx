//=========================================================
// Desc: Ч��Դ����
//=========================================================


//---------------------------------------------------------
// ȫ�ֱ���
//---------------------------------------------------------
float4x4 matWorld : WORLD;	
float4   vecLightDir;
float4   vecEye : EYEPOSITION;

float4 lightDiffuse = {0.6f, 0.6f, 0.6f, 1.0f}; 
//float4 MaterialAmbient : MATERIALAMBIENT = {0.1f, 0.1f, 0.1f, 1.0f};
//float4 MaterialDiffuse : MATERIALDIFFUSE = {0.8f, 0.8f, 0.8f, 1.0f};

static const int MAX_MATRICES = 26;
float4x3    mWorldMatrixArray[MAX_MATRICES] : WORLDMATRIXARRAY;
float       CurNumBones : BONEINFLUENCESNUMBER = 2;    //��ǰ��������
//float4x4    mProj : PROJECTION;
float4x4    mWorldViewProj : WORLDVIEWPROJECTION;

//--------------------------------------------------------------
// ���������
//--------------------------------------------------------------
texture ColorMap:TEXTURE0;
sampler ColorMapSampler = sampler_state
{
   Texture = <ColorMap>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;   
};
texture BumpMap:TEXTURE1;
sampler BumpMapSampler = sampler_state
{
   Texture = <BumpMap>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;   
};
//----------------------------------------------------------
// ������Ⱦ�����������ṹ
//----------------------------------------------------------
struct VS_INPUT
{
    float4  Pos           : POSITION;
    float4  BlendWeights  : BLENDWEIGHT;
    float4  BlendIndices  : BLENDINDICES;
    float3  Normal        : NORMAL;
    float3  Tex           : TEXCOORD0;
    float3  Tangent 		  : TANGENT;
};

struct VS_OUTPUT
{
    float4  Pos     : POSITION;
    float2  Tex     : TEXCOORD0;
    float3  Light		: TEXCOORD1;   //����ռ��еƹⷽ��
    float3  View 		: TEXCOORD2;   //����ռ��з��߷���
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

//---------------------------------------------------------
// �Ӻ���, ��ɶ��㴦��
//---------------------------------------------------------
VS_OUTPUT VShade(VS_INPUT i, uniform int NumBones)
{
    VS_OUTPUT   o = (VS_OUTPUT)0;
    float3      Pos = 0.0f;
    float3      Normal = 0.0f;
    float3      Tangent = 0.0f;
    float       LastWeight = 0.0f;
   
   //-------------------------------------------------------------------------
     
    //ΪGeforce3���͵��Կ������Ĳ���
    int4 IndexVector = D3DCOLORtoUBYTE4(i.BlendIndices);
    
    //������Ȩ�������͹������������任������
    float BlendWeightsArray[4] = (float[4])i.BlendWeights;
    int IndexArray[4]        = (int[4])IndexVector;

    //����ǰNumBones-1���������ڸö���λ�ü���������Ӱ��
    for (int iBone = 0; iBone < NumBones-1; iBone++)
    {
        LastWeight = LastWeight + BlendWeightsArray[iBone];
        
        Pos += mul(i.Pos, mWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
        Normal += mul(i.Normal, mWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
        Tangent += mul(i.Tangent, mWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
    }
    LastWeight = 1.0f - LastWeight; 

    //�������һ���������ڶ���λ�ü���������Ӱ��
    Pos += (mul(i.Pos, mWorldMatrixArray[IndexArray[NumBones-1]]) * LastWeight);
    Normal += (mul(i.Normal, mWorldMatrixArray[IndexArray[NumBones-1]]) * LastWeight); 
    Tangent += (mul(i.Tangent, mWorldMatrixArray[IndexArray[NumBones-1]]) * LastWeight);
    
    o.Pos = mul(float4(Pos.xyz, 1.0f), mWorldViewProj);
    Normal = normalize(Normal);
    Tangent = normalize(Tangent);
    
    //-------------------------------------------------------------------------
    
    //����һ��3x3�任����  ������ɴ�����ռ䵽����ռ�ı任
   float3x3 worldToTangentSpace;
   worldToTangentSpace[0] = mul(Tangent, matWorld);
   worldToTangentSpace[1] = mul(cross(Tangent,Normal), matWorld);
   worldToTangentSpace[2] = mul(Normal, matWorld);

    //�����������
    o.Tex  = i.Tex.xy;
    //����������ռ��е�����
   float3 PosWorld = normalize(mul(Pos, matWorld));
   
   //��������ռ��еƹⷽ������
   float3 Light  = vecLightDir - PosWorld; 
   o.Light.xyz = mul(worldToTangentSpace, Light);

   //��������ռ��еĹ۲췽��
   float3 Viewer = vecEye - PosWorld;						
   o.View = mul(worldToTangentSpace, Viewer);
    
    return o;
}

//--------------------------------------------------------------
// Desc: ������Ⱦ��������
//--------------------------------------------------------------
PS_OUTPUT PShade(float2 Tex: TEXCOORD0, float3 Light : TEXCOORD1, 
            float3 View : TEXCOORD2, float3 Att : TEXCOORD3)
{
    PS_OUTPUT Out_ps = (PS_OUTPUT)0;
    
    //��ɫ�������
    float4 color      = tex2D(ColorMapSampler, Tex);
    //��͹�������, �õ����Ƿ�������, ���ڴ��涥�㷨�߽��й��ռ���
    float3 bumpNormal = 2 * (tex2D(BumpMapSampler, Tex) - 0.5);
	
	//��׼������ռ��еĵƹⷽ��͹۲췽��
    float3 LightDir = normalize(Light);
    float3 ViewDir  = normalize(View);
    
    //���ݰ�͹��ͼ�ķ��߽�����������ռ���
    float4 diff = saturate(dot(bumpNormal, LightDir));
    
    //���������ڱ���Ӱ��
    float shadow = saturate(4 * diff);
    
    //���㾵�淴��ǿ��
    float3 Reflect = normalize(2 * diff * bumpNormal - LightDir);
    float4 spec    = min(pow(saturate(dot(Reflect, ViewDir)), 100), color.a);

    //���������ɫ�͹�����ɫ, �õ�ÿ�����ص�������ɫ
    Out_ps.Color = 0.2 * color + (shadow * (color * diff + spec));
    
    return Out_ps;
}

//---------------------------------------------------------
// ������Ⱦ��
//---------------------------------------------------------
VertexShader vsArray[4] = {
                            compile vs_2_0 VShade(1), 
                            compile vs_2_0 VShade(2),
                            compile vs_2_0 VShade(3),
                            compile vs_2_0 VShade(4)
                          };


//---------------------------------------------------------
// ������ͨ��
//---------------------------------------------------------
technique t0
{
    pass p0
    {
        VertexShader = (vsArray[CurNumBones]);
        PixelShader = compile ps_2_0 PShade();
    }
}

