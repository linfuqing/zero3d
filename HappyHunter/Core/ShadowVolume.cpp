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
m_fLength(0.0f)
{
	D3DXMatrixIdentity(&m_Matrix);
}

CShadowVolume::~CShadowVolume(void)
{
	Destroy();
}

//-----------------------------------------------------------------------------
// Desc: ������Ӱ��
//-----------------------------------------------------------------------------
bool CShadowVolume::Create(zerO::UINT uNumVertices, zerO::UINT uNumTriangles, CSceneNode& Parent, zerO::UINT uVertexSize, void* pVertices, void* pIndices)
{
	m_uNumVertices  = uNumVertices;
	m_uNumTriangles = uNumTriangles;

	m_pParent       = &Parent;

	//Ϊ��Ӱ�嶥�����洢�ռ�
	DEBUG_NEW(m_pShadowVertices, D3DXVECTOR3[m_uNumTriangles * 3 * 6]);
	DEBUG_NEW(m_pEdges         , EDGE       [m_uNumTriangles * 3    ]);
	DEBUG_NEW(m_pTriangles     , TRIANGLE   [m_uNumTriangles        ]);

	SetMeshData( (PUINT8)pVertices, (PUINT16)pIndices, uVertexSize );

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
		Mesh.GetNumBytesPerVertex(),
		pVertices,
		pIndices);
}

void CShadowVolume::SetMeshData(zerO::PUINT8 pVertices, zerO::PUINT16 pIndices, zerO::UINT uVertexSize)
{
	m_pVertices   = pVertices;
	m_pIndices    = pIndices;

	m_uVertexSize = uVertexSize;

	if(!pVertices || !pIndices)
		return;

	zerO::UINT i0, i1, i2, i, j = 0;

	D3DXVECTOR3 v0, v1, v2;

	//��������ģ�͵�ÿ����(������), ������ģ�͵���������ӵ���ʱ���б���
    for(i = 0; i < m_uNumTriangles; i ++)
    {
		//��ǰ���������������
        i0 = pIndices[j ++] * uVertexSize;
        i1 = pIndices[j ++] * uVertexSize;
        i2 = pIndices[j ++] * uVertexSize;

		v0 = CASE(pVertices[i0], D3DXVECTOR3);
		v1 = CASE(pVertices[i1], D3DXVECTOR3);
		v2 = CASE(pVertices[i2], D3DXVECTOR3);

		//���ݶ���������ȡ��ǰ���������������
        m_pTriangles[i].v0 = i0;
        m_pTriangles[i].v1 = i1;
        m_pTriangles[i].v2 = i2;

        D3DXVec3Cross( &m_pTriangles[i].Normal, &(v2 - v1), &(v1 - v0) );
    }
}

void CShadowVolume::SetMeshData(ID3DXMesh& Mesh)
{
	void* pVertices, *pIndices;

	Mesh.LockVertexBuffer( 0L, (LPVOID*)&pVertices );
    Mesh.LockIndexBuffer( 0L, (LPVOID*)&pIndices );

	SetMeshData( (PUINT8)pVertices, (PUINT16)pIndices, Mesh.GetNumBytesPerVertex() );

	Mesh.UnlockVertexBuffer();
    Mesh.UnlockIndexBuffer();
}

//-----------------------------------------------------------------------------
// Desc: ��������ģ�ͺ͹�Դλ�ù�����Ӱ��
//       ���ȼ������ģ�͵�ÿ��������, ������ģ�͵������߱��浽һ����ʱ�б���.
//       Ȼ����������ߺ͹�Դλ�ù�����Ӱ��
//-----------------------------------------------------------------------------
void CShadowVolume::Update()
{
	if(!m_bIsVisible)
		return;

	D3DXMatrixIdentity(&m_Matrix);

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

	D3DXVECTOR3 Extend = LightPosition * 500, Max, Min;

	if(Extend.x < 0.0f)
	{
		Min.x = m_pParent->GetWorldRectangle().GetMinX();
		Max.x = m_pParent->GetWorldRectangle().GetMaxX() - Extend.x;
	}
	else
	{
		Min.x = m_pParent->GetWorldRectangle().GetMinX() - Extend.x;
		Max.x = m_pParent->GetWorldRectangle().GetMaxX();
	}

	if(Extend.y < 0.0f)
	{
		Min.y = m_pParent->GetWorldRectangle().GetMinY();
		Max.y = m_pParent->GetWorldRectangle().GetMaxY() - Extend.y;
	}
	else
	{
		Min.y = m_pParent->GetWorldRectangle().GetMinY() - Extend.y;
		Max.y = m_pParent->GetWorldRectangle().GetMaxY();
	}

	if(Extend.z < 0.0f)
	{
		Min.z = m_pParent->GetWorldRectangle().GetMinZ();
		Max.z = m_pParent->GetWorldRectangle().GetMaxZ() - Extend.z;
	}
	else
	{
		Min.z = m_pParent->GetWorldRectangle().GetMinZ() - Extend.z;
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

	m_uNumEdges = 0;

	D3DXVECTOR3  v1, v2, v3, v4;
    DWORD i;

	m_uNumShadowVertices = 0;
    //��������ģ�͵�ÿ����(������), ������ģ�͵���������ӵ���ʱ���б���
    for(i = 0; i < m_uNumTriangles; i ++)
    {
		//�����ǰ���Ǳ�����, �򽫵�ǰ���������"���"�����б�
        if( D3DXVec3Dot(&m_pTriangles[i].Normal, &LightPosition) < 0.0f )
        {
			__AddEdge(m_pTriangles[i].v0, m_pTriangles[i].v1);
            __AddEdge(m_pTriangles[i].v1, m_pTriangles[i].v2);
            __AddEdge(m_pTriangles[i].v2, m_pTriangles[i].v0);

			/*v1 = CASE(m_pVertices[m_pTriangles[i].v0], D3DXVECTOR3);
			v2 = CASE(m_pVertices[m_pTriangles[i].v1], D3DXVECTOR3);
			v3 = CASE(m_pVertices[m_pTriangles[i].v2], D3DXVECTOR3);

			m_pShadowVertices[m_uNumShadowVertices ++] = v2;
			m_pShadowVertices[m_uNumShadowVertices ++] = v1;
			m_pShadowVertices[m_uNumShadowVertices ++] = v3;

			m_pShadowVertices[m_uNumShadowVertices ++] = v1 - Extend;
			m_pShadowVertices[m_uNumShadowVertices ++] = v2 - Extend;
			m_pShadowVertices[m_uNumShadowVertices ++] = v3 - Extend;*/
        }
    }

	//��Ա����ÿ��������, ���һ������, ���еľ��ι�����Ӱ��
    for(i = 0; i < m_uNumEdges; i ++)
    {
		//������ε��ĸ��Ķ���
        v1 = CASE(m_pVertices[m_pEdges[i].v0], D3DXVECTOR3);
        v2 = CASE(m_pVertices[m_pEdges[i].v1], D3DXVECTOR3);
        v3 = v1 - Extend;
        v4 = v2 - Extend;

		//��Ӿ���
        m_pShadowVertices[m_uNumShadowVertices ++] = v1;
        m_pShadowVertices[m_uNumShadowVertices ++] = v2;
        m_pShadowVertices[m_uNumShadowVertices ++] = v3;

        m_pShadowVertices[m_uNumShadowVertices ++] = v2;
        m_pShadowVertices[m_uNumShadowVertices ++] = v4;
        m_pShadowVertices[m_uNumShadowVertices ++] = v3;
    }
}


//-----------------------------------------------------------------------------
// Desc: ������ӵ��б���
//-----------------------------------------------------------------------------
void CShadowVolume::__AddEdge(zerO::UINT v0, zerO::UINT v1 )
{
	//����ɾ���ڲ��ı�(�ڱ��б��г������εı�)
    for(UINT i=0; i < m_uNumEdges; i++ )
    {
        if( (m_pEdges[i].v0 == v0 && m_pEdges[i].v1 == v1) ||
            (m_pEdges[i].v0 == v1 && m_pEdges[i].v0 == v0) )
        {
            if(m_uNumEdges > 1)
            {
                m_pEdges[i].v0 = m_pEdges[m_uNumEdges-1].v0;
                m_pEdges[i].v1 = m_pEdges[m_uNumEdges-1].v1;
            }

            m_uNumEdges--;

            return;
        }
    }

	//�ڱ��б������һ���±�
    m_pEdges[m_uNumEdges].v0 = v0;
    m_pEdges[m_uNumEdges].v1 = v1;

    m_uNumEdges ++;
}

//-----------------------------------------------------------------------------
// Desc: ��Ⱦ��Ӱ��, ֻ����ģ�建����, ��������ɫ������
//-----------------------------------------------------------------------------
void CShadowVolume::Render()
{
	if(!m_bIsVisible || m_bIsCulled)
		return;

	//����z������д����, ������ģ�建����
    DEVICE.SetRenderState( D3DRS_ZWRITEENABLE,  FALSE );
    DEVICE.SetRenderState( D3DRS_STENCILENABLE, TRUE );

	//ʹ��ƽ����ɫģʽ(�����в�ֵ)
    DEVICE.SetRenderState( D3DRS_SHADEMODE,    D3DSHADE_FLAT );

	//�����Ⱦ��Ӱ�嵽��ɫ������
	if(m_bIsRenderVolume)
	{
		DEVICE.SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		DEVICE.SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA );
		DEVICE.SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA );
	}
	else  //ֻ�������ģ�建����
	{
		DEVICE.SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		DEVICE.SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_ZERO );
		DEVICE.SetRenderState( D3DRS_DESTBLEND, D3DBLEND_ONE );
	}

	UINT uNumFaces = m_uNumShadowVertices / 3;

	
	DEVICE.SetRenderState( D3DRS_STENCILFUNC,  D3DCMP_ALWAYS );

	DEVICE.SetTransform( D3DTS_WORLD, &m_Matrix);

	//��Ⱦ��Ӱ�屳��
	/*DEVICE.SetRenderState( D3DRS_CULLMODE,   D3DCULL_CW );
	DEVICE.SetRenderState( D3DRS_STENCILZFAIL, D3DSTENCILOP_INCR );

	DEVICE.SetFVF( D3DFVF_XYZ );
    DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLELIST, uNumFaces, m_pShadowVertices, sizeof(D3DXVECTOR3) );*/

	//��Ⱦ��Ӱ��ǰ��
	DEVICE.SetRenderState( D3DRS_CULLMODE,   D3DCULL_CCW );
	DEVICE.SetRenderState( /*D3DRS_STENCILZFAIL*/D3DRS_STENCILPASS,  /*D3DSTENCILOP_DECR*/D3DSTENCILOP_INCR );

	DEVICE.SetFVF( D3DFVF_XYZ );
    DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLELIST, uNumFaces, m_pShadowVertices, sizeof(D3DXVECTOR3) );

	//��Ⱦ��Ӱ�屳��
	DEVICE.SetRenderState( D3DRS_CULLMODE,   D3DCULL_CW );
	DEVICE.SetRenderState( D3DRS_STENCILPASS, D3DSTENCILOP_DECR );
	
	DEVICE.SetFVF( D3DFVF_XYZ );
    DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLELIST, uNumFaces, m_pShadowVertices, sizeof(D3DXVECTOR3) );

	//�ָ���Ⱦ״̬
	DEVICE.SetRenderState( D3DRS_SHADEMODE, D3DSHADE_GOURAUD );
    DEVICE.SetRenderState( D3DRS_CULLMODE,  D3DCULL_CCW );
    DEVICE.SetRenderState( D3DRS_ZWRITEENABLE,     TRUE );
    DEVICE.SetRenderState( D3DRS_STENCILENABLE,    FALSE );
    DEVICE.SetRenderState( D3DRS_ALPHABLENDENABLE, FALSE );
}


//-----------------------------------------------------------------------------
// Desc: ������Ӱ��
//-----------------------------------------------------------------------------
bool CShadowVolume::Destroy( )
{
	DEBUG_DELETE_ARRAY(m_pShadowVertices);
	DEBUG_DELETE_ARRAY(m_pEdges);
	DEBUG_DELETE_ARRAY(m_pTriangles);

	m_pShadowVertices = NULL;
	m_pEdges          = NULL;
	m_pTriangles      = NULL;

	return true;
}

