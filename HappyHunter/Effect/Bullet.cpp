#include "StdAfx.h"
#include "Bullet.h"

using namespace zerO;

CBullet::CBullet(void) :
m_fSpeed(0.0f),
m_fGravity(0.0f),
m_fOffsetRadius(0),

m_uStep(1),
m_uLength(0),

m_Acceleration(0.0f, 0.0f, 0.0f),
m_Source(0.0f, 0.0f, 0.0f),
m_Direction(0.0f, 0.0f, 1.0f),

m_bIsAccelerationDirty(false)
{
}

CBullet::~CBullet(void)
{
}

///
// ���ӳ�ʼ��
///
void InitParticle(CParticleSystem<BULLETPARAMETERS>::LPPARTICLE pParticle)
{
	CBullet* pParent = (CBullet*)pParticle->pPARENT;

	pParticle->Parameter.bIsFree = false;

	pParticle->Parameter.Velocity = pParent->GetAcceleration();

	pParticle->Vertex.Color       = D3DXCOLOR(1.0f, 1.0f, 1.0f, 1.0f);

	pParticle->Vertex.Position    = pParent->GetSource();

	zerO::FLOAT fOffsetRadius      = pParent->GetOffsetRadius();

	if(fOffsetRadius)
	{
		switch( pParent->GetOffsetType() )
		{
		case CBullet::RANDOM_CUBE:
			pParticle->Vertex.Position.x += ( (zerO::FLOAT)rand() ) / RAND_MAX * fOffsetRadius - fOffsetRadius * 0.5f;
			pParticle->Vertex.Position.y += ( (zerO::FLOAT)rand() ) / RAND_MAX * fOffsetRadius - fOffsetRadius * 0.5f;
			pParticle->Vertex.Position.z += ( (zerO::FLOAT)rand() ) / RAND_MAX * fOffsetRadius - fOffsetRadius * 0.5f;
			break;

		case CBullet::RANDOM_CIRCLE:
			zerO::FLOAT fRandom = (zerO::FLOAT)rand() / RAND_MAX, fSin = sin(fRandom), fCos = cos(fRandom);
			pParticle->Vertex.Position.x += fOffsetRadius * fCos - fOffsetRadius * 0.5f;
			pParticle->Vertex.Position.y += fOffsetRadius * fSin - fOffsetRadius * 0.5f;
			break;
		}
	}

	pParticle->Parameter.Rectangle.Extract( pParticle->Vertex.Position, pParent->GetSize() );

	if( pParticle->Parameter.uOldDataLength != pParent->GetStep() )
	{
		DEBUG_DELETE_ARRAY(pParticle->Parameter.pOldData);

		DEBUG_NEW(pParticle->Parameter.pOldData, D3DXVECTOR3[pParent->GetStep()]);

		pParticle->Parameter.uOldDataLength = pParent->GetStep();
	}

	for(zerO::UINT i = 0; i < pParticle->Parameter.uOldDataLength; i ++)
		pParticle->Parameter.pOldData[i] = pParticle->Vertex.Position;

	pParticle->Parameter.uOldDataIndex = 0;
}

///
// ���Ӹ���
///
void UpdateParticle(CParticleSystem<BULLETPARAMETERS>::LPPARTICLE pParticle)
{
	CBullet* pParent = (CBullet*)pParticle->pPARENT;

	pParticle->Parameter.Velocity.y -= pParent->GetGravity();

	pParticle->Vertex.Position      += pParticle->Parameter.Velocity;

	pParticle->Parameter.Rectangle.Extract( pParticle->Vertex.Position, pParent->GetSize() );

	pParticle->Parameter.uOldDataIndex = pParticle->Parameter.uOldDataIndex < pParticle->Parameter.uOldDataLength ? pParticle->Parameter.uOldDataIndex : 0;

	pParticle->Parameter.pOldData[pParticle->Parameter.uOldDataIndex ++] = pParticle->Vertex.Position;
}

///
// ���������ж�
///
bool IsParticleDestroy(CParticleSystem<BULLETPARAMETERS>::LPPARTICLE pParticle)
{
	return !pParticle->Parameter.Rectangle.TestHit( CAMERA.GetWorldRectangle() ) || pParticle->Parameter.bIsFree;//pParticle->Vertex.Position.y < - 100.0f;
}

//D3DXVECTOR3 g_Position;
//D3DXVECTOR3 g_Velocity;

zerO::INT g_nIndex;
zerO::INT g_nOldIndex;
zerO::UINT g_uLength;

D3DXVECTOR3 g_CurrentOffset;
D3DXVECTOR3 g_OffsetPerStep;

///
// ������Ⱦǰ��Ϊ
// ����:����������Ⱦ����
///
zerO::UINT GetParticleRenderSteps(const CParticleSystem<BULLETPARAMETERS>::PARTICLE& Particle)
{
	CBullet* pParent = (CBullet*)Particle.pPARENT;

	//g_Position = Particle.Vertex.Position;
	//g_Velocity = Particle.Parameter.Velocity / (zerO::FLOAT)pParent->GetStep() * 3;// * (pParent->GetLength() + 1.0f);

	g_nIndex    = Particle.Parameter.uOldDataIndex - 1;

	g_nIndex    = g_nIndex < 0 ? Particle.Parameter.uOldDataLength - 1 : g_nIndex;

	g_nOldIndex = g_nIndex - 1;

	g_nOldIndex = g_nOldIndex < 0 ? Particle.Parameter.uOldDataLength - 1 : g_nOldIndex;

	g_uLength = 0;

	return Particle.Parameter.uOldDataLength * (pParent->GetLength() + 1);/*pParent->GetStep();*/
}

///
// ������Ⱦ
///
bool SetParticleRenderData(const CParticleSystem<BULLETPARAMETERS>::PARTICLE& Particle, CParticleSystem<BULLETPARAMETERS>::PARTICLEVERTEX& Vertex)
{
	CBullet* pParent = (CBullet*)Particle.pPARENT;

	if(g_uLength == 0)
	{
		g_CurrentOffset = D3DXVECTOR3(0.0f, 0.0f, 0.0f);
		g_OffsetPerStep = 
			(Particle.Parameter.pOldData[g_nOldIndex]
		- Particle.Parameter.pOldData[g_nIndex]) / (pParent->GetLength() + 1.0f);
	}

	Vertex.Position = Particle.Parameter.pOldData[g_nIndex] + g_CurrentOffset;
	Vertex.Color    = Particle.Vertex.Color;

	if( g_uLength < pParent->GetLength() )
	{
		g_CurrentOffset += g_OffsetPerStep;

		g_uLength ++;
	}
	else
	{
		g_uLength = 0;

		g_nIndex --;
		
		g_nIndex    = g_nIndex < 0 ? Particle.Parameter.uOldDataLength - 1 : g_nIndex;

		g_nOldIndex = g_nIndex - 1;

		g_nOldIndex = g_nOldIndex < 0 ? Particle.Parameter.uOldDataLength - 1 : g_nOldIndex;
	}

	return true;
}

CParticleSystem<BULLETPARAMETERS>::LPPARTICLE CBullet::FindHitParticle(const CRectangle3D Rect)const
{
	PARTICLENODE* pParticle = m_pParticles;

	while(pParticle)
	{
		if( pParticle->Particle.Parameter.Rectangle.TestHit(Rect) )
			return &pParticle->Particle;

		pParticle = pParticle->pNext;
	}

	return NULL;
}

bool CBullet::FreeHitParticle(const CRectangle3D Rect)const
{
	bool bResult = false;

	PARTICLENODE* pParticle = m_pParticles;

	while(pParticle)
	{
		if( pParticle->Particle.Parameter.Rectangle.TestHit(Rect) )
		{
			pParticle->Particle.Parameter.bIsFree = true;

			bResult = true;
		}

		pParticle = pParticle->pNext;
	}

	return bResult;
}

///
// ��������
// uMaxNum  ���еĴ�С,ÿ������ܷ�������ӵ�
// uFlush   ÿ����Ⱦ���������
// uDiscard Buffer������
// fSize    ���ӵĴ�С
// ����     �ɹ�����true, ʧ�ܷ���false.
///
bool CBullet::Create(zerO::UINT uMaxNum, zerO::UINT uFlush, zerO::UINT uDiscard, zerO::FLOAT fSize)
{
	D3DCAPS9 Caps;

	DEVICE.GetDeviceCaps(&Caps);

	if( !zerO::CParticleSystem<BULLETPARAMETERS>::Create(
		0, uMaxNum, uFlush, uDiscard, fSize, Caps.MaxPointSize, 0.0f, 0.0f, 0.0f, 1.0f, 
		InitParticle, UpdateParticle, IsParticleDestroy, GetParticleRenderSteps, SetParticleRenderData) )
		return false;

	 return true;
}

void CBullet::Update()
{
	if(m_bIsAccelerationDirty)
	{
		__BuildAcceleration();

		m_bIsAccelerationDirty = false;
	}

	CParticleSystem<BULLETPARAMETERS>::Update();

	m_uNumEmitedPerFrame = 0;
}

void CBullet::Render(CRenderQueue::LPRENDERENTRY pEntry, zerO::UINT32 uFlag)
{
	/*DEVICE.SetRenderState(D3DRS_ZWRITEENABLE, false            );
	DEVICE.SetRenderState(D3DRS_ALPHABLENDENABLE, true         );
	DEVICE.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA   );
	DEVICE.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);*/
	DEVICE.SetRenderState(D3DRS_ALPHATESTENABLE, TRUE);
	DEVICE.SetRenderState(D3DRS_ALPHAREF, 0x0000000);
	DEVICE.SetRenderState(D3DRS_ALPHAFUNC, D3DCMP_GREATER);

	CParticleSystem::Render(pEntry, uFlag);

	/*DEVICE.SetRenderState(D3DRS_ALPHABLENDENABLE, false        );
	DEVICE.SetRenderState(D3DRS_ZWRITEENABLE    , true         );*/

	DEVICE.SetRenderState(D3DRS_ALPHATESTENABLE, FALSE);
}