#include "StdAfx.h"
#include "HDREffect.h"
#include "Gamehost.h"

float g_fExposure = 0.50f;    // The exposure bias fed into the FinalPass.psh shader (OnFrameRender )
float g_BrightThreshold = 1.0f;             // A configurable parameter into the pixel shader
float g_GaussMultiplier = 2.4f;             // Default multiplier
float g_GaussMean = 0.0f;             // Default mean for gaussian distribution
float g_GaussStdDev = 0.8f;             // Default standard deviation for gaussian distribution

using namespace zerO;
CHDREffect::CHDREffect(void) :
m_puTextureLuminance(NULL),
//m_pLumDispPS(NULL),
m_pAdaptedLumPS(NULL),
m_pAdaptedLumPSConsts(NULL),
m_pLum1PS(NULL),
m_pLum1PSConsts(NULL),
m_pLum3x3DSPS(NULL),
m_pLum3x3DSPSConsts(NULL),
m_pBrightPassPS(NULL),
m_pBrightPassConstants(NULL),
m_pDownSamplePS(NULL),
m_pDownSampleConstants(NULL),
m_pHBloomPS(NULL),
m_pHBloomConstants(NULL),
m_pVBloomPS(NULL),
m_pVBloomConstants(NULL),
m_pFinalPassPS(NULL),
m_pFinalPassPSConsts(NULL)
{
}

CHDREffect::~CHDREffect(void)
{
	Destroy();
}

bool CHDREffect::Create(zerO::UINT uNumLuminanceTextures)
{
	//m_uFinalTexture = pTexturePrinter->AddTexture();

	HRESULT hr;
	LPD3DXBUFFER pCode;

	hr = D3DXCompileShaderFromFile( TEXT("FinalPass.psh"),
                                         NULL, NULL,
                                         "main",
                                         "ps_2_0",
                                         0,
                                         &pCode,
                                         NULL,
                                         &m_pFinalPassPSConsts
                                         );

	if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

    hr = DEVICE.CreatePixelShader(reinterpret_cast< DWORD* >( pCode->GetBufferPointer() ), &m_pFinalPassPS);

	pCode->Release();

	if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

	return __CreatePostProcessing() && __CreateLuminance(uNumLuminanceTextures);
}

bool CHDREffect::Destroy()
{
	DEBUG_DELETE_ARRAY(m_puTextureLuminance);

	//DEBUG_RELEASE(m_pLumDispPS);

	DEBUG_RELEASE(m_pAdaptedLumPS);
	DEBUG_RELEASE(m_pAdaptedLumPSConsts);

	DEBUG_RELEASE(m_pLum1PS);
	DEBUG_RELEASE(m_pLum1PSConsts);

	DEBUG_RELEASE(m_pLum3x3DSPS);
	DEBUG_RELEASE(m_pLum3x3DSPSConsts);

	DEBUG_RELEASE(m_pBrightPassPS);
	DEBUG_RELEASE(m_pBrightPassConstants);

	DEBUG_RELEASE(m_pDownSamplePS); 
	DEBUG_RELEASE(m_pDownSampleConstants);

	DEBUG_RELEASE(m_pHBloomPS); 
	DEBUG_RELEASE(m_pHBloomConstants);

	DEBUG_RELEASE(m_pVBloomPS);
	DEBUG_RELEASE(m_pVBloomConstants);

	DEBUG_RELEASE(m_pFinalPassPS);
	DEBUG_RELEASE(m_pFinalPassPSConsts);

	m_puTextureLuminance   = NULL;

	//m_pLumDispPS         = NULL;
	m_pAdaptedLumPS        = NULL;
	m_pAdaptedLumPSConsts  = NULL;

	m_pLum1PS              = NULL;
	m_pLum1PSConsts        = NULL;

	m_pLum3x3DSPS          = NULL;
	m_pLum3x3DSPSConsts    = NULL;

	m_pBrightPassPS        = NULL;
	m_pBrightPassConstants = NULL;

	m_pDownSamplePS        = NULL;
	m_pDownSampleConstants = NULL;

	m_pHBloomPS            = NULL;
	m_pHBloomConstants     = NULL;

	m_pVBloomPS            = NULL;
	m_pVBloomConstants     = NULL;

	m_pFinalPassPS         = NULL;
	m_pFinalPassPSConsts   = NULL;

	return true;
}

void CHDREffect::Render(CTexturePrinter &TexturePrinter)
{
	TexturePrinter.Begin();
	
	__MeasureLuminance(TexturePrinter);

	__PerformPostProcessing();

	TexturePrinter.End();

	CTexturePrinter* pTexturePrinter = &TexturePrinter;

	CTexturePrinter::LPTEXTURE pHDRTexture       = pTexturePrinter->GetTextureInfo(0);
	CTexturePrinter::LPTEXTURE pLuminanceTexture = pTexturePrinter->GetTextureInfo(m_uCurrentLuminanceTexture);
	CTexturePrinter::LPTEXTURE pBloomTexture     = pTexturePrinter->GetTextureInfo(m_uBloomVertical);

    DEVICE.SetTexture( 0, pHDRTexture->Texture.GetTexture() );
    DEVICE.SetTexture( 1, pLuminanceTexture->Texture.GetTexture() );
    DEVICE.SetTexture( 2, pBloomTexture->Texture.GetTexture() );

    m_pFinalPassPSConsts->SetFloat( &DEVICE, "g_rcp_bloom_tex_w", 1.0f / static_cast< float >(pBloomTexture->Desc.Width ) );
    m_pFinalPassPSConsts->SetFloat( &DEVICE, "g_rcp_bloom_tex_h", 1.0f / static_cast< float >(pBloomTexture->Desc.Height) );
    m_pFinalPassPSConsts->SetFloat( &DEVICE, "fExposure", g_fExposure );
    m_pFinalPassPSConsts->SetFloat( &DEVICE, "fGaussianScalar", g_GaussMultiplier );

	DEVICE.SetPixelShader(m_pFinalPassPS);

	//DEVICE.SetTexture( 0, TexturePrinter.GetTexture(m_uBrightPassTexture/*m_puTextureLuminance[0]*/)->GetTexture() );

	FLOAT fWidth  = (FLOAT)GAMEHOST.GetBackBufferSurfaceDesc().Width  - 0.5f;
	FLOAT fHeight = (FLOAT)GAMEHOST.GetBackBufferSurfaceDesc().Height - 0.5f;

    VERTEX Vertices[4];

    Vertices[0].Position = D3DXVECTOR4(- 0.5f, - 0.5f, 0.0f, 1.0f);
    Vertices[0].UV       = D3DXVECTOR2(0.0f, 0.0f);

    Vertices[1].Position = D3DXVECTOR4(fWidth, - 0.5f, 0.0f, 1.0f);
    Vertices[1].UV       = D3DXVECTOR2(1.0f, 0.0f);

    Vertices[2].Position = D3DXVECTOR4(- 0.5f, fHeight, 0.0f, 1.0f);
    Vertices[2].UV       = D3DXVECTOR2(0.0f, 1.0f);

    Vertices[3].Position = D3DXVECTOR4(fWidth, fHeight, 0.0f, 1.0f);
    Vertices[3].UV       = D3DXVECTOR2(1.0f, 1.0f);

	DEVICE.SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
    DEVICE.SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);

    DEVICE.SetSamplerState(1, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
    DEVICE.SetSamplerState(1, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);

    DEVICE.SetSamplerState(2, D3DSAMP_ADDRESSU, D3DTADDRESS_CLAMP);
    DEVICE.SetSamplerState(2, D3DSAMP_ADDRESSV, D3DTADDRESS_CLAMP);

    //DEVICE.SetVertexShader(NULL);
    DEVICE.SetFVF(D3DFVF_XYZRHW | D3DFVF_TEX1);
    DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLESTRIP, 2, Vertices, sizeof(VERTEX) );

	DEVICE.SetPixelShader(NULL);

    DEVICE.SetTexture(2, NULL);
    DEVICE.SetTexture(1, NULL);
    DEVICE.SetTexture(0, NULL);
}

bool CHDREffect::__CreateLuminance(zerO::UINT uNumLuminanceTextures)
{
	CTexturePrinter* pTexturePrinter = GAMEHOST.GetTexturePrinter();
	if(!pTexturePrinter)
		return false;

	HRESULT hr;
	LPD3DXBUFFER pCode;

	D3DFORMAT LuminanceFormat;
	if( !__FindBestLuminanceFormat( &LuminanceFormat ) )
	{
		DEBUG_WARNING("Current hardware does not support HDR rendering!");

		return false;
	}

	/*D3DSURFACE_DESC Desc = GAMEHOST.GetBackBufferSurfaceDesc();
	UINT uTextureSize = 1, i;

	for(i = 0; i < uNumLuminanceTextures; i ++)
	{
        uTextureSize *= 3;

		if(uTextureSize > Desc.Width || uTextureSize > Desc.Height)
			break;
	}

	m_uNumLuminanceTextures = i;*/

	m_uNumLuminanceTextures    = uNumLuminanceTextures;

	m_uCurrentLuminanceTexture = pTexturePrinter->AddTexture(1, 1, LuminanceFormat);
	m_uLastLuminanceTexture    = pTexturePrinter->AddTexture(1, 1, LuminanceFormat);

	DEBUG_NEW(m_puTextureLuminance, UINT[m_uNumLuminanceTextures]);

	UINT uTextureSize = 1, i;
    for(i = 0; i < m_uNumLuminanceTextures; i ++)
    {
		m_puTextureLuminance[i] = pTexturePrinter->AddTexture(uTextureSize, uTextureSize, LuminanceFormat);

        uTextureSize *= 3;
    }

	//CREATE GUI DISPLAY SHADER
    //-------------------------------
   /* hr = D3DXCompileShaderFromFile(
       TEXT("Luminance.psh"),
       NULL, NULL,
       "LuminanceDisplay",
       "ps_2_0",
       0,
       &pCode,
       NULL,
       NULL
       );
    if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

    hr = DEVICE.CreatePixelShader( reinterpret_cast< DWORD* >( pCode->GetBufferPointer() ),
                                   &m_pLumDispPS );

	pCode->Release();
    if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }*/

	hr = D3DXCompileShaderFromFile(
       TEXT("Luminance.psh"),
       NULL, NULL,
       "CalculateAdaptedLumPS",
       "ps_2_0",
       0,
       &pCode,
       NULL,
       &m_pAdaptedLumPSConsts
       );
    if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

    hr = DEVICE.CreatePixelShader( reinterpret_cast< DWORD* >( pCode->GetBufferPointer() ), &m_pAdaptedLumPS );

	pCode->Release();

    if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

	hr = D3DXCompileShaderFromFile(
       TEXT("Luminance.psh"),
       NULL, NULL,
       "GreyScaleDownSample",
       "ps_2_0",
       0,
       &pCode,
       NULL,
       &m_pLum1PSConsts
       );
    if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

    hr = DEVICE.CreatePixelShader( reinterpret_cast< DWORD* >( pCode->GetBufferPointer() ), &m_pLum1PS );

	pCode->Release();

    if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

    hr = D3DXCompileShaderFromFile(
       TEXT("Luminance.psh"),
       NULL, NULL,
       "DownSample",
       "ps_2_0",
       0,
       &pCode,
       NULL,
       &m_pLum3x3DSPSConsts
       );

    if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

    hr = DEVICE.CreatePixelShader( reinterpret_cast< DWORD* >( pCode->GetBufferPointer() ),
                                   &m_pLum3x3DSPS );

	pCode->Release();

    if( FAILED( hr ) )
    {
        DEBUG_WARNING(hr);

        return false;
    }

	return true;
}

D3DFORMAT g_PostProcessFormat;

void ResetBrightPassTexture(
							zerO::UINT& uWidth, 
							zerO::UINT& uHeight, 
							D3DFORMAT & Format)
{
	uWidth     = GAMEHOST.GetBackBufferSurfaceDesc().Width  >> 1;
	uHeight    = GAMEHOST.GetBackBufferSurfaceDesc().Height >> 1;
	Format     = g_PostProcessFormat;
}

void ResetDownSampledTexture(
							 zerO::UINT& uWidth, 
							 zerO::UINT& uHeight, 
							 D3DFORMAT & Format)
{
	uWidth     = GAMEHOST.GetBackBufferSurfaceDesc().Width  >> 3;
	uHeight    = GAMEHOST.GetBackBufferSurfaceDesc().Height >> 3;
	Format     = g_PostProcessFormat;
}

bool CHDREffect::__CreatePostProcessing()
{
	CTexturePrinter* pTexturePrinter = GAMEHOST.GetTexturePrinter();
	if(!pTexturePrinter)
		return false;

    HRESULT hr = S_OK;
    LPD3DXBUFFER pCode = NULL;

    if( !__FindBestHDRFormat(&g_PostProcessFormat) )
    {
        DEBUG_WARNING("Current hardware does not allow HDR rendering!" );

        return false;
    }

	m_uBrightPassTexture = pTexturePrinter->AddTexture(ResetBrightPassTexture);

    hr = D3DXCompileShaderFromFile(
       TEXT("PostProcessing.psh"),
       NULL, NULL,
       "BrightPass",
       "ps_2_0",
       0,
       &pCode,
       NULL,
       &m_pBrightPassConstants
       );
    if( FAILED(hr) )
    {
        DEBUG_WARNING("Compiling of 'BrightPass' from 'PostProcessing.psh' failed!" );
        return false;
    }

    hr = DEVICE.CreatePixelShader( reinterpret_cast<DWORD*>( pCode->GetBufferPointer() ), &m_pBrightPassPS );

	pCode->Release();

    if( FAILED(hr) )
    {
        DEBUG_WARNING("Could not create a pixel shader object for 'BrightPass'." );
        return false;
    }

	m_uDownSampledTexture = pTexturePrinter->AddTexture(ResetDownSampledTexture);

    hr = D3DXCompileShaderFromFile(
       TEXT("PostProcessing.psh"),
       NULL, NULL,
       "DownSample",
       "ps_2_0",
       0,
       &pCode,
       NULL,
       &m_pDownSampleConstants
       );
    if( FAILED(hr) )
    {
        DEBUG_WARNING("Compiling of 'DownSample' from 'PostProcessing.psh' failed!");

        return false;
    }

    DEVICE.CreatePixelShader( reinterpret_cast< DWORD* >( pCode->GetBufferPointer() ), &m_pDownSamplePS );

	pCode->Release();

    if( FAILED(hr) )
    {
        DEBUG_WARNING("Could not create a pixel shader object for 'DownSample'.");

        return false;
    }

	m_uBloomHorizontal = pTexturePrinter->AddTexture(ResetDownSampledTexture);

    hr = D3DXCompileShaderFromFile(
       TEXT("PostProcessing.psh"),
       NULL, NULL,
       "HorizontalBlur",
       "ps_2_0",
       0,
       &pCode,
       NULL,
       &m_pHBloomConstants
       );
    if( FAILED(hr) )
    {
        DEBUG_WARNING("Compiling of 'HorizontalBlur' from 'PostProcessing.psh' failed!");

        return false;
    }

    hr = DEVICE.CreatePixelShader(reinterpret_cast< DWORD* >( pCode->GetBufferPointer() ), &m_pHBloomPS);

	pCode->Release();

    if( FAILED(hr) )
    {
        DEBUG_WARNING("Could not create a pixel shader object for 'HorizontalBlur'.");

        return false;
    }

    m_uBloomVertical = pTexturePrinter->AddTexture(ResetDownSampledTexture);

    hr = D3DXCompileShaderFromFile(
       TEXT("PostProcessing.psh"),
       NULL, NULL,
       "VerticalBlur",
       "ps_2_0",
       0,
       &pCode,
       NULL,
       &m_pVBloomConstants
       );
    if( FAILED(hr) )
    {
        DEBUG_WARNING("Compiling of 'VerticalBlur' from 'PostProcessing.psh' failed!" );

        return false;
    }

    hr = DEVICE.CreatePixelShader(reinterpret_cast< DWORD* >( pCode->GetBufferPointer() ), &m_pVBloomPS );

	pCode->Release();

    if( FAILED(hr) )
    {
        DEBUG_WARNING("Could not create a pixel shader object for 'VerticalBlur'." );

        return false;
    }

    return true;
}

void CHDREffect::__MeasureLuminance(CTexturePrinter &TexturePrinter)
{
	CTexturePrinter::LPTEXTURE pSourceTexture = TexturePrinter.GetTextureInfo(0);

    DEVICE.SetTexture( 0, pSourceTexture->Texture.GetTexture() );

    DEVICE.SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
    DEVICE.SetSamplerState(0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR);

    DEVICE.SetPixelShader(m_pLum1PS);

    D3DXVECTOR4 Offsets[4], DownSampleOffsets[9];

	zerO::FLOAT u = ( 1.0f / static_cast<FLOAT>(pSourceTexture->Desc.Width ) );
	zerO::FLOAT v = ( 1.0f / static_cast<FLOAT>(pSourceTexture->Desc.Height) );

    Offsets[0] = D3DXVECTOR4(- 0.5f * u,   0.5f * v, 0.0f, 0.0f);
    Offsets[1] = D3DXVECTOR4(  0.5f * u,   0.5f * v, 0.0f, 0.0f);
    Offsets[2] = D3DXVECTOR4(- 0.5f * u, - 0.5f * v, 0.0f, 0.0f);
    Offsets[3] = D3DXVECTOR4(  0.5f * u, - 0.5f * v, 0.0f, 0.0f);

    m_pLum1PSConsts->SetVectorArray(&DEVICE, "tcLumOffsets", Offsets, 4);

    TexturePrinter.Draw(m_puTextureLuminance[m_uNumLuminanceTextures - 1]);

	zerO::INT i, x, y, nIndex;
    for(i = m_uNumLuminanceTextures - 1; i > 0; i --)
    {
		pSourceTexture = TexturePrinter.GetTextureInfo(m_puTextureLuminance[i]);

        DEVICE.SetTexture( 0, pSourceTexture->Texture.GetTexture() );

        nIndex = 0;
        for(x = - 1; x < 2; x ++)
        {
            for(y = - 1; y < 2; y ++)
            {
                DownSampleOffsets[nIndex ++] = D3DXVECTOR4(
                    static_cast< float >( x ) / static_cast< float >(pSourceTexture->Desc.Width ),
                    static_cast< float >( y ) / static_cast< float >(pSourceTexture->Desc.Height),
                    0.0f,   //unused
                    0.0f    //unused
                    );
            }
        }

        DEVICE.SetPixelShader(m_pLum3x3DSPS);

        m_pLum3x3DSPSConsts->SetVectorArray(&DEVICE, "tcDSOffsets", DownSampleOffsets, 9);

        TexturePrinter.Draw(m_puTextureLuminance[i - 1]);
    }

	UINT uTemp;

	SWAP(m_uCurrentLuminanceTexture, m_uLastLuminanceTexture, uTemp);

    DEVICE.SetPixelShader(m_pAdaptedLumPS);
    m_pAdaptedLumPSConsts->SetFloat(&DEVICE, "g_fElapsedTime", ELAPSEDTIME);

    DEVICE.SetTexture( 0, TexturePrinter.GetTextureInfo(m_uLastLuminanceTexture)->Texture.GetTexture() );
    DEVICE.SetTexture( 1, TexturePrinter.GetTextureInfo(m_puTextureLuminance[0])->Texture.GetTexture() );
    DEVICE.SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_POINT );
    DEVICE.SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_POINT );
    DEVICE.SetSamplerState( 1, D3DSAMP_MAGFILTER, D3DTEXF_POINT );
    DEVICE.SetSamplerState( 1, D3DSAMP_MINFILTER, D3DTEXF_POINT );

	TexturePrinter.Draw(m_uCurrentLuminanceTexture);
}

void CHDREffect::__PerformPostProcessing()
{
	CTexturePrinter* pTexturePrinter = GAMEHOST.GetTexturePrinter();

	CTexturePrinter::LPTEXTURE pSourceTexture = pTexturePrinter->GetTextureInfo(0);

    DEVICE.SetTexture( 0, pSourceTexture->Texture.GetTexture() );
    DEVICE.SetPixelShader(m_pBrightPassPS);
    m_pBrightPassConstants->SetFloat(&DEVICE, "fBrightPassThreshold", g_BrightThreshold );

    D3DXVECTOR4 Offsets[4], DownSampleOffsets[16];

    FLOAT u = ( 1.0f / static_cast<FLOAT>(pSourceTexture->Desc.Width ) );
    FLOAT v = ( 1.0f / static_cast<FLOAT>(pSourceTexture->Desc.Height) );

    Offsets[0] = D3DXVECTOR4(- 0.5f * u,   0.5f * v, 0.0f, 0.0f);
    Offsets[1] = D3DXVECTOR4(  0.5f * u,   0.5f * v, 0.0f, 0.0f);
    Offsets[2] = D3DXVECTOR4(- 0.5f * u, - 0.5f * v, 0.0f, 0.0f);
    Offsets[3] = D3DXVECTOR4(  0.5f * u, - 0.5f * v, 0.0f, 0.0f);

    m_pBrightPassConstants->SetVectorArray(&DEVICE, "tcDownSampleOffsets", Offsets, 4);

    pTexturePrinter->Draw(m_uBrightPassTexture);

	pSourceTexture = pTexturePrinter->GetTextureInfo(m_uDownSampledTexture);

    DEVICE.SetTexture( 0, pTexturePrinter->GetTextureInfo(m_uBrightPassTexture)->Texture.GetTexture() );
	DEVICE.SetTexture( 1, pTexturePrinter->GetTextureInfo(m_uCurrentLuminanceTexture)->Texture.GetTexture() );
    DEVICE.SetPixelShader(m_pDownSamplePS);

	D3DSURFACE_DESC Desc = pSourceTexture->Desc;

    INT nIndex = 0, i, j;
    for(i = - 2; i < 2; i ++)
    {
        for(j = - 2; j < 2; j ++)
        {
            DownSampleOffsets[nIndex ++] = D3DXVECTOR4(
                ( static_cast<FLOAT>(i) + 0.5f ) * ( 1.0f / static_cast<FLOAT>(Desc.Width ) ),
                ( static_cast<FLOAT>(j) + 0.5f ) * ( 1.0f / static_cast<FLOAT>(Desc.Height) ),
                0.0f, // unused 
                0.0f  // unused
                );
        }
    }

    m_pDownSampleConstants->SetVectorArray(&DEVICE, "tcDownSampleOffsets", DownSampleOffsets, 16);

    pTexturePrinter->Draw(m_uDownSampledTexture);

    DEVICE.SetTexture( 0, pSourceTexture->Texture.GetTexture() );
    DEVICE.SetPixelShader(m_pHBloomPS);

    FLOAT HBloomWeights[9];
    FLOAT HBloomOffsets[9];

    for(i = 0; i < 9; i ++)
    {
        HBloomOffsets[i] = (static_cast<FLOAT>(i) - 4.0f) * ( 1.0f / static_cast<FLOAT>(Desc.Width) );

        FLOAT x = (static_cast<FLOAT>(i) - 4.0f) / 4.0f;

        HBloomWeights[i] = g_GaussMultiplier * __ComputeGaussianValue(x, g_GaussMean, g_GaussStdDev);
    }

    m_pHBloomConstants->SetFloatArray(&DEVICE, "HBloomWeights", HBloomWeights, 9);
    m_pHBloomConstants->SetFloatArray(&DEVICE, "HBloomOffsets", HBloomOffsets, 9);

    pTexturePrinter->Draw(m_uBloomHorizontal);

    DEVICE.SetTexture( 0, pTexturePrinter->GetTextureInfo(m_uBloomHorizontal)->Texture.GetTexture() );
    DEVICE.SetPixelShader(m_pVBloomPS);

    FLOAT VBloomWeights[9];
    FLOAT VBloomOffsets[9];

    for(i = 0; i < 9; i ++)
    {
        VBloomOffsets[i] = (static_cast<FLOAT>(i) - 4.0f) * ( 1.0f / static_cast< float >(Desc.Height) );

        FLOAT x = (static_cast<FLOAT>(i) - 4.0f) / 4.0f;

        VBloomWeights[i] = g_GaussMultiplier * __ComputeGaussianValue(x, g_GaussMean, g_GaussStdDev);
    }

    m_pVBloomConstants->SetFloatArray(&DEVICE, "VBloomWeights", VBloomWeights, 9);
    m_pVBloomConstants->SetFloatArray(&DEVICE, "VBloomOffsets", VBloomOffsets, 9);

    pTexturePrinter->Draw(m_uBloomVertical);
}

float CHDREffect::__ComputeGaussianValue( float x, float mean, float std_deviation )
{
    // The gaussian equation is defined as such:
    /*    
      -(x - mean)^2
      -------------
      1.0               2*std_dev^2
      f(x,mean,std_dev) = -------------------- * e^
      sqrt(2*pi*std_dev^2)
      
     */

    return ( 1.0f / sqrt( 2.0f * D3DX_PI * std_deviation * std_deviation ) )
        * expf( ( -( ( x - mean ) * ( x - mean ) ) ) / ( 2.0f * std_deviation * std_deviation ) );
}

bool CHDREffect::__FindBestHDRFormat(D3DFORMAT* pBestFormat)
{

    // Retrieve important information about the current configuration
	CGameHost::DEVICESETTINGS info = GAMEHOST.GetDeviceSettings();

    if( FAILED( DIRECT.CheckDeviceFormat( info.AdapterOrdinal, info.DeviceType,
                                                        info.AdapterFormat,
                                                        D3DUSAGE_QUERY_FILTER | D3DUSAGE_RENDERTARGET,
                                                        D3DRTYPE_TEXTURE, D3DFMT_A32B32G32R32F ) ) )
    {
        // We don't support 128 bit render targets with filtering. Check the next format.
        DEBUG_WARNING("Current device does *not* support single-precision floating point textures with filtering.");

        if( FAILED( DIRECT.CheckDeviceFormat( info.AdapterOrdinal, info.DeviceType,
                                                            info.AdapterFormat,
                                                            D3DUSAGE_QUERY_FILTER | D3DUSAGE_RENDERTARGET,
                                                            D3DRTYPE_TEXTURE, D3DFMT_A16B16G16R16F ) ) )
        {
            // We don't support 64 bit render targets with filtering. Check the next format.
            DEBUG_WARNING("Current device does *not* support half-precision floating point textures with filtering.");

            if( FAILED( DIRECT.CheckDeviceFormat( info.AdapterOrdinal, info.DeviceType,
                                                                info.AdapterFormat, D3DUSAGE_RENDERTARGET,
                                                                D3DRTYPE_TEXTURE, D3DFMT_A32B32G32R32F ) ) )
            {
                // We don't support 128 bit render targets. Check the next format.
                DEBUG_WARNING("Current device does *not* support single-precision floating point textures.");

                if( FAILED( DIRECT.CheckDeviceFormat( info.AdapterOrdinal, info.DeviceType,
                                                                    info.AdapterFormat, D3DUSAGE_RENDERTARGET,
                                                                    D3DRTYPE_TEXTURE, D3DFMT_A16B16G16R16F ) ) )
                {
                    // We don't support 64 bit render targets. This device is not compatable.
                    DEBUG_WARNING("Current device does *not* support half-precision floating point textures.\n");
                    DEBUG_WARNING("THE CURRENT HARDWARE DOES NOT SUPPORT HDR RENDERING!");

                    return false;
                }
                else
                {
                    // We have support for 64 bit render targets without filtering
                    DEBUG_WARNING("Best available format is 'half-precision without filtering'.");

                    if( NULL != pBestFormat ) 
						*pBestFormat = D3DFMT_A16B16G16R16F;
                }
            }
            else
            {
                // We have support for 128 bit render targets without filtering
                DEBUG_WARNING("Enumeration::FindBestHDRFormat() - Best available format is 'single-precision without filtering'.");

                if( NULL != pBestFormat ) 
					*pBestFormat = D3DFMT_A32B32G32R32F;
            }
        }
        else
        {
            // We have support for 64 bit render targets with filtering
            DEBUG_WARNING("Best available format is 'half-precision with filtering'.");
            if( NULL != pBestFormat ) 
				*pBestFormat = D3DFMT_A16B16G16R16F;
        }
    }
    else
    {
        // We have support for 128 bit render targets with filtering
        DEBUG_WARNING("Best available format is 'single-precision with filtering'.");
        if( NULL != pBestFormat ) 
			*pBestFormat = D3DFMT_A32B32G32R32F;
    }

    return true;
}

bool CHDREffect::__FindBestLuminanceFormat(D3DFORMAT* pBestLuminanceFormat)
{

    // Retrieve important information about the current configuration
    CGameHost::DEVICESETTINGS info = GAMEHOST.GetDeviceSettings();

    if( FAILED( DIRECT.CheckDeviceFormat( info.AdapterOrdinal, info.DeviceType,
                                                        info.AdapterFormat,
                                                        D3DUSAGE_QUERY_FILTER | D3DUSAGE_RENDERTARGET,
                                                        D3DRTYPE_TEXTURE, D3DFMT_G32R32F ) ) )
    {
        // We don't support 32 bit render targets with filtering. Check the next format.
        DEBUG_WARNING("Current device does *not* support single-precision floating point textures with filtering.");

        if( FAILED( DIRECT.CheckDeviceFormat( info.AdapterOrdinal, info.DeviceType,
                                                            info.AdapterFormat,
                                                            D3DUSAGE_QUERY_FILTER | D3DUSAGE_RENDERTARGET,
                                                            D3DRTYPE_TEXTURE, D3DFMT_G16R16F ) ) )
        {
            // We don't support 16 bit render targets with filtering. Check the next format.
            DEBUG_WARNING("Current device does *not* support half-precision floating point textures with filtering.");

            if( FAILED( DIRECT.CheckDeviceFormat( info.AdapterOrdinal, info.DeviceType,
                                                                info.AdapterFormat, D3DUSAGE_RENDERTARGET,
                                                                D3DRTYPE_TEXTURE, D3DFMT_G32R32F ) ) )
            {
                // We don't support 32 bit render targets. Check the next format.
                DEBUG_WARNING("Current device does *not* support single-precision floating point textures.");

                if( FAILED( DIRECT.CheckDeviceFormat( info.AdapterOrdinal, info.DeviceType,
                                                                    info.AdapterFormat, D3DUSAGE_RENDERTARGET,
                                                                    D3DRTYPE_TEXTURE, D3DFMT_G16R16F ) ) )
                {
                    // We don't support 16 bit render targets. This device is not compatable.
                    DEBUG_WARNING("Current device does *not* support half-precision floating point textures.");
                    DEBUG_WARNING("THE CURRENT HARDWARE DOES NOT SUPPORT HDR RENDERING!");

                    return false;
                }
                else
                {
                    // We have support for 16 bit render targets without filtering
                    DEBUG_WARNING("Best available format is 'half-precision without filtering'.");

                    if( NULL != pBestLuminanceFormat ) 
						*pBestLuminanceFormat = D3DFMT_G16R16F;
                }
            }
            else
            {
                // We have support for 32 bit render targets without filtering
                DEBUG_WARNING("Best available format is 'single-precision without filtering'.");

                if( NULL != pBestLuminanceFormat ) 
					*pBestLuminanceFormat = D3DFMT_G32R32F;
            }

        }
        else
        {
            // We have support for 16 bit render targets with filtering
            DEBUG_WARNING("Best available format is 'half-precision with filtering'.");

            if( NULL != pBestLuminanceFormat )
				*pBestLuminanceFormat = D3DFMT_G16R16F;
        }
    }
    else
    {
        // We have support for 32 bit render targets with filtering
        DEBUG_WARNING("Best available format is 'single-precision with filtering'.");

        if( NULL != pBestLuminanceFormat ) 
			*pBestLuminanceFormat = D3DFMT_G32R32F;
    }

    return true;
}