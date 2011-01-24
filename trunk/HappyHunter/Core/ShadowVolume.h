//=============================================================================
// Desc: ShadowVolume.h
//=============================================================================

#pragma once

#include <map>
#include <vector>

#include "SceneNode.h"
#include "Shadow.h"
#include "VertexBuffer.h"

namespace zerO
{
	class CShadowVolume :
		public CShadow
	{
		/*typedef struct
		{
			UINT         v0;
			UINT         v1;
			UINT         v2;

			D3DXVECTOR3  Normal;
		}TRIANGLE, * LPTRIANGLE;

		typedef struct
		{
			UINT v0;
			UINT v1;
		}EDGE, * LPEDGE;*/

		typedef struct
		{
			D3DXVECTOR3 Position;
			D3DXVECTOR3 Normal;
		}VERTEX, * LPVERTEX;

		typedef struct
		{
			UINT         v0;
			UINT         v1;
			UINT         v2;

			UINT uSharedVertices[3];

			D3DXVECTOR3  Normal;

			bool bIsLightFacing;
		}TRIANGLE, * LPTRIANGLE;

		typedef struct
		{
			UINT uVertices[2];
			UINT uSharedVertices[2];
			UINT uTriangles[2];

			bool bIsDegenerate;

		}EDGE, * LPEDGE;

		struct VectorLess {
            bool operator()(const D3DXVECTOR3& a, const D3DXVECTOR3& b) const
            {
                if (a.x < b.x) 
					return true;

                if (a.x > b.x) 
					return false;

                if (a.y < b.y) 
					return true;

                if (a.y > b.y) 
					return false;

                return a.z < b.z;
            }
        };
	public:
		CShadowVolume(void);
		~CShadowVolume(void);

		void SetLength(FLOAT fLength);
		void SetVisible(bool bValue);
		void SetTransform(const D3DXMATRIX Matrix);

		void UpdateVertices(void* pVertices);

		bool Create(ID3DXMesh& Mesh, CSceneNode& Node);

		bool Create(
			UINT uNumVertices,
			UINT uNumTriangles, 
			CSceneNode& Parent,
			UINT uIndexSize,
			UINT uVertexSize, 
			UINT uVertexOffset = 0, 
			void* pVertices = NULL, 
			void* pIndices = NULL);

		void Update();
		void Render();
		bool Destroy();

	private:
		void __BuildVertexList(void* pVertices);
		void __BuildTriangleList(void* pIndices);
		void __BuildEdgeList();

		void __AddEdge(UINT v0, UINT v1, UINT uSharedVertex0, UINT uSharedVertex1, zerO::UINT uTriangle);

		void __Draw(UINT uStartVertex, UINT uPrimitiveCount);

		UINT __GetCommonVertex(const D3DXVECTOR3& Position);

		LPTRIANGLE   m_pTriangles;
		LPEDGE       m_pEdges;
		LPVERTEX     m_pVertices;

		D3DXVECTOR3  m_Extends;

		UINT         m_uVertexSize;
		UINT         m_uIndexSize;

		UINT         m_uNumVertices;
		UINT         m_uNumTriangles;
		UINT         m_uNumEdges;

		UINT         m_uFlushVertices;
		UINT         m_uFlushFaces;

		UINT         m_uDiscardVertices;

		FLOAT        m_fLength;

		D3DXMATRIX   m_Matrix;
		D3DXMATRIX   m_Transform;

		CSceneNode*  m_pParent;
		bool         m_bIsRenderVolume;
		bool         m_bIsVisible;
		bool         m_bIsCulled;

		typedef std::map<D3DXVECTOR3, UINT, VectorLess> COMMONVERTEXMAP;
		COMMONVERTEXMAP m_CommonVertexMap;
		std::vector<D3DXVECTOR3> m_CommonVertex;
		typedef std::multimap<std::pair<UINT, UINT>, UINT> EDGEMAP;
		EDGEMAP m_EdgeMap;

		CVertexBuffer m_VertexBuffer;
	};

	inline void CShadowVolume::SetLength(FLOAT fLength)
	{
		m_fLength = fLength;
	}

	inline void CShadowVolume::SetVisible(bool bValue)
	{
		m_bIsVisible = bValue;
	}

	inline void CShadowVolume::SetTransform(const D3DXMATRIX Matrix)
	{
		m_Transform = Matrix;
	}
}