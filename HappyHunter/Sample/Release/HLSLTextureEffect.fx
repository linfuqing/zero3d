//==============================================================
// Desc: Ч���ļ�
//==============================================================

//--------------------------------------------------------------
// ȫ�ֱ���
//--------------------------------------------------------------
float4x4 matWorldViewProj : WORLDVIEWPROJECTION;	
float4x4 matWorld : WORLD;	
float4x4 matViewProj:VIEWPROJECTION;
float4   vecLightDir : LIGHTDIRECTION;
float4   vecEye : CAMERAPOSITION;

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

//--------------------------------------------------------------
// ������Ⱦ������ṹ
//--------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Pos    : POSITION;
    float2 Tex    : TEXCOORD0;
    float3 Light  : TEXCOORD1;   //����ռ��еƹⷽ��
    float3 View   : TEXCOORD2;   //����ռ��з��߷���
    float3 Normal : TEXCOORD3; 
};


//--------------------------------------------------------------
//  ������Ⱦ��������
//--------------------------------------------------------------
VS_OUTPUT VS(float4 Pos : POSITION, float2 Tex : TEXCOORD, float3 Normal : NORMAL, float3 Tangent : TANGENT  )
{
   VS_OUTPUT Out = (VS_OUTPUT)0;
   
   //��������任
   Out.Pos = mul(Pos, matWorldViewProj);
  
   Out.Normal = mul(Normal, matWorldViewProj);

   Out.Tex = Tex.xy;
   
   //����������ռ��е�����
   float3 PosWorld = normalize(mul(Pos, matWorld));

   float3 Light  = vecLightDir - PosWorld; 
   Out.Light.xyz = mul(matViewProj, Light);

   float3 Viewer = vecEye - PosWorld;						
   Out.View = mul(matViewProj, Viewer);
      
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
            float3 View : TEXCOORD2, float3 Normal : TEXCOORD3)
{
    PS_OUTPUT Out_ps = (PS_OUTPUT)0;
    
    //��ɫ�������
    float4 color      = tex2D(ColorMapSampler, Tex);
	
	//��׼������ռ��еĵƹⷽ��͹۲췽��
    float3 LightDir = normalize(Light);
    float3 ViewDir  = normalize(View);
    
    //���ݰ�͹��ͼ�ķ��߽�����������ռ���
    float4 diff = saturate(dot(Normal, LightDir));
    
    //���������ڱ���Ӱ��
    float shadow = saturate(4 * diff);
    
    //���㾵�淴��ǿ��
    float3 Reflect = normalize(2 * diff * Normal - LightDir);
    float4 spec    = min(pow(saturate(dot(Reflect, ViewDir)), 25), color.a);

    //���������ɫ�͹�����ɫ, �õ�ÿ�����ص�������ɫ
    Out_ps.Color = 0.2 * color + (shadow * (color * diff + spec) );
    
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

