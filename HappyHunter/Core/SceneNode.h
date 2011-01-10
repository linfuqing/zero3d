#pragma once

#include <list>
#include "RenderQueue.h"
#include "Rectangle3D.h"

namespace zerO
{
	///
	// ��Դ�����ڵ�,���ṹ.����ϵ����,��������ϵʵ�嶼�̳д���.
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

		//���ؾ���
		const D3DXMATRIX& GetLocalMatrix()const;
		//�������
		const D3DXMATRIX& GetWorldMatrix()const;
		//���ر߽��
		const CRectangle3D& GetLocalRectangle()const;
		//����߽��
		const CRectangle3D& GetWorldRectangle()const;

		bool GetVisible()const;

		void SetVisible(bool bValue);

		void Clone(CSceneNode& Node)const;

		// �����Ӽ�.
		bool AddChild(CSceneNode* pChild);
		bool RemoveChild(CSceneNode* pChild);

		//void UpdateChildren();
		virtual void AddedToRenderQueue();

		//������Ⱦ�鲢���뵽��Ⱦ������,����Ⱦ�����Զ����ñ�����Ⱦ����.
		virtual bool ApplyForRender();

		virtual void UpdateTransform();

		virtual bool Destroy();

		//��Ⱦ֮������б任����,����CPU����.
		virtual void Update();

		//��Ⱦ����,���Ӽ�����
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