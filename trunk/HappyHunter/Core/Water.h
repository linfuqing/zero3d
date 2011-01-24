#pragma once

#include "RenderMethod.h"
#include "VertexBuffer.h"
#include "IndexBuffer.h"
#include "Geometry.h"

namespace zerO
{
	class CWater
	{
		typedef struct
		{
			FLOAT x, y, z;
		}VERTEX, * LPVERTEX;
	public:
		CWater(void);
		~CWater(void);

		CRenderMethod& GetRenderMethod();

		void SetBumpMap(CTexture* const pTexture);
		void SetTransform(const D3DXMATRIX& Matrix);

		bool Create(
			FLOAT fWidth, 
			FLOAT fHeight, 
			UINT uSegmentsX, 
			UINT uSegmentsY, 
			CTexture::RESET pfnRefractionReset = NULL, 
			CTexture::RESET pfnReflectionReset = NULL);
		void UpdateViewSpace();
		void Render(bool bIsRenderToTexture = false);

	private:
		CRenderMethod m_RenderMethod;

		CTexture* m_pBumpMap;

		D3DXPLANE m_Plane;

		D3DXMATRIX m_Matrix;

		CSurface m_Surface;

		CGeometry m_Geometry;

		CTexture::RESET m_pfnRefractionReset;
		CTexture::RESET m_pfnReflectionReset;

		UINT m_uRefractionMap;
		UINT m_uReflectionMap;

		static UINT sm_uRefractionMap;
		static UINT sm_uReflectionMap;
	};

	inline CRenderMethod& CWater::GetRenderMethod()
	{
		return m_RenderMethod;
	}

	inline void CWater::SetBumpMap(CTexture* const pTexture)
	{
		m_pBumpMap = pTexture;

		m_Surface.SetTexture(pTexture, 2);
	}

	inline void CWater::SetTransform(const D3DXMATRIX& Matrix)
	{
		m_Matrix = Matrix;
	}
}
