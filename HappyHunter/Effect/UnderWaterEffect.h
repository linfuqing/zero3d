#pragma once

#include "FullScreenEffect.h"
#include "VertexBuffer.h"
#include "Texture.h"

namespace zerO
{
	class CUnderWaterEffect :
		public CFullScreenEffect
	{
		struct BUMPVERTEX
		{
			D3DXVECTOR4 p;
			float tu1, tv1;
			float tu2, tv2;
		};
	public:
		CUnderWaterEffect(void);
		~CUnderWaterEffect(void);

		bool Restore();
		bool Create();

		void Render(CTexturePrinter& TexturePrinter);

	private:
		CVertexBuffer m_VertexBuffer;
		CTexture m_Texture;
	};
}