//==============================================================
// Desc: Ч���ļ�
//==============================================================

//--------------------------------------------------------------
// ȫ�ֱ���
//--------------------------------------------------------------
float4x4 matWorldViewProj : WORLDVIEWPROJECTION;	
float4x4 matWorld : WORLD;	
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
    float2 Tex  : TEXCOORD0;
    float3 Light: TEXCOORD1;   //����ռ��еƹⷽ��
    float3 View : TEXCOORD2;   //����ռ��з��߷���
};


//--------------------------------------------------------------
//  ������Ⱦ��������
//--------------------------------------------------------------
VS_OUTPUT VS(float4 Pos : POSITION, float2 Tex : TEXCOORD, float3 Normal : NORMAL, float3 Tangent : TANGENT  )
{
   VS_OUTPUT Out = (VS_OUTPUT)0;
   
   //��������任
   Out.Pos = mul(Pos, matWorldViewProj);
  
   //����һ��3x3�任����  ������ɴ�����ռ䵽����ռ�ı任
   float3x3 worldToTangentSpace;
   worldToTangentSpace[0] = mul(Tangent, matWorld);
   worldToTangentSpace[1] = mul(cross(Tangent,Normal), matWorld);
   worldToTangentSpace[2] = mul(Normal, matWorld);

   Out.Tex = Tex.xy;
   
   //����������ռ��е�����
   float3 PosWorld = normalize(mul(Pos, matWorld));

   //��������ռ��еƹⷽ������
   float3 Light  = vecLightDir - PosWorld; 
   Out.Light.xyz = mul(worldToTangentSpace, Light);

   //��������ռ��еĹ۲췽��
   float3 Viewer = vecEye - PosWorld;						
   Out.View = mul(worldToTangentSpace, Viewer);
      
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
    float4 spec    = min(pow(saturate(dot(Reflect, ViewDir)), 25), color.a);

    //���������ɫ�͹�����ɫ, �õ�ÿ�����ص�������ɫ
    Out_ps.Color = /*float4(1.0f, 0.5f, 0.5f, 0.5f);*/0.2 * color + (shadow * (color * diff + spec) );
    
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

