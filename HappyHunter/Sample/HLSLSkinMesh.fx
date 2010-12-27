//=========================================================
// Desc: Ч��Դ����
//=========================================================


//---------------------------------------------------------
// ȫ�ֱ���
//---------------------------------------------------------
float4 lightDir:LIGHTDIRECTION = {0.0f, 0.0f, -1.0f, 1.0f};
float4 lightDiffuse:LIGHTDIFFUSE = {0.6f, 0.6f, 0.6f, 1.0f}; 
float4 MaterialAmbient:MATERIALAMBIENT = {0.1f, 0.1f, 0.1f, 1.0f};
float4 MaterialDiffuse:MATERIALDIFFUSE = {0.8f, 0.8f, 0.8f, 1.0f};

static const int MAX_MATRICES = 26;
float4x3    mWorldMatrixArray[MAX_MATRICES];  //������ɫ����� 
int         CurNumBones = 2;    //��ǰ��������
float4x4    mProj;

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

//----------------------------------------------------------
// ������Ⱦ�����������ṹ
//----------------------------------------------------------
struct VS_INPUT
{
    float4  Pos           : POSITION;
    float4  BlendWeights  : BLENDWEIGHT;
    float4  BlendIndices  : BLENDINDICES;
    float3  Normal        : NORMAL;
    float3  Tex0          : TEXCOORD0;
};

struct VS_OUTPUT
{
    float4  Pos     : POSITION;
    float4  Diffuse : COLOR;
    float2  Tex0    : TEXCOORD0;
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
    CosTheta = max(0.0f, dot(Normal, lightDir.xyz));
    return (CosTheta);
}

//---------------------------------------------------------
// �Ӻ���, ��ɶ��㴦��
//---------------------------------------------------------
VS_OUTPUT VShade(VS_INPUT i, uniform int NumBones)
{
    VS_OUTPUT   o;
    float3      Pos = 0.0f;
    float3      Normal = 0.0f;
    float       sumWeight  = 0.0f;
    float       LastWeight = 0.0f;
     
    //ΪGeforce3���͵��Կ������Ĳ���
    int4 IndexVector = D3DCOLORtoUBYTE4(i.BlendIndices);
    
    //������Ȩ�������͹������������任������
    float BlendWeightsArray[4] = (float[4])i.BlendWeights;
    int   IndexArray[4]        = (int[4])IndexVector;

    //����ǰNumBones-1���������ڸö���λ�ü���������Ӱ��
    for (int iBone = 0; iBone < NumBones-1; iBone++)
    {
        sumWeight = sumWeight + BlendWeightsArray[iBone];
        
        Pos += mul(i.Pos, mWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
        Normal += mul(i.Normal, mWorldMatrixArray[IndexArray[iBone]]) * BlendWeightsArray[iBone];
    }
    LastWeight = 1.0f - sumWeight; 

    //�������һ���������ڶ���λ�ü���������Ӱ��
    Pos += (mul(i.Pos, mWorldMatrixArray[IndexArray[NumBones-1]]) * LastWeight);
    Normal += (mul(i.Normal, mWorldMatrixArray[IndexArray[NumBones-1]]) * LastWeight); 
    
    o.Pos = mul(float4(Pos.xyz, 1.0f), mProj);
    Normal = normalize(Normal);

    //�������
    o.Diffuse.xyz = MaterialAmbient.xyz + Diffuse(Normal) * MaterialDiffuse.xyz;
    o.Diffuse.w = 1.0f;

    //�����������
    o.Tex0  = i.Tex0.xy;

    return o;
}

//--------------------------------------------------------------
// Desc: ������Ⱦ��������
//--------------------------------------------------------------
PS_OUTPUT PShade(float2 Tex: TEXCOORD0, float4 Diffuse : COLOR)
{
    PS_OUTPUT Out_ps = (PS_OUTPUT)0;
    
    //��ɫ�������
    float4 color      = tex2D(ColorMapSampler, Tex);

    //������ɫ
    Out_ps.Color = color * Diffuse;
    
    return Out_ps;
}

//---------------------------------------------------------
// ������Ⱦ��
//---------------------------------------------------------
VertexShader vsArray[4] = {
                            compile vs_1_1 VShade(1), 
                            compile vs_1_1 VShade(2),
                            compile vs_1_1 VShade(3),
                            compile vs_1_1 VShade(4)
                          };


//---------------------------------------------------------
// ������ͨ��
//---------------------------------------------------------
technique t0
{
    pass p0
    {
        VertexShader = (vsArray[CurNumBones]);
        PixelShader = compile ps_1_1 PShade();
    }
}

