#include "StdAfx.h"
#include "SceneNode.h"
#include "GameHost.h"

using namespace zerO;

CSceneNode::CSceneNode(zerO::UINT32 uFlag) :
m_uFlag(uFlag),
m_pParent(NULL), 
m_pChild(NULL),
m_pPrevious(NULL),
m_pNext(NULL),
m_bIsTransformDirty(false)
{
	D3DXMatrixIdentity(&m_LocalMatrix);
	D3DXMatrixIdentity(&m_WorldMatrix);

	if( CGameHost::IsGameHostCreated() )
		GAMEHOST.GetScene().AddChild(this);
}

CSceneNode::~CSceneNode(void)
{
	Destroy();
}

bool CSceneNode::Destroy()
{
	//m_Children.clear();

	return true;
}


bool CSceneNode::AddChild(CSceneNode* pChild)
{
	if(pChild == NULL || pChild == this)
		return false;

	if( TEST_FLAG(m_uFlag, LOCK_ADD_CHILD) || TEST_FLAG(pChild->m_uFlag, LOCK_ADDED) )
		return false;

	if( pChild->m_pParent && !pChild->m_pParent->RemoveChild(pChild) )
		return false;

	//m_Children.push_back(pChild);
	if(m_pChild)
		m_pChild->m_pPrevious = pChild;

	pChild->m_pParent = this;

	pChild->m_pNext = m_pChild;

	//pChild->_SetTransformDirty();

	m_pChild = pChild;

	pChild->m_bIsTransformDirty = true;

	return true;
}

bool CSceneNode::RemoveChild(CSceneNode* pChild)
{
	if(pChild == NULL)
		return false;

	if( TEST_FLAG(m_uFlag, LOCK_REMOVE_CHILD) || TEST_FLAG(pChild->m_uFlag, LOCK_REMOVED) )
		return false;

	if(pChild->m_pParent != this)
		return false;
	//m_Children.remove(pChild);
	if(m_pChild == pChild)
		m_pChild = pChild->m_pNext;
	else if(pChild->m_pPrevious)
		pChild->m_pPrevious->m_pNext = pChild->m_pNext;
	else
		return false;

	pChild->m_pParent   = NULL;
	pChild->m_pPrevious = NULL;
	pChild->m_pNext     = NULL;

	//pChild->_SetTransformDirty();
	pChild->m_bIsTransformDirty = true;

	return true;
}

/*void CSceneNode::UpdateChildren()
{
	for(std::list<CSceneNode*>::const_iterator i = m_Children.begin(); i != m_Children.end(); i ++)
	{
		(*i)->Update();
		(*i)->UpdateChildren();
	}
}*/

/*void CSceneNode::_SetTransformDirty()
{
	m_bIsTransformDirty = true;

	for(std::list<CSceneNode*>::const_iterator i =  m_Children.begin(); i != m_Children.end(); i ++)
		(*i)->_SetTransformDirty();
}*/

void CSceneNode::UpdateTransform()
{
	//m_bIsTransformDirty = false;

	if(m_pParent)
		D3DXMatrixMultiply(&m_WorldMatrix, &m_LocalMatrix, &m_pParent->m_WorldMatrix);
	else
		m_WorldMatrix = m_LocalMatrix;

	m_WorldRect = m_LocalRect;

	m_WorldRect.Transform(m_WorldMatrix);
}

void CSceneNode::UpdateViewSpace()
{
	CSceneNode* pNode = m_pChild;

	while(pNode)
	{
		pNode->UpdateViewSpace();

		pNode = pNode->m_pNext;
	}
}

void CSceneNode::Update()
{
	if(m_bIsTransformDirty)
		UpdateTransform();

	CSceneNode* pNode = m_pChild;

	if(m_bIsTransformDirty)
	{
		while(pNode)
		{
			pNode->m_bIsTransformDirty = true;

			pNode = pNode->m_pNext;
		}

		pNode = m_pChild;
	}

	while(pNode)
	{
		pNode->Update();

		pNode = pNode->m_pNext;
	}

	m_bIsTransformDirty = true;
}

void CSceneNode::Clone(CSceneNode& Node)const
{
	//for(std::list<CSceneNode*>::const_iterator i =  m_Children.begin(); i != m_Children.end(); i ++)
	//	Node.m_Children.push_back(*i);

	Node.m_LocalMatrix = m_LocalMatrix;
	Node.m_WorldMatrix = m_WorldMatrix;
	Node.m_LocalRect   = m_LocalRect;
	Node.m_WorldRect   = m_WorldRect;

	Node.m_bIsTransformDirty = m_bIsTransformDirty;
}

void CSceneNode::AddedToRenderQueue()
{
	CSceneNode* pNode = m_pChild;

	while(pNode)
	{
		pNode->ApplyForRender();

		pNode = pNode->m_pNext;
	}

	ApplyForRender();
}

bool CSceneNode::ApplyForRender()
{
	return true;
}

void CSceneNode::Render(CRenderQueue::LPRENDERENTRY pEntry, zerO::UINT32 uFlag)
{
}