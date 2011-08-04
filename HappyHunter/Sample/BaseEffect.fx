//==============================================================
// Desc: Ч���ļ�
//==============================================================

//--------------------------------------------------------------
// ȫ�ֱ���
//--------------------------------------------------------------
float4x4 matWorldViewProj : WORLDVIEWPROJECTION;	

float4 g_Color : MATERIALAMBIENT;

//--------------------------------------------------------------
// ���������
//--------------------------------------------------------------
texture ColorMap : TEXTURE0;
sampler ColorMapSampler = sampler_state
{
   Texture = <ColorMap>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;   
};

texture BumpMap : TEXTURE1;
sampler BumpMapSampler = sampler_state
{
   Texture = <BumpMap>;
   MinFilter = Linear;
   MagFilter = Linear;
   MipFilter = Linear;   
};

//--------------------------------------------------------------
// ������Ⱦ������ṹ
//--------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Pos  : POSITION;
};


//--------------------------------------------------------------
//  ������Ⱦ��������
//--------------------------------------------------------------
VS_OUTPUT VS(float4 Pos : POSITION, float2 Tex : TEXCOORD, float3 Normal : NORMAL, float3 Tangent : TANGENT  )
{
   VS_OUTPUT Out = (VS_OUTPUT)0;
   
   //��������任
   Out.Pos = mul(Pos, matWorldViewProj);
      
   return Out;
}


//--------------------------------------------------------------
//������Ⱦ������ṹ
//--------------------------------------------------------------
struct PS_OUTPUT
{
    float4 Color  : COLOR;
};

//--------------------------------------------------------------
// Desc: ������Ⱦ��������
//--------------------------------------------------------------
PS_OUTPUT PS(float2 Tex: TEXCOORD0, float3 Light : TEXCOORD1, 
            float3 View : TEXCOORD2, float3 Att : TEXCOORD3)
{
    PS_OUTPUT Out_ps = (PS_OUTPUT)0;
    
    //��ɫ�������
    Out_ps.Color      = g_Color;//float4(1.0f, 0.0f, 0.0f, 1.0f);
    
    return Out_ps;
}


//--------------------------------------------------------------
// Desc: ����
//--------------------------------------------------------------
technique TShader
{
    pass P0
    {
		//FILLMODE = WIREFRAME;
		//CULLMODE = NONE;
		
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}

