//==============================================================
// Desc: Ч�������ļ�
//==============================================================


//--------------------------------------------------------------
// ȫ�ֱ���
//--------------------------------------------------------------
float4x4  matWorldViewProj : WORLDVIEWPROJECTION;	  //��ϱ任����


//--------------------------------------------------------------
// ���������
//--------------------------------------------------------------
texture TextureMapping : TEXTURE0;
sampler2D Sampler2D = sampler_state
{
    Texture   = <TextureMapping>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};


//--------------------------------------------------------------
// ����ṹ
//--------------------------------------------------------------
struct VS_OUTPUT
{
    float4 Position   : POSITION;
    float2 TextureUV  : TEXCOORD0;  //��������  
};

struct PS_OUTPUT
{
    float4 RGBColor : COLOR0;       //������ɫ
};


//-----------------------------------------------------------------
// ������Ⱦ��������
//-----------------------------------------------------------------
VS_OUTPUT VS(float4 Pos : POSITION, float2 vTexCoord0 : TEXCOORD0)
{
    //����λ��
    VS_OUTPUT Out = (VS_OUTPUT)0;      
    Out.Position = mul(Pos, matWorldViewProj);	//����任
   
    //����
    Out.TextureUV = vTexCoord0; 
    return Out;
}


//--------------------------------------------------------------
// ������Ⱦ��������
//--------------------------------------------------------------
PS_OUTPUT PS( VS_OUTPUT In)
{ 
    PS_OUTPUT Output = (PS_OUTPUT)0;
    Output.RGBColor  = tex2D(Sampler2D, In.TextureUV);
    
    return Output;
}


//--------------------------------------------------------------
//  ����
//--------------------------------------------------------------
technique TShader
{
    pass P0
    {
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}