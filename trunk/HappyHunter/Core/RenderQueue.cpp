#include "StdAfx.h"
#include "RenderQueue.h"
#include "basicutils.h"
#include "SceneNode.h"
#include "Effect.h"
#include "BitFlag.h"

using namespace zerO;

CRenderQueue::CRenderQueue(zerO::UINT uMaxRenderEntries) :
m_uMaxRenderEntries(uMaxRenderEntries),
m_uActiveEntries(0),
m_bIsLockEntry(false)
{
	DEBUG_NEW(m_pEntryPool, RENDERENTRY[uMaxRenderEntries]);
	DEBUG_NEW(m_ppEntryList, LPRENDERENTRY[uMaxRenderEntries]);
}

CRenderQueue::~CRenderQueue(void)
{
	Destroy();
}

bool CRenderQueue::Destroy()
{
	DEBUG_DELETE_ARRAY(m_pEntryPool);
	DEBUG_DELETE_ARRAY(m_ppEntryList);

	m_pEntryPool  = NULL;
	m_ppEntryList = NULL;

	return true;
}

CRenderQueue::LPRENDERENTRY CRenderQueue::LockRenderEntry()
{
	if (m_uActiveEntries + 1 >= m_uMaxRenderEntries)
		Render();

	LPRENDERENTRY pEntry = &m_pEntryPool[m_uActiveEntries];

	pEntry->Clear();

	return pEntry;
}

void CRenderQueue::UnLockRenderEntry(CRenderQueue::LPRENDERENTRY pEntry)
{
	m_ppEntryList[m_uActiveEntries ++] = pEntry;
}

bool IsWrap(
		const CRenderQueue::LPRENDERENTRY& Source, 
		const CRenderQueue::LPRENDERENTRY& Target)
{
	return Source->uSortValueA == Target->uSortValueA ? (Source->uSortValueB == Target->uSortValueB ? 
		(Source->uSortValueC == Target->uSortValueC ? false : Source->uSortValueC > Target->uSortValueC) :
		Source->uSortValueB > Target->uSortValueB) : Source->uSortValueA > Target->uSortValueA;
};

void CRenderQueue::Render()
{
	if(m_uActiveEntries)
	{	
		Sort<LPRENDERENTRY>(m_ppEntryList, m_ppEntryList, m_uActiveEntries, IsWrap);

		UINT32 uFlags = 0xffffffff;

		CEffect* pEffect;

		LPRENDERENTRY pCurrentEntry = m_ppEntryList[0], pPreviousEntry = NULL;

		if(pCurrentEntry->hEffect)
		{
			pEffect = dynamic_cast<CEffect*>( GAMEHOST.GetResource(pCurrentEntry->hEffect, RESOURCE_EFFECT) );

			pEffect->Active(pCurrentEntry->uRenderPass);
		}

		pCurrentEntry->pParent->Render(
			pCurrentEntry, 
			uFlags);

		for (UINT i = 1; i < m_uActiveEntries; i ++)
		{
			pCurrentEntry  = m_ppEntryList[i];
			pPreviousEntry = m_ppEntryList[i - 1];

			uFlags = 0;

			if (pPreviousEntry->hEffect != pCurrentEntry->hEffect)
			{
				if(pPreviousEntry->hEffect)
				{
					pEffect = dynamic_cast<CEffect*>( GAMEHOST.GetResource(pPreviousEntry->hEffect, RESOURCE_EFFECT) );

					pEffect->End();
				}

				if(pCurrentEntry->hEffect)
				{
					pEffect = dynamic_cast<CEffect*>( GAMEHOST.GetResource(pCurrentEntry->hEffect, RESOURCE_EFFECT) );

					pEffect->Active(pCurrentEntry->uRenderPass);
				}

				SET_BIT(uFlags, EFFECT);
				SET_BIT(uFlags, EFFECT_PASS);
				SET_BIT(uFlags, EFFECT_PARAM);
			}
			else if (pPreviousEntry->uRenderPass != pCurrentEntry->uRenderPass)
			{
				if(pPreviousEntry->hEffect)
				{
					pEffect = dynamic_cast<CEffect*>( GAMEHOST.GetResource(pPreviousEntry->hEffect, RESOURCE_EFFECT) );

					pEffect->EndPass();
				}

				if(pCurrentEntry->hEffect)
				{
					pEffect = dynamic_cast<CEffect*>( GAMEHOST.GetResource(pCurrentEntry->hEffect, RESOURCE_EFFECT) );

					pEffect->BeginPass(pCurrentEntry->uRenderPass);
				}

				SET_BIT(uFlags, EFFECT_PASS);
				SET_BIT(uFlags, EFFECT_PARAM);
			}		
			else 
			{
				if (pPreviousEntry->uBoneCount != pCurrentEntry->uBoneCount)
					SET_BIT(uFlags, EFFECT_PARAM);	
				if (pPreviousEntry->uDetailLevel != pCurrentEntry->uDetailLevel)
					SET_BIT(uFlags, EFFECT_LOD);
			}

			if (pPreviousEntry->hModel != pCurrentEntry->hModel || pPreviousEntry->uModelType != pCurrentEntry->uModelType)
			{
				SET_BIT(uFlags, MODEL);
				SET_BIT(uFlags, MODEL_PARAMA);
				SET_BIT(uFlags, MODEL_PARAMB);
			}
			else 
			{
				if (pPreviousEntry->uModelParamA != pCurrentEntry->uModelParamA)
					SET_BIT(uFlags, MODEL_PARAMA);
				if (pPreviousEntry->uModelParamB != pCurrentEntry->uModelParamB)
					SET_BIT(uFlags, MODEL_PARAMB);	
			}

			if(pPreviousEntry->hSurface != pCurrentEntry->hSurface)
				SET_BIT(uFlags, SURFACE);

			if(pPreviousEntry->pParent != pCurrentEntry->pParent)
				SET_BIT(uFlags, PARENT);

			pCurrentEntry->pParent->Render(pCurrentEntry, uFlags);
		}

		if(m_ppEntryList[m_uActiveEntries - 1]->hEffect)
		{
			pEffect = dynamic_cast<CEffect*>( GAMEHOST.GetResource(m_ppEntryList[m_uActiveEntries - 1]->hEffect, RESOURCE_EFFECT) );

			pEffect->End();
		}
	}
	
	m_uActiveEntries = 0;
}