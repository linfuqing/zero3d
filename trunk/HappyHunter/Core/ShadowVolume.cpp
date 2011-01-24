//=============================================================================
// Desc: ShadowVolume.cpp
//=============================================================================

#include "stdafx.h"
#include "ShadowVolume.h"
#include "basicutils.h"
#include "Camera.h"

using namespace zerO;


CShadowVolume::CShadowVolume(void) :
m_bIsRenderVolume(false),
m_bIsVisible(false),
m_bIsCulled(false),
m_pTriangles(NULL),
m_pEdges(NULL),
//m_pSourceVertices(NULL),
m_pVertices(NULL),
m_fLength(0.0f)
{
	//D3DXMatrixIdentity(&m_Matrix);
	D3DXMatrixIdentity(&m_Transform);
}

CShadowVolume::~CShadowVolume(void)
{
	Destroy();
}

//-----------------------------------------------------------------------------
// Desc: 创建阴影体
//-----------------------------------------------------------------------------
bool CShadowVolume::Create(
						   zerO::UINT uNumVertices,
						   zerO::UINT uNumTriangles, 
						   CSceneNode& Parent, 
						   zerO::UINT uIndexSize,
						   zerO::UINT uVertexSize, 
						   zerO::UINT uVertexOffset, 
						   void* pVertices, 
						   void* pIndices)
{
	if(!pVertices || !pIndices)
		return false;


	m_uVertexSize = uVertexSize;

	m_uNumVertices  = uNumVertices;
	m_uNumTriangles = uNumTriangles;

	m_pParent       = &Parent;

	m_uNumEdges     = 0;

	DEBUG_NEW(m_pEdges         , EDGE    [uNumTriangles * 3]);
	DEBUG_NEW(m_pTriangles     , TRIANGLE[uNumTriangles    ]);
	DEBUG_NEW(m_pVertices      , VERTEX  [uNumVertices     ]);
	
	__BuildVertexList(pVertices);

	__BuildTriangleList(pIndices);

	__BuildEdgeList();

	m_VertexBuffer.Create(m_uNumTriangles * 3 * 6, sizeof(D3DXVECTOR3), D3DUSAGE_DYNAMIC | D3DUSAGE_WRITEONLY, D3DPOOL_DEFAULT, NULL, D3DFVF_XYZ);

	return true;
}

bool CShadowVolume::Create(ID3DXMesh& Mesh, CSceneNode& Node)
{
	void* pVertices, *pIndices;

	Mesh.LockVertexBuffer( 0L, (LPVOID*)&pVertices );
    Mesh.LockIndexBuffer( 0L, (LPVOID*)&pIndices );

	Mesh.UnlockVertexBuffer();
    Mesh.UnlockIndexBuffer();

	return Create(
		Mesh.GetNumVertices(), 
		Mesh.GetNumFaces(),
		Node,
		TEST_FLAG(Mesh.GetOptions(), D3DXMESH_32BIT) ? sizeof(INT32) : sizeof(INT16),
		Mesh.GetNumBytesPerVertex(),
		0,
		pVertices,
		pIndices);
}

void CShadowVolume::UpdateVertices(void* pSourceVertices)
{
	UINT i;
	D3DXVECTOR3 v0, v1, v2;
	LPTRIANGLE pTriangle;
	PUINT8 pVertices = (PUINT8)pSourceVertices;

	memset( m_pVertices, 0, m_uNumVertices * sizeof(VERTEX) );

	for(i = 0; i < m_uNumVertices; i ++)
	{
		m_pVertices[i].Position = *(LPD3DXVECTOR3)pVertices;

		pVertices += m_uVertexSize;
	}

	for(i = 0; i < m_uNumTriangles; i ++)
    {
		pTriangle = &m_pTriangles[i];

		v0 = m_pVertices[pTriangle->v0].Position;
		v1 = m_pVertices[pTriangle->v1].Position;
		v2 = m_pVertices[pTriangle->v2].Position;

        D3DXVec3Cross( &pTriangle->Normal, &(v2 - v1), &(v1 - v0) );

		D3DXVec3Normalize(&pTriangle->Normal, &pTriangle->Normal);

		m_pVertices[pTriangle->v0].Normal += pTriangle->Normal;
		m_pVertices[pTriangle->v1].Normal += pTriangle->Normal;
		m_pVertices[pTriangle->v2].Normal += pTriangle->Normal;
    }

	for(i = 0; i < m_uNumVertices; i ++)
	{
		m_pVertices[i].Position += *D3DXVec3Normalize(&m_pVertices[i].Normal, &m_pVertices[i].Normal);
	}
}

//-----------------------------------------------------------------------------
// Desc: 根据网格模型和光源位置构造阴影体
//       首先检查网格模型的每个三角形, 将网格模型的轮廓边保存到一个临时列表中.
//       然后根据轮廓边和光源位置构造阴影体
//-----------------------------------------------------------------------------
void CShadowVolume::Update()
{
	if(!m_bIsVisible)
		return;

	//D3DXMatrixIdentity(&m_Matrix);

	m_Matrix = m_Transform;

	m_Matrix *= m_pParent->GetWorldMatrix();

	D3DXVECTOR3 Position(m_Matrix._41, m_Matrix._42, m_Matrix._43);

	if(m_Matrix._44)
		Position /= m_Matrix._44;

	Position -= CAMERA.GetWorldPosition();

	if( D3DXVec3Length(&Position) + m_pParent->GetWorldRectangle().GetSize() < CAMERA.GetFarPlane() )
		m_bIsCulled = false;
	else
	{
		m_bIsCulled = true;

		return;
	}

	D3DXVECTOR3 LightPosition(LIGHTMANAGER.GetLight(0)->Position);

	D3DXMATRIX InverseWorldMatrix;
    D3DXMatrixInverse(&InverseWorldMatrix, NULL, &m_Matrix);

	D3DXVec3TransformCoord(&LightPosition, &LightPosition, &InverseWorldMatrix);

	D3DXVec3Normalize(&LightPosition, &LightPosition);

	D3DXVECTOR3 Max, Min;

	m_Extends = LightPosition * 500;

	if(m_Extends.x < 0.0f)
	{
		Min.x = m_pParent->GetWorldRectangle().GetMinX();
		Max.x = m_pParent->GetWorldRectangle().GetMaxX() - m_Extends.x;
	}
	else
	{
		Min.x = m_pParent->GetWorldRectangle().GetMinX() - m_Extends.x;
		Max.x = m_pParent->GetWorldRectangle().GetMaxX();
	}

	if(m_Extends.y < 0.0f)
	{
		Min.y = m_pParent->GetWorldRectangle().GetMinY();
		Max.y = m_pParent->GetWorldRectangle().GetMaxY() - m_Extends.y;
	}
	else
	{
		Min.y = m_pParent->GetWorldRectangle().GetMinY() - m_Extends.y;
		Max.y = m_pParent->GetWorldRectangle().GetMaxY();
	}

	if(m_Extends.z < 0.0f)
	{
		Min.z = m_pParent->GetWorldRectangle().GetMinZ();
		Max.z = m_pParent->GetWorldRectangle().GetMaxZ() - m_Extends.z;
	}
	else
	{
		Min.z = m_pParent->GetWorldRectangle().GetMinZ() - m_Extends.z;
		Max.z = m_pParent->GetWorldRectangle().GetMaxZ();
	}

	CRectangle3D Rect;

	Rect.Set(Min.x, Max.x, Min.y, Max.y, Min.z, Max.z);

	if( CAMERA.GetFrustum().TestHit(Rect) )
		m_bIsCulled = false;
	else
	{
		m_bIsCulled = true;

		return;
	}

    //遍历网格模型的每个面(三角形), 将网格模型的轮廓边添加到临时边列表中
    for(UINT i = 0; i < m_uNumTriangles; i ++)
		m_pTriangles[i].bIsLightFacing = D3DXVec3Dot(&m_pTriangles[i].Normal, &LightPosition) < 0.0f;
}

void CShadowVolume::__BuildVertexList(void* pSourceVertices)
{
	PUINT8 pVertices = (PUINT8)pSourceVertices;
	for(UINT i = 0; i < m_uNumVertices; i ++)
	{
		m_pVertices[i].Position = *(LPD3DXVECTOR3)pVertices;

		pVertices += m_uVertexSize;
	}
}

void CShadowVolume::__BuildTriangleList(void* pSourceIndices)
{
	zerO::UINT i0, i1, i2, i, j = 0;

	D3DXVECTOR3 v0, v1, v2;

	PUINT8 pIndices = (PUINT8)pSourceIndices;

	//遍历网格模型的每个面(三角形), 将网格模型的轮廓边添加到临时边列表中
    for(i = 0; i < m_uNumTriangles; i ++)
    {
		i0 = 0;
		i1 = 0;
		i2 = 0;

		memcpy(&i0, pIndices, 2);
		pIndices += 2;
		memcpy(&i1, pIndices, 2);
		pIndices += 2;
		memcpy(&i2, pIndices, 2);
		pIndices += 2;

		v0 = m_pVertices[i0].Position;
		v1 = m_pVertices[i1].Position;
		v2 = m_pVertices[i2].Position;

		//根据顶点索引获取当前面三个顶点的坐标
        m_pTriangles[i].v0 = i0;
        m_pTriangles[i].v1 = i1;
        m_pTriangles[i].v2 = i2;

		m_pTriangles[i].uSharedVertices[0] = __GetCommonVertex(v0);
		m_pTriangles[i].uSharedVertices[1] = __GetCommonVertex(v1);
		m_pTriangles[i].uSharedVertices[2] = __GetCommonVertex(v2);

        D3DXVec3Cross( &m_pTriangles[i].Normal, &(v2 - v1), &(v1 - v0) );

		D3DXVec3Normalize(&m_pTriangles[i].Normal, &m_pTriangles[i].Normal);
    }
}

void CShadowVolume::__BuildEdgeList()
{
	for(UINT i = 0; i < m_uNumTriangles; i ++)
	{
		__AddEdge(m_pTriangles[i].v0, m_pTriangles[i].v1, m_pTriangles[i].uSharedVertices[0], m_pTriangles[i].uSharedVertices[1], i);
		__AddEdge(m_pTriangles[i].v1, m_pTriangles[i].v2, m_pTriangles[i].uSharedVertices[1], m_pTriangles[i].uSharedVertices[2], i);
		__AddEdge(m_pTriangles[i].v2, m_pTriangles[i].v0, m_pTriangles[i].uSharedVertices[2], m_pTriangles[i].uSharedVertices[0], i);
	}
}

void CShadowVolume::__AddEdge(zerO::UINT v0, zerO::UINT v1, zerO::UINT uSharedVertex0, zerO::UINT uSharedVertex1, zerO::UINT uTriangle)
{
	// Find the existing edge (should be reversed order) on shared vertices
    EDGEMAP::iterator emi = m_EdgeMap.find(std::pair<UINT, UINT>(uSharedVertex1, uSharedVertex0));
    if( emi != m_EdgeMap.end() )
    {
        // The edge already exist, connect it
        EDGE& Edge = m_pEdges[emi->second];
        // update with second side
        Edge.uTriangles[1] = uTriangle;

		Edge.bIsDegenerate = false;

        // Remove from the edge map, so we never supplied to connect edge again
        m_EdgeMap.erase(emi);
    }
    else
    {
        // Not found, create new edge
        m_EdgeMap.insert( EDGEMAP::value_type(std::pair<UINT, UINT>(uSharedVertex0, uSharedVertex1), m_uNumEdges) );
        EDGE& Edge = m_pEdges[m_uNumEdges];

        // Set only first tri, the other will be completed in connect existing edge
        Edge.uVertices[0] = v0;
		Edge.uVertices[1] = v1;

		Edge.uSharedVertices[0] = uSharedVertex0;
		Edge.uSharedVertices[1] = uSharedVertex1;

		Edge.uTriangles[0] = uTriangle;

		Edge.bIsDegenerate = true;

        m_uNumEdges ++;
    }
}

zerO::UINT CShadowVolume::__GetCommonVertex(const D3DXVECTOR3& Position)
{
	std::pair<COMMONVERTEXMAP::iterator, bool> Inserted = m_CommonVertexMap.insert(COMMONVERTEXMAP::value_type(Position, m_CommonVertex.size()));
    if (!Inserted.second)
		return Inserted.first->second;

	m_CommonVertex.push_back(Position);

	return m_CommonVertex.size() - 1;
}

//-----------------------------------------------------------------------------
// Desc: 渲染阴影体, 只更新模板缓冲区, 不更新颜色缓冲区
//-----------------------------------------------------------------------------
void CShadowVolume::Render()
{
	if(!m_bIsVisible || m_bIsCulled)
		return;

	//禁用z缓冲区写操作, 并启用模板缓冲区
    DEVICE.SetRenderState( D3DRS_ZWRITEENABLE,  FALSE );
    DEVICE.SetRenderState( D3DRS_STENCILENABLE, TRUE );

	//DEVICE.SetRenderState( D3DRS_SLOPESCALEDEPTHBIAS, 

	DEVICE.SetRenderState( D3DRS_STENCILFUNC,  D3DCMP_ALWAYS );
	DEVICE.SetRenderState( D3DRS_STENCILZFAIL,  D3DSTENCILOP_DECR/*D3DSTENCILOP_KEEP*/ );
	DEVICE.SetRenderState( D3DRS_STENCILFAIL,  D3DSTENCILOP_KEEP );
	DEVICE.SetRenderState( D3DRS_STENCILPASS, D3DSTENCILOP_KEEP/*D3DSTENCILOP_DECR*/ );

	DEVICE.SetRenderState( D3DRS_STENCILREF,  0x1 );
	DEVICE.SetRenderState( D3DRS_STENCILMASK,  0xffffffff );
	DEVICE.SetRenderState( D3DRS_STENCILWRITEMASK,  0xffffffff );

	if( TEST_FLAG(GAMEHOST.GetCaps().StencilCaps, D3DSTENCILCAPS_TWOSIDED) )
	{
		DEVICE.SetRenderState(D3DRS_TWOSIDEDSTENCILMODE,   TRUE);
		DEVICE.SetRenderState(D3DRS_CCW_STENCILFUNC,   D3DCMP_ALWAYS );
		DEVICE.SetRenderState(D3DRS_CCW_STENCILZFAIL,   D3DSTENCILOP_INCR/*D3DSTENCILOP_KEEP*/ );
		DEVICE.SetRenderState(D3DRS_CCW_STENCILFAIL,   D3DSTENCILOP_KEEP);
		DEVICE.SetRenderState(D3DRS_CCW_STENCILPASS,   D3DSTENCILOP_KEEP/*D3DSTENCILOP_INCR*/);

		DEVICE.SetRenderState(D3DRS_CULLMODE,   D3DCULL_NONE);
	}

	//使用平面着色模式(不进行插值)
    DEVICE.SetRenderState( D3DRS_SHADEMODE,    D3DSHADE_FLAT );

	//如果渲染阴影体到颜色缓冲区
	if(m_bIsRenderVolume)
	{
		DEVICE.SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		DEVICE.SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA );
		DEVICE.SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA );
	}
	else  //只更新深度模板缓冲区
	{
		DEVICE.SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		DEVICE.SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_ZERO );
		DEVICE.SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ONE );
	}

	//UINT uNumFaces = m_uNumShadowVertices / 3;

	DEVICE.SetTransform( D3DTS_WORLD, &m_Matrix);

	m_VertexBuffer.Activate(0, 0, true);

	//__Draw(0, uNumFaces);


	D3DXVECTOR3 LightPosition(LIGHTMANAGER.GetLight(0)->Position);

	D3DXMATRIX InverseWorldMatrix;
    D3DXMatrixInverse(&InverseWorldMatrix, NULL, &m_Matrix);

	D3DXVec3TransformCoord(&LightPosition, &LightPosition, &InverseWorldMatrix);

	D3DXVECTOR3  v1, v2, v3, v4;
    UINT i;
	bool bIsLightFacing;

	m_uDiscardVertices = m_uNumTriangles * 3 * 6;
	m_uFlushFaces = m_uDiscardVertices / 3;
	m_uFlushVertices = m_uFlushFaces * 3;

	UINT uStartVertex = 0, uNumVertices = 0;
	LPD3DXVECTOR3 pVertices;
	m_VertexBuffer.Lock(uStartVertex, m_uFlushVertices, D3DLOCK_DISCARD, (void**)&pVertices);

	for(i = 0; i < m_uNumEdges; i ++)
    {
		//v1 = CASE(m_pVertices[m_pEdges[i].v0], D3DXVECTOR3);
        //v2 = CASE(m_pVertices[m_pEdges[i].v1], D3DXVECTOR3);
		bIsLightFacing = m_pTriangles[m_pEdges[i].uTriangles[0]].bIsLightFacing;
		if( m_pEdges[i].bIsDegenerate ? !bIsLightFacing : (bIsLightFacing != m_pTriangles[m_pEdges[i].uTriangles[1]].bIsLightFacing) )
		{
			if(bIsLightFacing)
			{
				v2 = m_pVertices[m_pEdges[i].uVertices[0]].Position;
				v1 = m_pVertices[m_pEdges[i].uVertices[1]].Position;
			}
			else
			{
				v1 = m_pVertices[m_pEdges[i].uVertices[0]].Position;
				v2 = m_pVertices[m_pEdges[i].uVertices[1]].Position;
			}

			//D3DXVec3Normalize( &v3, &(v1 - LightPosition) );
			//D3DXVec3Normalize( &v4, &(v2 - LightPosition) );

			//v3 = v1 + v3 * 500.0f;
			//v4 = v2 + v4 * 500.0f;
			v3 = v1 - m_Extends;
			v4 = v2 - m_Extends;

			//添加矩形
			*pVertices ++ = v1;
			*pVertices ++ = v2;
			*pVertices ++ = v3;

			*pVertices ++ = v2;
			*pVertices ++ = v4;
			*pVertices ++ = v3;

			uNumVertices += 6;

			if(uNumVertices == m_uFlushVertices)
			{
				if( !m_VertexBuffer.Unlock() )
					return;

				__Draw(uStartVertex, m_uFlushFaces);

				uStartVertex += m_uFlushVertices;

				if(uStartVertex > m_uDiscardVertices)
					uStartVertex = 0;

				if( !m_VertexBuffer.Lock(uStartVertex, m_uFlushVertices, uStartVertex ? D3DLOCK_NOOVERWRITE : D3DLOCK_DISCARD, (void**)&pVertices) )
					return;

				uNumVertices = 0;
			}
		}
    }

	for(i = 0; i < m_uNumTriangles; i ++)
	{
		if(!m_pTriangles[i].bIsLightFacing)
		{
			*pVertices ++ = m_pVertices[m_pTriangles[i].v1].Position;
			*pVertices ++ = m_pVertices[m_pTriangles[i].v0].Position;
			*pVertices ++ = m_pVertices[m_pTriangles[i].v2].Position;
			
			uNumVertices += 3;

			*pVertices ++ = m_pVertices[m_pTriangles[i].v0].Position - m_Extends;
			*pVertices ++ = m_pVertices[m_pTriangles[i].v1].Position - m_Extends;
			*pVertices ++ = m_pVertices[m_pTriangles[i].v2].Position - m_Extends;

			uNumVertices += 3;
		}

		if(uNumVertices == m_uFlushVertices)
		{
			if( !m_VertexBuffer.Unlock() )
				return;

			__Draw(uStartVertex, m_uFlushFaces);

			uStartVertex += m_uFlushVertices;

			if(uStartVertex > m_uDiscardVertices)
				uStartVertex = 0;

			if( !m_VertexBuffer.Lock(uStartVertex, m_uFlushVertices, uStartVertex ? D3DLOCK_NOOVERWRITE : D3DLOCK_DISCARD, (void**)&pVertices) )
				return;

			uNumVertices = 0;
		}
	}

	if( !m_VertexBuffer.Unlock() )
		return;

	if(uNumVertices)
		__Draw(uStartVertex, uNumVertices / 3);

	//恢复渲染状态
	DEVICE.SetRenderState( D3DRS_SHADEMODE, D3DSHADE_GOURAUD );
    DEVICE.SetRenderState( D3DRS_CULLMODE,  D3DCULL_CCW );
    DEVICE.SetRenderState( D3DRS_ZWRITEENABLE,     TRUE );
    DEVICE.SetRenderState( D3DRS_STENCILENABLE,    FALSE );
    DEVICE.SetRenderState( D3DRS_ALPHABLENDENABLE, FALSE );

	if( TEST_FLAG(GAMEHOST.GetCaps().StencilCaps, D3DSTENCILCAPS_TWOSIDED) )
		DEVICE.SetRenderState(D3DRS_TWOSIDEDSTENCILMODE, FALSE);
}

void CShadowVolume::__Draw(zerO::UINT uStartVertex, zerO::UINT uPrimitiveCount)
{
	if( TEST_FLAG(GAMEHOST.GetCaps().StencilCaps, D3DSTENCILCAPS_TWOSIDED) )
	{
		DEVICE.DrawPrimitive(D3DPT_TRIANGLELIST, uStartVertex, uPrimitiveCount);

		return;
	}

	//渲染阴影体背面
	/*DEVICE.SetRenderState( D3DRS_CULLMODE,   D3DCULL_CW );
	DEVICE.SetRenderState( D3DRS_STENCILZFAIL, D3DSTENCILOP_INCR );

	DEVICE.SetFVF( D3DFVF_XYZ );
    DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLELIST, uNumFaces, m_pShadowVertices, sizeof(D3DXVECTOR3) );*/

	//渲染阴影体前面
	DEVICE.SetRenderState( D3DRS_CULLMODE,   D3DCULL_CCW );
	DEVICE.SetRenderState( /*D3DRS_STENCILZFAIL*/D3DRS_STENCILPASS,  /*D3DSTENCILOP_DECR*/D3DSTENCILOP_INCR );

	//DEVICE.SetFVF( D3DFVF_XYZ );
    //DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLELIST, uNumFaces, m_pShadowVertices, sizeof(D3DXVECTOR3) );
	DEVICE.DrawPrimitive(D3DPT_TRIANGLELIST, uStartVertex, uPrimitiveCount);

	//渲染阴影体背面
	DEVICE.SetRenderState( D3DRS_CULLMODE,   D3DCULL_CW );
	DEVICE.SetRenderState( D3DRS_STENCILPASS, D3DSTENCILOP_DECR );
	
	//DEVICE.SetFVF( D3DFVF_XYZ );
    //DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLELIST, uNumFaces, m_pShadowVertices, sizeof(D3DXVECTOR3) );
	DEVICE.DrawPrimitive(D3DPT_TRIANGLELIST, uStartVertex, uPrimitiveCount);
}

//-----------------------------------------------------------------------------
// Desc: 销毁阴影体
//-----------------------------------------------------------------------------
bool CShadowVolume::Destroy( )
{
	DEBUG_DELETE_ARRAY(m_pEdges);
	DEBUG_DELETE_ARRAY(m_pTriangles);
	DEBUG_DELETE_ARRAY(m_pVertices);

	//DEBUG_DELETE_ARRAY(m_pSourceVertices);

	m_pEdges          = NULL;
	m_pTriangles      = NULL;
	m_pVertices       = NULL;

	//m_pSourceVertices = NULL;

	m_CommonVertexMap.clear();
	m_CommonVertex.clear();

	return true;
}

