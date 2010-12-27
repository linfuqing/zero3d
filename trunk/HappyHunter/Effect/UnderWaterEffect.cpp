#include "StdAfx.h"
#include "UnderWaterEffect.h"

using namespace zerO;

CUnderWaterEffect::CUnderWaterEffect(void)
{
}

CUnderWaterEffect::~CUnderWaterEffect(void)
{
}

bool CUnderWaterEffect::Restore()
{
	BUMPVERTEX* v;

	m_VertexBuffer.Lock(0, (void**)&v);

	FLOAT fError = 5.0f;
	FLOAT sx = (FLOAT)GAMEHOST.GetBackBufferSurfaceDesc().Width + fError;
	FLOAT sy = (FLOAT)GAMEHOST.GetBackBufferSurfaceDesc().Height + fError;

	v[0].p = D3DXVECTOR4(- fError ,   sy    , 0.0f, 1.0f);
	v[1].p = D3DXVECTOR4(- fError , - fError, 0.0f, 1.0f);
	v[2].p = D3DXVECTOR4(sx       ,   sy    , 0.0f, 1.0f);
	v[3].p = D3DXVECTOR4(sx       , - fError, 0.0f, 1.0f);
	v[0].tu2 = 0.000f;
	v[0].tv2 = 1.0f;
	v[1].tu2 = 0.000f;
	v[1].tv2 = 0.0f;
	v[2].tu2 = 1.000f; 
	v[2].tv2 = 1.0f;
	v[3].tu2 = 1.000f;
	v[3].tv2 = 0.0f;

	m_VertexBuffer.Unlock();

	return true;
}

bool CUnderWaterEffect::Create()
{
	m_VertexBuffer.Create(4, sizeof(BUMPVERTEX), D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED, NULL, D3DFVF_XYZRHW | D3DFVF_TEX2);

	UINT iWidth  = 256;
	UINT iHeight = 256;

	if( !m_Texture.Create(iWidth, iHeight, 1, 0, D3DFMT_V8U8, D3DPOOL_MANAGED) )
		return false;

	//填充纹理元素
	D3DLOCKED_RECT lrDst;
	m_Texture.GetTexture()->LockRect( 0, &lrDst, 0, 0 );
	BYTE* pDst = (BYTE*)lrDst.pBits;

	for( DWORD y=0; y<iHeight; y++ )
	{
		for( DWORD x=0; x<iWidth; x++ )
		{
			FLOAT fx = x/(FLOAT)iWidth  - 0.5f;
			FLOAT fy = y/(FLOAT)iHeight - 0.5f;

			CHAR iDu = (CHAR)(64*cosf(4.0f*(fx+fy)*D3DX_PI));
			CHAR iDv = (CHAR)(64*sinf(4.0f*(fx+fy)*D3DX_PI));

			pDst[2*x+0] = iDu;
			pDst[2*x+1] = iDv;
		}
		pDst += lrDst.Pitch;
	}

	m_Texture.GetTexture()->UnlockRect(0);

	return true;
}

//inline float rnd() { return (((FLOAT)rand()-(FLOAT)rand())/(2L*RAND_MAX)); }
//inline float RND() { return (((float)rand())/RAND_MAX); }
inline DWORD F2DW( float f ) { return *((DWORD*)&f); }

void CUnderWaterEffect::Render(CTexturePrinter& TexturePrinter)
{
	FLOAT64 fTime = TIME;

	//实时更新纹理坐标
	BUMPVERTEX* vWaterVertices;
	m_VertexBuffer.Lock(0,(void**)&vWaterVertices);
	vWaterVertices[0].tu1 = 0.000f; 
	vWaterVertices[0].tv1 = 0.5f*(float)fTime + 2.0f;
	vWaterVertices[1].tu1 = 0.000f; 
	vWaterVertices[1].tv1 = 0.5f*(float)fTime;
	vWaterVertices[2].tu1 = 1.000f; 
	vWaterVertices[2].tv1 = 0.5f*(float)fTime;
	vWaterVertices[3].tu1 = 1.000f; 
	vWaterVertices[3].tv1 = 0.5f*(float)fTime + 2.0f;
	m_VertexBuffer.Unlock();

	m_VertexBuffer.Activate(0, 0, true);

	//设置纹理状态
	DEVICE.SetTextureStageState( 0, D3DTSS_TEXCOORDINDEX, 0 );
	DEVICE.SetTextureStageState( 0, D3DTSS_COLOROP,   D3DTOP_BUMPENVMAP );
	DEVICE.SetTextureStageState( 0, D3DTSS_BUMPENVMAT00, F2DW(0.01f) );
	DEVICE.SetTextureStageState( 0, D3DTSS_BUMPENVMAT01, F2DW(0.00f) );
	DEVICE.SetTextureStageState( 0, D3DTSS_BUMPENVMAT10, F2DW(0.00f) );
	DEVICE.SetTextureStageState( 0, D3DTSS_BUMPENVMAT11, F2DW(0.01f) );
	DEVICE.SetSamplerState( 0, D3DSAMP_ADDRESSU, D3DTADDRESS_WRAP );
	DEVICE.SetSamplerState( 0, D3DSAMP_ADDRESSV, D3DTADDRESS_WRAP );

	DEVICE.SetTextureStageState( 1, D3DTSS_TEXCOORDINDEX, 1 );
	DEVICE.SetTextureStageState( 1, D3DTSS_COLOROP,   D3DTOP_SELECTARG1 );
	DEVICE.SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
	DEVICE.SetSamplerState( 1, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
	DEVICE.SetSamplerState( 1, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );

	DEVICE.SetTexture( 0, m_Texture.GetTexture() );
	DEVICE.SetTexture(1, TexturePrinter.GetTexture(0)->GetTexture() );

	DEVICE.DrawPrimitive( D3DPT_TRIANGLESTRIP, 0, 2 );

	DEVICE.SetTexture(0, NULL);
	DEVICE.SetTexture(1, NULL);
	DEVICE.SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
	DEVICE.SetTextureStageState( 0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1 );
	DEVICE.SetTextureStageState( 1, D3DTSS_COLOROP,   D3DTOP_DISABLE );
}