#include "StdAfx.h"
#include "TexturePrinter.h"

using namespace zerO;
CTexturePrinter::CTexturePrinter(void) :
CResource(RESOURCE_TEXTUREPRINTER),
m_pSavedRenderSurface(NULL),
m_pSavedDepthStencilSurface(NULL),
m_pDepthStencilSurface(NULL),
m_nCurrentTexture(-1)
{
}

CTexturePrinter::~CTexturePrinter(void)
{
	Destroy();
}

zerO::UINT CTexturePrinter::AddTexture(zerO::UINT uWidth, zerO::UINT uHeight, D3DFORMAT Format)
{
	LPTEXTURE pTexture;

	DEBUG_NEW( pTexture, TEXTURE(uWidth, uHeight, Format) );

	m_TextureList.push_back(pTexture);

	return m_TextureList.size() - 1;
}

zerO::UINT CTexturePrinter::AddTexture(CTexture::RESET pfnReset)
{
	LPTEXTURE pTexture;

	DEBUG_NEW( pTexture, TEXTURE(pfnReset) );

	m_TextureList.push_back(pTexture);

	return m_TextureList.size() - 1;
}

void ResetTexture(
				  zerO::UINT& uWidth, 
				  zerO::UINT& uHeight, 
				  D3DFORMAT & Format)
{
	uWidth     = GAMEHOST.GetBackBufferSurfaceDesc().Width;
	uHeight    = GAMEHOST.GetBackBufferSurfaceDesc().Height;
	Format     = GAMEHOST.GetBackBufferSurfaceDesc().Format;
}

zerO::UINT CTexturePrinter::AddTexture()
{
	return AddTexture(ResetTexture);
}

bool CTexturePrinter::Create()
{
	if(m_pSavedRenderSurface || m_pSavedDepthStencilSurface || m_pDepthStencilSurface)
		return false;

	HRESULT hr;

	hr = DEVICE.CreateDepthStencilSurface( 
		GAMEHOST.GetBackBufferSurfaceDesc().Width, 
		GAMEHOST.GetBackBufferSurfaceDesc().Height, 
		GAMEHOST.GetDeviceSettings().pp.AutoDepthStencilFormat, 
		GAMEHOST.GetBackBufferSurfaceDesc().MultiSampleType,
		GAMEHOST.GetBackBufferSurfaceDesc().MultiSampleQuality, 
		FALSE, 
		&m_pDepthStencilSurface,
		NULL );

	if( SUCCEEDED(hr) )
	{
		hr = DEVICE.GetRenderTarget( 0, &m_pSavedRenderSurface );

		if( FAILED(hr) )
		{
			DEBUG_WARNING(hr);
			return false;
		}

		hr = DEVICE.GetDepthStencilSurface( &m_pSavedDepthStencilSurface );

		if( FAILED(hr) )
		{
			DEBUG_WARNING(hr);
			return false;
		}
	}

	DEBUG_RELEASE(m_pDepthStencilSurface);

	m_pDepthStencilSurface = NULL;

	return true;
}

bool CTexturePrinter::Disable()
{
	DEBUG_RELEASE(m_pSavedRenderSurface);
	DEBUG_RELEASE(m_pSavedDepthStencilSurface);
	DEBUG_RELEASE(m_pDepthStencilSurface);

	m_pSavedRenderSurface       = NULL;
	m_pSavedDepthStencilSurface = NULL;
	m_pDepthStencilSurface      = NULL;

	for(std::vector<LPTEXTURE>::iterator i = m_TextureList.begin(); i != m_TextureList.end(); i ++)
	{
		DEBUG_RELEASE( (*i)->pSurface );

		(*i)->pSurface = NULL;
	}

	return true;
}

bool CTexturePrinter::Restore()
{
	HRESULT hr;
	RECT Rect;

	DEBUG_RELEASE(m_pSavedRenderSurface);
	DEBUG_RELEASE(m_pSavedDepthStencilSurface);
	DEBUG_RELEASE(m_pDepthStencilSurface);

	hr = DEVICE.CreateDepthStencilSurface( 
		GAMEHOST.GetBackBufferSurfaceDesc().Width, 
		GAMEHOST.GetBackBufferSurfaceDesc().Height, 
		GAMEHOST.GetDeviceSettings().pp.AutoDepthStencilFormat, 
		GAMEHOST.GetBackBufferSurfaceDesc().MultiSampleType,
		GAMEHOST.GetBackBufferSurfaceDesc().MultiSampleQuality, 
		FALSE, 
		&m_pDepthStencilSurface,
		NULL );

	if( FAILED(hr) )
	{
		DEBUG_WARNING(hr);
		return false;
	}

	hr = DEVICE.GetRenderTarget( 0, &m_pSavedRenderSurface );

	if( FAILED(hr) )
	{
		DEBUG_WARNING(hr);
		return false;
	}

	hr = DEVICE.GetDepthStencilSurface( &m_pSavedDepthStencilSurface );

	if( FAILED(hr) )
	{
		DEBUG_WARNING(hr);
		return false;
	}

	for(std::vector<LPTEXTURE>::iterator i = m_TextureList.begin(); i != m_TextureList.end(); i ++)
	{
		DEBUG_RELEASE( (*i)->pSurface );

		hr = (*i)->Texture.GetTexture()->GetSurfaceLevel( 0, &( (*i)->pSurface ) );

		if( FAILED(hr) )
		{
			DEBUG_WARNING(hr);
			return false;
		}

		hr = (*i)->pSurface->GetDesc(&(*i)->Desc);

		if( FAILED(hr) )
		{
			DEBUG_WARNING(hr);
			return false;
		}

		Rect.left   = 0;
		Rect.top    = 0;
		Rect.right  = (*i)->Desc.Width;
		Rect.bottom = (*i)->Desc.Height;

		hr = DEVICE.ColorFill( (*i)->pSurface, &Rect, 0 );
	}

	return true;
}

void CTexturePrinter::Begin()
{
	DEVICE.SetDepthStencilSurface(m_pDepthStencilSurface);
}

void CTexturePrinter::End(ENDFLAG Flag)
{
	if(TEST_FLAG(Flag, RENDER_SURFACE) && m_nCurrentTexture != - 1)
	{
		DEVICE.SetRenderTarget(0, m_pSavedRenderSurface);

		m_nCurrentTexture = - 1;
	}

	if( TEST_FLAG(Flag, DEPTH_STENCIL_SURFACE) )
		DEVICE.SetDepthStencilSurface(m_pSavedDepthStencilSurface);
}

void CTexturePrinter::Activate(zerO::UINT uTextureIndex, zerO::UINT32 uClearFlag, zerO::ARGBCOLOR Color)
{
	if( uTextureIndex >= m_TextureList.size() )
		return;

	HRESULT hr = DEVICE.SetRenderTarget(0, m_TextureList[uTextureIndex]->pSurface);

	if( FAILED(hr) )
	{
		DEBUG_WARNING(hr);

		return;
	}

	if(uClearFlag)
	{
		hr = DEVICE.Clear(0, NULL, uClearFlag, Color, 1.0f, 0);

		if( FAILED(hr) )
		{
			DEBUG_WARNING(hr);

			return;
		}
	}

	m_nCurrentTexture = uTextureIndex;
}

void CTexturePrinter::Draw(zerO::UINT uTextureIndex)
{
	if( uTextureIndex >= m_TextureList.size() )
		return;

	LPTEXTURE pTexture = m_TextureList[uTextureIndex];

	DEVICE.SetRenderState(D3DRS_ZENABLE, FALSE);
	DEVICE.SetRenderState(D3DRS_ZWRITEENABLE, FALSE);
	DEVICE.SetRenderState(D3DRS_FILLMODE, D3DFILL_SOLID);

	DEVICE.SetRenderTarget(0, pTexture->pSurface);

    FLOAT fWidth  = static_cast< float >(pTexture->Desc.Width ) - 0.5f;
    FLOAT fHeight = static_cast< float >(pTexture->Desc.Height) - 0.5f;

    VERTEX Vertices[4];

    Vertices[0].Position = D3DXVECTOR4(- 0.5f, - 0.5f, 0.0f, 1.0f);
    Vertices[0].UV       = D3DXVECTOR2(0.0f, 0.0f);

    Vertices[1].Position = D3DXVECTOR4(fWidth, - 0.5f, 0.0f, 1.0f);
    Vertices[1].UV       = D3DXVECTOR2(1.0f, 0.0f);

    Vertices[2].Position = D3DXVECTOR4(- 0.5f, fHeight, 0.0f, 1.0f);
    Vertices[2].UV       = D3DXVECTOR2(0.0f, 1.0f);

    Vertices[3].Position = D3DXVECTOR4(fWidth, fHeight, 0.0f, 1.0f);
    Vertices[3].UV       = D3DXVECTOR2(1.0f, 1.0f);

    DEVICE.SetVertexShader(NULL);
    DEVICE.SetFVF(D3DFVF_XYZRHW | D3DFVF_TEX1);
    DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLESTRIP, 2, Vertices, sizeof(VERTEX) );

	DEVICE.SetRenderState(D3DRS_ZENABLE, TRUE);
	DEVICE.SetRenderState(D3DRS_ZWRITEENABLE, TRUE);

	m_nCurrentTexture = uTextureIndex;
}

bool CTexturePrinter::Stretch(zerO::INT nDestinationIndex, zerO::INT nSourceIndex)
{
	zerO::INT nTextureSize = m_TextureList.size();
	if(nTextureSize <= nDestinationIndex || nTextureSize <= nSourceIndex)
	{
		DEBUG_WARNING("Erorr index.");

		return false;
	}

	HRESULT hr = DEVICE.StretchRect(nSourceIndex < 0 ? m_pSavedRenderSurface : m_TextureList[nSourceIndex]->pSurface, NULL, nDestinationIndex < 0 ? m_pSavedRenderSurface : m_TextureList[nDestinationIndex]->pSurface, NULL, D3DTEXF_NONE);

	if( FAILED(hr) )
	{
		DEBUG_WARNING(hr);

		return false;
	}

	return true;
}

bool CTexturePrinter::RnederToTexture(zerO::INT nTextureIndex)
{
	return Stretch(nTextureIndex, m_nCurrentTexture);
}

bool CTexturePrinter::Destroy()
{
	DEBUG_RELEASE(m_pSavedRenderSurface);
	DEBUG_RELEASE(m_pSavedDepthStencilSurface);
	DEBUG_RELEASE(m_pDepthStencilSurface);

	m_pSavedRenderSurface       = NULL;
	m_pSavedDepthStencilSurface = NULL;
	m_pDepthStencilSurface      = NULL;

	for(std::vector<LPTEXTURE>::iterator i = m_TextureList.begin(); i != m_TextureList.end(); i ++)
	{
		DEBUG_RELEASE( (*i)->pSurface );
		DEBUG_DELETE(*i);
	}

	m_TextureList.clear();

	return true;
}