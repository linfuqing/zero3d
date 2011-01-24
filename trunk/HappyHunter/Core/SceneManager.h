#pragma once

#include "Camera.h"

namespace zerO
{
	class CSceneManager;

	class CSceneManagerEntry :
		public CSceneNode
	{
		friend class CSceneManager;
	public:
		CSceneManagerEntry(void);
		~CSceneManagerEntry(void);

		CSceneManagerEntry* GetNext()const;

		void DetachFromSearchList();

	protected:

		CSceneManagerEntry* m_pSearchForward;
		CSceneManagerEntry* m_pSearchRear;
	};

	inline void CSceneManagerEntry::DetachFromSearchList()
	{
		if(m_pSearchForward)
			m_pSearchForward->m_pSearchRear = m_pSearchRear;

		if(m_pSearchRear)
			m_pSearchRear->m_pSearchForward = m_pSearchForward;

		m_pSearchForward = NULL;
		m_pSearchRear    = NULL;
	}

	inline CSceneManagerEntry* CSceneManagerEntry::GetNext()const
	{
		return m_pSearchForward;
	}

	class CSceneManager
	{
	public:
		CSceneManager(void);
		~CSceneManager(void);

		virtual bool Destroy();

		virtual CSceneManagerEntry* SearchObject(const CRectangle3D& WorldRectangle, const LPFRUSTUM pFrustum = NULL, CSceneManagerEntry** ppSearchListTail = NULL) = 0;

		virtual UINT32 AddObject(CSceneManagerEntry* pObject);

	protected:
		void _AttachToSearchListHead(CSceneManagerEntry* pEntry, CSceneManagerEntry* pHead);
		void _AttachToSearchListTail(CSceneManagerEntry* pEntry, CSceneManagerEntry* pTail);

	private:
		CSceneNode m_Scene;
	};

	inline void CSceneManager::_AttachToSearchListHead(CSceneManagerEntry* pEntry, CSceneManagerEntry* pHead)
	{
		if(pEntry)
		{
			if(pHead)
				pHead->m_pSearchRear = pEntry;

			pEntry->m_pSearchForward = pHead;
		}
	}

	inline void CSceneManager::_AttachToSearchListTail(CSceneManagerEntry* pEntry, CSceneManagerEntry* pTail)
	{
		if(pEntry)
		{
			if(pTail)
				pTail->m_pSearchForward = pEntry;

			pEntry->m_pSearchRear = pTail;
		}
	}
}