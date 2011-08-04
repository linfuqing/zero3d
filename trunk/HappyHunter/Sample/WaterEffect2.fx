//==============================================================
// Desc: 效果代码文件
//==============================================================


//--------------------------------------------------------------
// 全局变量
//--------------------------------------------------------------
float4x4  matWorldViewProj : WORLDVIEWPROJECTION;	  //组合变换矩阵
float4 vecEye : CAMERAPOSITION;
float time : TIME;//ELAPSEDTIME;

//--------------------------------------------------------------
// 纹理采样器
//--------------------------------------------------------------
texture TextureMapping : TEXTURE0;
sampler2D Sampler2D = sampler_state
{
    Texture   = <TextureMapping>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture RefractionMapping : TEXTURE1;
sampler2D RefractionMap = sampler_state
{
    Texture   = <RefractionMapping>;
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture BumpMapping : TEXTURE2;
sampler2D BumpMap = sampler_state
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
struct VS_OUTPUT
{
    float4 Position   : POSITION;
    float4 TextureUV  : TEXCOORD0;  //纹理坐标  
    float3 Eye        : TEXCOORD1;
    
    float4 Wave0      : TEXCOORD2;
    float2 Wave1      : TEXCOORD3;
    float2 Wave2      : TEXCOORD4;
    float2 Wave3      : TEXCOORD5;
};

struct PS_OUTPUT
{
    float4 RGBColor : COLOR0;       //像素颜色
};

float3x3 GetTangentSpaceBasis(float3 T, float3 N)
{
   float3x3 objToTangentSpace;
   
   objToTangentSpace[0]=T;           // tangent
   objToTangentSpace[1]=cross(T, N); // binormal
   objToTangentSpace[2]=N;           // normal  
   
   return objToTangentSpace;
}

//-----------------------------------------------------------------
// 顶点渲染器主函数
//-----------------------------------------------------------------
VS_OUTPUT VS(float3 Pos : POSITION, float2 UV : TEXCOORD, float3 Nor : NORMAL, float3 Tan: TANGENT)
{
    //顶点位置
    VS_OUTPUT Out = (VS_OUTPUT)0;   
    float4 Position = float4(Pos.xyz, 1.0);
       
    Out.Position = mul(Position, matWorldViewProj);	//坐标变换
   
    //纹理
    Out.TextureUV.xyw = Out.Position.xyw;
    Out.TextureUV.y   = - Out.TextureUV.y;
    Out.TextureUV.xy  = (Out.TextureUV.xy + Out.TextureUV.w) * 0.5;
    Out.TextureUV.z   = 0;
    //Out.TextureUV.xy = Out.Position.xy;
    
    float2 fTranslation=float2(fmod(time, 100000)*0.01, 0);
    float2 vTexCoords=Pos.xy*0.001;
    
    // Output bump layers texture coordinates    
    float fSinTranslation=sin(fTranslation*100)*0.005;
    float2 vTranslation0=fTranslation+fSinTranslation;
    float2 vTranslation1=fTranslation-fSinTranslation;
    float2 vTranslation2=fTranslation;
    
    // Scale texture coordinates to get mix of low/high frequency details
    Out.Wave0.xy = vTexCoords.xy+fTranslation*2.0;
    Out.Wave1.xy = vTexCoords.xy*2.0+fTranslation*4.0;
    Out.Wave2.xy = vTexCoords.xy*4.0+fTranslation*2.0;
    Out.Wave3.xy = vTexCoords.xy*8.0+fTranslation;  
    
    Out.Wave0.zw=Out.Position.w;
    
    // get tangent space basis    
    float3x3 objToTangentSpace=GetTangentSpaceBasis(Tan.xyz, Nor.xyz);
            
    float3 EyeVec=vecEye.xyz-Pos;        
    Out.Eye.xyz = mul(EyeVec, objToTangentSpace);
    
    //Out.Eye = mul(vecEye, matWorldViewProj);
    
    return Out;
}

// This assumes NdotL comes clamped
float Fresnel(float NdotL, float fresnelBias, float fresnelPow)
{
	float facing = (1.0 - NdotL);
	return  max(fresnelBias + (1.0-fresnelBias)*pow(facing, fresnelPow), 0.0);
}

//--------------------------------------------------------------
// 像素渲染器主函数
//--------------------------------------------------------------
PS_OUTPUT PS( VS_OUTPUT In)
{ 
    PS_OUTPUT Output = (PS_OUTPUT)0;
    
    float2 uv = In.TextureUV.xy / In.TextureUV.w;
    
    float3 vEye = normalize(In.Eye);

	// Get bump layers
	float3 vBumpTexA = tex2D(BumpMap, In.Wave0.xy).xyz;
	float3 vBumpTexB = tex2D(BumpMap, In.Wave1.xy).xyz;
	float3 vBumpTexC = tex2D(BumpMap, In.Wave2.xy).xyz;
	float3 vBumpTexD = tex2D(BumpMap, In.Wave3.xy).xyz;

	// Average bump layers
	float3 vBumpTex=normalize(2.0 * (vBumpTexA.xyz + vBumpTexB.xyz + vBumpTexC.xyz + vBumpTexD.xyz)-4.0);

	// Apply individual bump scale for refraction and reflection
	float3 vRefrBump = vBumpTex.xyz * float3(0.02, 0.02, 1.0);
	float3 vReflBump = vBumpTex.xyz * float3(0.1, 0.1, 1.0);  
	 
	// Compute projected coordinates
	//float2 vProj = (ScreenPos.xy/ScreenPos.w);
	float4 vReflection = tex2D(Sampler2D, uv+ vReflBump.xy);
	float4 vRefrA = tex2D(RefractionMap, uv + vRefrBump.xy);
	float4 vRefrB = tex2D(RefractionMap, uv);

	// Mask occluders from refraction map
	float4 vRefraction = vRefrB * vRefrA.w + vRefrA * (1 - vRefrA.w);
	  
    //float4 vReflection = tex2D(Sampler2D, uv);
    //float4 vRefraction = tex2D(RefractionMap, uv);
    
     // Compute Fresnel term
	float NdotL = max(dot(In.Eye, vReflBump), 0);
	float facing = (1.0 - NdotL);
	float fresnel = Fresnel(NdotL, 0.2, 5.0);

	 // Use distance to lerp between refraction and deep water color
	float fDistScale = saturate(10.0/In.Wave0.w);
	float3 WaterDeepColor = (vRefraction.xyz * fDistScale + (1 - fDistScale) * float3(0, 0.1, 0.125));  
	  
	 // Lerp between water color and deep water color
	float3 WaterColor = float3(0, 0.1, 0.15);
	float3 waterColor = (WaterColor * facing + WaterDeepColor * (1.0 - facing));
	float3 cReflect = fresnel * vReflection;

	 // final water = reflection_color * fresnel + water_color
	//return float4(cReflect + waterColor, 1);  
    
    Output.RGBColor  = float4(cReflect + waterColor, 1);//tex2D(Sampler2D, uv);
    
    return Output;
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
