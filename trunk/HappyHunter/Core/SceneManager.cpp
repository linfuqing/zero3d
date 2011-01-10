#include "StdAfx.h"
#include "SceneManager.h"
#include "GameHost.h"

using namespace zerO;

CSceneManagerEntry::CSceneManagerEntry(void) :
m_pEntryForward(NULL),
m_pEntryRear(NULL)
{
}

CSceneManagerEntry::~CSceneManagerEntry(void)
{
}

CSceneManager::CSceneManager(void) :
m_Scene(CSceneNode::LOCK_ADDED | CSceneNode::LOCK_REMOVE_CHILD)
{
}

CSceneManager::~CSceneManager(void)
{
	Destroy();
}

bool CSceneManager::Destroy()
{
	return true;
}

zerO::UINT32 CSceneManager::AddObject(CSceneNode* pObject)
{
	m_Scene.AddChild(pObject);

	return 0;
}
