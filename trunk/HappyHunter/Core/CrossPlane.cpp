#include "StdAfx.h"
#include "CrossPlane.h"
#include "Camera.h"

using namespace zerO;

CCrossPlane::CCrossPlane(void) :
m_fWidth(0.0f),
m_fHeight(0.0f),
m_uNumPlanes(0),
m_bIsCreated(false),
m_pVertexBuffer(NULL)
{
}

CCrossPlane::~CCrossPlane(void)
{
	Destroy();
}

void CCrossPlane::Clone(CCrossPlane& CrossPlane)const
{
	CSprite::Clone(CrossPlane);

	CrossPlane.m_pVertexBuffer = m_pVertexBuffer;

	m_RenderMethod.Clone(CrossPlane.m_RenderMethod);

	CrossPlane.m_uNumPlanes = m_uNumPlanes;

	CrossPlane.m_fWidth     = m_fWidth;
	CrossPlane.m_fHeight    = m_fHeight;
}

bool CCrossPlane::Create(zerO::FLOAT fWidth, zerO::FLOAT fHeight, zerO::UINT uNumPlanes, const D3DXVECTOR3* pCenter)
{
	m_fWidth      = fWidth;
	m_fHeight     = fHeight;
	m_uNumPlanes  = uNumPlanes;

	FLOAT fHalfWidth  = fWidth * 0.5f;
	FLOAT fHalfHeight = fHeight * 0.5f;

	FLOAT fOffsetAngle = D3DX_PI / uNumPlanes;

	D3DXVECTOR3 p0(- fHalfWidth, - fHalfHeight, 0.0f),
		p1(- fHalfWidth,   fHalfHeight, 0.0f),
		p2(  fHalfWidth, - fHalfHeight, 0.0f),
		p3(  fHalfWidth,   fHalfHeight, 0.0f);

	if(pCenter)
	{
		p0 += *pCenter;
		p1 += *pCenter;
		p2 += *pCenter;
		p3 += *pCenter;
	}

	D3DXMATRIX Matrix;

	D3DXMatrixRotationY(&Matrix, fOffsetAngle);

	LPPLANE pPlane;

	DEBUG_NEW(pPlane, PLANE[uNumPlanes]);

	for(UINT i = 0; i < uNumPlanes; i ++)
	{
		pPlane[i].Vertices[0].Position = p0;
		pPlane[i].Vertices[1].Position = p1;
		pPlane[i].Vertices[2].Position = p2;
		pPlane[i].Vertices[3].Position = p3;

		pPlane[i].Vertices[0].UV = D3DXVECTOR2(0.0f, 1.0f);
		pPlane[i].Vertices[1].UV = D3DXVECTOR2(0.0f, 0.0f);
		pPlane[i].Vertices[2].UV = D3DXVECTOR2(1.0f, 1.0f);
		pPlane[i].Vertices[3].UV = D3DXVECTOR2(1.0f, 0.0f);

		D3DXVec3TransformCoord(&p0, &p0, &Matrix);
		D3DXVec3TransformCoord(&p1, &p1, &Matrix);
		D3DXVec3TransformCoord(&p2, &p2, &Matrix);
		D3DXVec3TransformCoord(&p3, &p3, &Matrix);
	}

	DEBUG_NEW(m_pVertexBuffer, CVertexBuffer);

	if( !m_pVertexBuffer->Create(4 * uNumPlanes, sizeof(VERTEX), D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED, pPlane, D3DFVF_XYZ | D3DFVF_TEX1) )
		return false;

	DEBUG_DELETE_ARRAY(pPlane);

	m_bIsCreated = true;

	return true;
}

bool CCrossPlane::Destroy()
{
	if(m_bIsCreated)
	{
		DEBUG_DELETE(m_pVertexBuffer);

		m_pVertexBuffer = NULL;
	}

	return true;
}

void CCrossPlane::Update()
{
	CSprite::Update();
}

bool CCrossPlane::ApplyForRender()
{
	CEffect* pEffect = m_RenderMethod.GetEffect();

	if (pEffect)
	{
		UINT uTotalPass = pEffect->GetTechniqueDesc().Passes, i;

		for (i = 0; i < uTotalPass; i ++)
		{
			CRenderQueue::LPRENDERENTRY pRenderEntry = GAMEHOST.GetRenderQueue().LockRenderEntry();
			
			pRenderEntry->hEffect      = pEffect->GetHandle();
			pRenderEntry->hSurface     = m_RenderMethod.GetSurface()->GetHandle();
			pRenderEntry->uModelType   = CRenderQueue::RENDERENTRY::BUFFER_TYPE;
			pRenderEntry->hModel       = m_pVertexBuffer->GetHandle();
			pRenderEntry->uRenderPass  = i;
			pRenderEntry->pParent      = this;

			GAMEHOST.GetRenderQueue().UnLockRenderEntry(pRenderEntry);
		}

		return true;
	}

	return false;
}

void CCrossPlane::Render(CRenderQueue::LPRENDERENTRY pEntry, zerO::UINT32 uFlag)
{
	CEffect* pEffect = m_RenderMethod.GetEffect();
	
	if (pEffect)
	{	
		DEVICE.SetRenderState(D3DRS_ALPHATESTENABLE, TRUE);
		DEVICE.SetRenderState(D3DRS_ALPHAREF, 0x0000000);
		DEVICE.SetRenderState(D3DRS_ALPHAFUNC, D3DCMP_GREATER);

		DEVICE.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);

		if( TEST_BIT(uFlag, CRenderQueue::PARENT) )
			pEffect->SetMatrix( CEffect::WORLD_VIEW_PROJECTION, m_WorldMatrix * CAMERA.GetViewProjectionMatrix() );

		if( TEST_BIT(uFlag, CRenderQueue::MODEL) )
			m_pVertexBuffer->Activate(0, 0, true);

		if ( TEST_BIT(uFlag, CRenderQueue::SURFACE) )
			pEffect->SetSurface( m_RenderMethod.GetSurface() );

		pEffect->GetEffect()->CommitChanges();

		for(UINT i = 0; i < m_uNumPlanes; i ++)
			DEVICE.DrawPrimitive(D3DPT_TRIANGLESTRIP, i << 2, 2);

		DEVICE.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

		DEVICE.SetRenderState(D3DRS_ALPHATESTENABLE, FALSE);
	}
}