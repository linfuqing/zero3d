#include "StdAfx.h"
#include "SceneManager.h"
#include "GameHost.h"

using namespace zerO;

CSceneManagerEntry::CSceneManagerEntry(void) :
//m_pTreeForward(NULL),
//m_pTreeRear(NULL),
m_pSearchForward(NULL),
m_pSearchRear(NULL)
{
}

CSceneManagerEntry::~CSceneManagerEntry(void)
{
}

CSceneManager::CSceneManager(void) :
m_Scene(CSceneNode::LOCK_ADDED | CSceneNode::LOCK_REMOVE_CHILD)
{
	GAMEHOST.AddSceneManager(*this);
}

CSceneManager::~CSceneManager(void)
{
	Destroy();
}

bool CSceneManager::Destroy()
{
	return true;
}

zerO::UINT32 CSceneManager::AddObject(CSceneManagerEntry* pObject)
{
	m_Scene.AddChild(pObject);

	return 0;
}
