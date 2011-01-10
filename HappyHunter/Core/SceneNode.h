#pragma once

#include <list>
#include "RenderQueue.h"
#include "Rectangle3D.h"

namespace zerO
{
	///
	// 资源场景节点,树结构.坐标系基类,所有坐标系实体都继承此类.
	///
	class CSceneNode
	{
	public:
		typedef enum
		{
			LOCK_NONE = 0,
			LOCK_ADD_CHILD,
			LOCK_REMOVE_CHILD,

			LOCK_ADDED,
			LOCK_REMOVED
		}LOCKTYPE;

		CSceneNode(UINT32 uFlag = LOCK_NONE);
		~CSceneNode(void);

		CSceneNode* GetParent()const;

		UINT32 GetLockChildrenFlag()const;

		//本地矩阵
		const D3DXMATRIX& GetLocalMatrix()const;
		//世界矩阵
		const D3DXMATRIX& GetWorldMatrix()const;
		//本地边界盒
		const CRectangle3D& GetLocalRectangle()const;
		//世界边界盒
		const CRectangle3D& GetWorldRectangle()const;

		bool GetVisible()const;

		void SetVisible(bool bValue);

		void Clone(CSceneNode& Node)const;

		// 加入子集.
		bool AddChild(CSceneNode* pChild);
		bool RemoveChild(CSceneNode* pChild);

		//void UpdateChildren();
		virtual void AddedToRenderQueue();

		//构建渲染块并加入到渲染队列中,由渲染队列自动调用本身渲染机制.
		virtual bool ApplyForRender();

		virtual void UpdateTransform();

		virtual bool Destroy();

		//渲染之外的所有变换更新,进行CPU计算.
		virtual void Update();

		//渲染机制,供子集重载
		virtual void Render(CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag);

	protected:
		//void _SetTransformDirty();

		bool m_bIsTransformDirty;
		bool m_bIsVisible;

		D3DXMATRIX m_LocalMatrix;
		D3DXMATRIX m_WorldMatrix;

		CSceneNode* m_pParent;

		CRectangle3D m_LocalRect;
		CRectangle3D m_WorldRect;
	private:
		//std::list<CSceneNode*> m_Children;
		CSceneNode* m_pPrevious;
		CSceneNode* m_pNext;
		CSceneNode* m_pChild;

		UINT32 m_uFlag;
	};

	inline CSceneNode* CSceneNode::GetParent()const
	{
		return m_pParent;
	}

	inline UINT32 CSceneNode::GetLockChildrenFlag()const
	{
		return m_uFlag;
	}

	inline const D3DXMATRIX& CSceneNode::GetLocalMatrix()const
	{
		return m_LocalMatrix;
	}

	inline const D3DXMATRIX& CSceneNode::GetWorldMatrix()const
	{
		return m_WorldMatrix;
	}

	inline const CRectangle3D& CSceneNode::GetLocalRectangle()const
	{
		return m_LocalRect;
	}

	inline const CRectangle3D& CSceneNode::GetWorldRectangle()const
	{
		return m_WorldRect;
	}

	inline bool CSceneNode::GetVisible() const
	{
		return m_bIsVisible;
	}

	inline void CSceneNode::SetVisible(bool bValue)
	{
		m_bIsVisible = bValue;
	}
}