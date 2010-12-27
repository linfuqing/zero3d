#pragma once

#include <vector>
#include "Texture.h"

namespace zerO
{
	class CTexturePrinter :
		public CResource
	{
		typedef struct
		{
			D3DXVECTOR4 Position;
			D3DXVECTOR2 UV;
		}VERTEX;
	public:
		typedef struct TEXTURE
		{
			CTexture Texture;
			LPDIRECT3DSURFACE9 pSurface;
			D3DSURFACE_DESC Desc;

			TEXTURE(CTexture::RESET pfnReset) :
			pSurface(NULL)
			{
				DEBUG_ASSERT(Texture.Create(pfnReset, D3DUSAGE_RENDERTARGET), "CTexturePrinter::TEXTURE can not created.");
			}

			TEXTURE(UINT uWidth, UINT uHeight, D3DFORMAT Format) :
			pSurface(NULL)
			{
				DEBUG_ASSERT(Texture.Create(uWidth, uHeight, 1, D3DUSAGE_RENDERTARGET, Format, D3DPOOL_DEFAULT), "CTexturePrinter::TEXTURE can not created.") ;
			}
		}TEXTURE, * LPTEXTURE;

		CTexturePrinter(void);
		~CTexturePrinter(void);

		CTexture* GetTexture(UINT uIndex)const;
		const LPTEXTURE GetTextureInfo(UINT uIndex)const;

		UINT AddTexture(UINT uWidth, UINT uHeight, D3DFORMAT Format);
		UINT AddTexture(CTexture::RESET pfnReset);
		UINT AddTexture();

		bool Disable();
		bool Restore();

		void Begin();
		void End();

		void Activate(UINT uTextureIndex, UINT32 uClearFlag = 0, ARGBCOLOR Color = 0);
		void Draw(UINT uTextureIndex);

		bool Destroy();

	private:
		std::vector<LPTEXTURE> m_TextureList;

		/// 保存原有的渲染表面
		LPDIRECT3DSURFACE9 m_pSavedRenderSurface;
		/// 保存原有的深度表面
		LPDIRECT3DSURFACE9 m_pSavedDepthStencilSurface;

		LPDIRECT3DSURFACE9 m_pDepthStencilSurface;
	};

	inline CTexture* CTexturePrinter::GetTexture(UINT uIndex)const
	{
		if( uIndex < m_TextureList.size() )
			return &m_TextureList[uIndex]->Texture;

		return NULL;
	}

	inline const CTexturePrinter::LPTEXTURE CTexturePrinter::GetTextureInfo(UINT uIndex)const
	{
		if( uIndex < m_TextureList.size() )
			return m_TextureList[uIndex];

		return NULL;
	}
}