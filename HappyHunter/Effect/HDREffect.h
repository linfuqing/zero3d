#pragma once
#include "FullScreenEffect.h"

namespace zerO
{
	static const DWORD m_dwLumTextures = 6;                // How many luminance textures we're creating

	class CHDREffect :
		public CFullScreenEffect
	{
		typedef struct
		{
			D3DXVECTOR4 Position;
			D3DXVECTOR2 UV;
		}VERTEX;
	public:
		CHDREffect(void);
		~CHDREffect(void);

		bool Create(UINT uNumLuminanceTextures);
		//bool Restore();

		bool Destroy();

		void Render(CTexturePrinter &TexturePrinter);

	private:
		bool __CreateLuminance(UINT uNumLuminanceTextures);
		bool __CreatePostProcessing();

		void __MeasureLuminance(CTexturePrinter &TexturePrinter);
		void __PerformPostProcessing();

		float __ComputeGaussianValue( float x, float mean, float std_deviation );

		bool __FindBestHDRFormat( D3DFORMAT* pBestFormat );
		bool __FindBestLuminanceFormat( D3DFORMAT* pBestLuminanceFormat );

		//UINT  m_uFinalTexture;

		UINT  m_uNumLuminanceTextures;

		PUINT m_puTextureLuminance;
		UINT  m_uCurrentLuminanceTexture;
		UINT  m_uLastLuminanceTexture;

		UINT  m_uBrightPassTexture;
		UINT  m_uDownSampledTexture;
		UINT  m_uBloomHorizontal;
		UINT  m_uBloomVertical;

		LPDIRECT3DPIXELSHADER9      m_pFinalPassPS;     // The pixel shader that maps HDR->LDR
		LPD3DXCONSTANTTABLE         m_pFinalPassPSConsts;     // The interface for setting param/const data for the above PS

		//LPDIRECT3DPIXELSHADER9 m_pLumDispPS;             // PShader used to display the debug panel
		LPDIRECT3DPIXELSHADER9 m_pAdaptedLumPS;
		LPD3DXCONSTANTTABLE m_pAdaptedLumPSConsts;

		LPDIRECT3DPIXELSHADER9 m_pLum1PS;             // PShader that does a 2x2 downsample and convert to greyscale
		LPD3DXCONSTANTTABLE m_pLum1PSConsts;             // Interface to set the sampling points for the above PS

		LPDIRECT3DPIXELSHADER9 m_pLum3x3DSPS;             // The PS that does each 3x3 downsample operation
		LPD3DXCONSTANTTABLE m_pLum3x3DSPSConsts;             // Interface for the above PS

		LPDIRECT3DPIXELSHADER9 m_pBrightPassPS;             // Represents the bright pass processing
		LPD3DXCONSTANTTABLE m_pBrightPassConstants;

		LPDIRECT3DPIXELSHADER9 m_pDownSamplePS;             // Represents the downsampling processing
		LPD3DXCONSTANTTABLE m_pDownSampleConstants;

		LPDIRECT3DPIXELSHADER9 m_pHBloomPS;             // Performs the first stage of the bloom rendering
		LPD3DXCONSTANTTABLE m_pHBloomConstants;

		LPDIRECT3DPIXELSHADER9 m_pVBloomPS;             // Performs the second stage of the bloom rendering
		LPD3DXCONSTANTTABLE m_pVBloomConstants;
	};
}