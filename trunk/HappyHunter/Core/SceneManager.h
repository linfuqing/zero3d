#pragma once

#include "Camera.h"

namespace zerO
{
	class CSceneManagerEntry :
		public CSceneNode
	{
		CSceneManagerEntry(void);
		~CSceneManagerEntry(void);

		CSceneManagerEntry* GetNext()const;
	protected:
		CSceneManagerEntry* m_pEntryForward;
		CSceneManagerEntry* m_pEntryRear;
	};

	inline CSceneManagerEntry* CSceneManagerEntry::GetNext()const
	{
		return m_pEntryForward;
	}

	class CSceneManager
	{
	public:
		CSceneManager(void);
		~CSceneManager(void);

		virtual bool Destroy();

		virtual CSceneNode* SearchObject(const CRectangle3D& WorldRectangle, const LPFRUSTUM pFrustum = NULL) = 0;

		virtual UINT32 AddObject(CSceneNode* pObject);

	private:
		CSceneNode m_Scene;
	};
}