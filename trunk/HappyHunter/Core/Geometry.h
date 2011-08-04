#pragma once

#include "VertexBuffer.h"
#include "IndexBuffer.h"
#include "RenderMethod.h"
#include "SceneNode.h"

namespace zerO
{
	class CGeometry;
	class CGeometrySubset :
		public CSceneNode
	{
		friend class CGeometry;
	public:
		typedef struct
		{
			D3DXVECTOR3 Position;
			/*D3DXVECTOR2 UV;
			D3DXVECTOR3 Normal;
			D3DXVECTOR3 Tangent;*/
			//D3DXVECTOR3 Binormal;
		}VERTEX, *LPVERTEX;

		typedef struct
		{
			D3DXVECTOR2 UV;
			D3DXVECTOR3 Normal;
		}VERTEXINFO, *LPVERTEXINFO;

		typedef struct
		{
			D3DXVECTOR3 Tangent;
			D3DXVECTOR3 Binormal;
		}VERTEXADDITIONALINFO, *LPVERTEXADDITIONALINFO;

		CGeometrySubset(CGeometry& Parent, UINT uStartVertex, UINT uEndVertex);
		~CGeometrySubset(void);

		bool ApplyForRender();

		void Render(CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag);

		bool Destroy();
	private:
		CIndexBuffer m_IndexBuffer;
		CSurface m_Surface;

		UINT m_uStartVertex;
		UINT m_uEndVertex;

		UINT m_uNumVertices;

		CGeometry* m_pParent;
	};

	class CGeometry
	{
		friend class CGeometrySubset;

	public:

		typedef CGeometrySubset::VERTEX               VERTEX              , * LPVERTEX;
		typedef CGeometrySubset::VERTEXINFO           VERTEXINFO          , * LPVERTEXINFO;
		typedef CGeometrySubset::VERTEXADDITIONALINFO VERTEXADDITIONALINFO, * LPVERTEXADDITIONALINFO;

		typedef enum
		{
			POSITION       = 0x01,
			INFO           = 0x02,
			ADDITIONALINFO = 0x04,
		}VERTEXTYPE;

		typedef enum
		{
			DYNAMIC_VERTEX = 0x10,
			STATIC_VERTEX  = 0x20,

			DYNAMIC_INDEX  = 0x40,
			STATIC_INDEX   = 0x80
		}BUFFERTYPE;

		CGeometry(CSceneNode* pParent = NULL, UINT8 uFlag = POSITION | INFO | STATIC_VERTEX | STATIC_INDEX);
		~CGeometry(void);

		virtual bool Create(const PUINT8 pData);

		bool CreatePlane(
			FLOAT fWidth, 
			FLOAT fHeight, 
			UINT uVerticesX, 
			UINT uVerticesY,
			UINT uStepX = 1,
			UINT uStepY = 1);

		bool DrawSubset(UINT uIndex, bool bIsActiveVertices = true, bool bIsAutoEffect = true, const LPD3DXMATRIX pWorldMatrix = NULL);

		bool Draw(bool bIsAutoEffect = true, const LPD3DXMATRIX pWorldMatrix = NULL);

		bool Destroy();

	private:
		std::vector<CGeometrySubset*> m_SubsetList;

		CVertexBuffer m_VertexBuffer;

		CVertexBuffer m_VertexInfoBuffer;

		CVertexBuffer m_VertexAdditionalInfoBuffer;

		CRenderMethod m_RenderMethod;

		CSceneNode* m_pParent;

		UINT8 m_uFlag;
	};
}
