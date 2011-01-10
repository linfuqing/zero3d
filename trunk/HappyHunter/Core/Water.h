#pragma once

#include "RenderMethod.h"
#include "VertexBuffer.h"
#include "IndexBuffer.h"

namespace zerO
{
	class CWater
	{
		typedef struct
		{
			FLOAT x, y, z, w;
		}VERTEX, * LPVERTEX;
	public:
		CWater(void);
		~CWater(void);

		CRenderMethod& GetRenderMethod();

		bool Create(zerO::FLOAT fWidth, zerO::FLOAT fHeight, zerO::UINT uSegmentsX, zerO::UINT uSegmentsY);
		void Update();
		void Render();

	private:
		CRenderMethod m_RenderMethod;

		CVertexBuffer m_VertexBuffer;
		CIndexBuffer m_IndexBuffer;

		UINT m_uVerticesX;
		UINT m_uVerticesY;

		D3DXPLANE m_Plane;

		D3DXMATRIX m_Matrix;

		static UINT sm_uTexture;

		/*typedef struct
		{
			D3DXVECTOR4 Position;
			D3DXVECTOR2 UV;
		}RENDERVERTEX, * LPRENDERVERTEX;

		RENDERVERTEX m_Vertices[4];*/
	};

	inline CRenderMethod& CWater::GetRenderMethod()
	{
		return m_RenderMethod;
	}
}
