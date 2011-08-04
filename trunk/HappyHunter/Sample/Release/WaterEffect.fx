//==============================================================
// Desc: 效果代码文件
//==============================================================


//--------------------------------------------------------------
// 全局变量
//--------------------------------------------------------------
float4x4 WorldViewProj : WORLDVIEWPROJECTION;
float4x4 ModelViewProj : VIEWPROJECTION;	  //组合变换矩阵
float4x4 World : WORLD;
float4 vCameraPos : CAMERAPOSITION;
float time : TIME;//ELAPSEDTIME;

//--------------------------------------------------------------
// 纹理采样器
//--------------------------------------------------------------
texture ReflactionMapping : TEXTURE0;
sampler2D tex2 = sampler_state
{
    Texture   = <ReflactionMapping>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture RefractionMapping : TEXTURE1;
sampler2D tex1 = sampler_state
{
    Texture   = <RefractionMapping>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture BumpMapping : TEXTURE2;
sampler2D tex0 = sampler_state
{
    Texture   = <BumpMapping>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};


//--------------------------------------------------------------
// 输出结构
//--------------------------------------------------------------
struct VpIn
{
    float3 Pos       : POSITION;
    float2 TexCoord0 : TEXCOORD0;      
    float3 Normal    : NORMAL;  
    float3 Tangent   : TANGENT; 
};

// define outputs from vertex shader
struct VpOut
{
    float4 HPos       : POSITION;    
    float4 Eye        : TEXCOORD0;
    float4 Wave0      : TEXCOORD1;
    float2 Wave1      : TEXCOORD2;
    float2 Wave2      : TEXCOORD3;
    float2 Wave3      : TEXCOORD4;        
    float4 ScreenPos  : TEXCOORD5;            
};

float3x3 GetTangentSpaceBasis(float3 T, float3 N)
{
   float3x3 objToTangentSpace;
   
   objToTangentSpace[0]=N;           // tangent
   objToTangentSpace[1]=cross(T, N); // binormal
   objToTangentSpace[2]=T;           // normal  
   
   return objToTangentSpace;
}

//-----------------------------------------------------------------
// 顶点渲染器主函数
//-----------------------------------------------------------------
VpOut VS(VpIn IN)
{
    VpOut OUT = (VpOut)0;
    
    float4 vPos= mul(float4(IN.Pos, 1), World);
    OUT.HPos = mul(vPos, ModelViewProj);
    
    float2 fTranslation=float2(fmod(time, 100)*0.01, 0);
    float2 vTexCoords=vPos.xz*0.001;
    
    // Output bump layers texture coordinates    
    float fSinTranslation=sin(fTranslation*100)*0.005;
    float2 vTranslation0=fTranslation+fSinTranslation;
    float2 vTranslation1=fTranslation-fSinTranslation;
    float2 vTranslation2=fTranslation;
    
    // Scale texture coordinates to get mix of low/high frequency details
    OUT.Wave0.xy = vTexCoords.xy+fTranslation*2.0;
    OUT.Wave1.xy = vTexCoords.xy*2.0+fTranslation*4.0;
    OUT.Wave2.xy = vTexCoords.xy*4.0+fTranslation*2.0;
    OUT.Wave3.xy = vTexCoords.xy*8.0+fTranslation;              
                  
    // perspective corrected projection      
    float4 vHPos = mul(vPos, ModelViewProj);         	
    OUT.Wave0.zw=vHPos.w;
    		  
	  vHPos.y = -vHPos.y;
    OUT.ScreenPos.xy = (vHPos.xy + vHPos.w)*0.5;    
    OUT.ScreenPos.zw =  float2(1, vHPos.w);      
        
    // get tangent space basis    
    //float3x3 objToTangentSpace=GetTangentSpaceBasis(IN.Tangent.xyz, IN.Normal.xyz);
    float3x3 worldToTangentSpace;
	worldToTangentSpace[0] = mul(IN.Tangent, WorldViewProj);
	worldToTangentSpace[1] = mul(cross(IN.Tangent, IN.Normal), WorldViewProj);
	worldToTangentSpace[2] = mul(IN.Normal, WorldViewProj);
            
    float3 EyeVec=vCameraPos.xyz-vPos;        
    OUT.Eye.xyz = mul(worldToTangentSpace, EyeVec);
                                                 
    return OUT;
}

// This assumes NdotL comes clamped
float Fresnel(float NdotL, float fresnelBias, float fresnelPow)
{
	float facing = (1.0 - NdotL);
	return  max(fresnelBias + (1.0-fresnelBias)*pow(facing, fresnelPow), 0.0);
}

struct FpOut
{
    half4 Color : COLOR0;           
};

//--------------------------------------------------------------
// 像素渲染器主函数
//--------------------------------------------------------------
FpOut PS(float3 Eye : TEXCOORD0,
           float4 Wave0 : TEXCOORD1, float2 Wave1 : TEXCOORD2,
           float2 Wave2 : TEXCOORD3, float2 Wave3 : TEXCOORD4,
           float4 ScreenPos : TEXCOORD5)
{ 
	FpOut OUT = (FpOut)0;
	
	half3 vEye = normalize(Eye);

	// Get bump layers
	half3 vBumpTexA = tex2D(tex0, Wave0.xy).xyz;
	half3 vBumpTexB = tex2D(tex0, Wave1.xy).xyz;
	half3 vBumpTexC = tex2D(tex0, Wave2.xy).xyz;
	half3 vBumpTexD = tex2D(tex0, Wave3.xy).xyz;

	// Average bump layers
	half3 vBumpTex=normalize(2 * (vBumpTexA.xyz + vBumpTexB.xyz + vBumpTexC.xyz + vBumpTexD.xyz)-4.0);

	// Apply individual bump scale for refraction and reflection
	half3 vRefrBump = vBumpTex.xyz * half3(0.02, 0.02, 1.0);
	half3 vReflBump = vBumpTex.xyz * half3(0.1, 0.1, 1.0);  
	 
	// Compute projected coordinates
	half2 vProj = (ScreenPos.xy/ScreenPos.w);
	half4 vReflection = tex2D(tex2, vProj.xy+ vReflBump.xy);
	half4 vRefrA = tex2D(tex1, vProj.xy + vRefrBump.xy);
	half4 vRefrB = tex2D(tex1, vProj.xy);

	// Mask occluders from refraction map
	half4 vRefraction = vRefrB * vRefrA.w + vRefrA * (1 - vRefrA.w);

	// Compute Fresnel term
	half NdotL = max(dot(vEye, vReflBump), 0);
	half facing = (1.0 - NdotL);
	half fresnel = Fresnel(NdotL, 0.2, 5.0);

	// Use distance to lerp between refraction and deep water color
	half fDistScale = saturate(10.0/Wave0.w);
	half3 WaterDeepColor = (vRefraction.xyz * fDistScale + (1 - fDistScale) * half3(0, 0.1, 0.125));  

	// Lerp between water color and deep water color
	half3 WaterColor = half3(0, 0.1, 0.15);
	half3 waterColor = (WaterColor * facing + WaterDeepColor * (1.0 - facing));
	half3 cReflect = fresnel * vReflection;

	// final water = reflection_color * fresnel + water_color
	OUT.Color = half4(cReflect + waterColor, 1);  
	
	return OUT; 
}


//--------------------------------------------------------------
//  技术
//--------------------------------------------------------------
technique TShader
{
    pass P0
    {
		//CULLMODE = NONE;
		
        VertexShader = compile vs_2_0 VS();
        PixelShader  = compile ps_2_0 PS();
    }
}
