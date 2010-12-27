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
		CSceneNode(void);
		~CSceneNode(void);

		CSceneNode* GetParent()const;

		//���ؾ���
		const D3DXMATRIX& GetLocalMatrix()const;
		//�������
		const D3DXMATRIX& GetWorldMatrix()const;
		//���ر߽��
		const CRectangle3D& GetLocalRectangle()const;
		//����߽��
		const CRectangle3D& GetWorldRectangle()const;

		void Clone(CSceneNode& Node)const;

		// �����Ӽ�.
		void AddChild(CSceneNode* pChild);
		void RemoveChild(CSceneNode* pChild);

		void UpdateChildren();

		//������Ⱦ�鲢���뵽��Ⱦ������,����Ⱦ�����Զ����ñ�����Ⱦ����.
		virtual bool ApplyForRender();

		virtual void UpdateTransform();

		virtual bool Destroy();

		//��Ⱦ֮������б任����,����CPU����.
		virtual void Update();

		//��Ⱦ����,���Ӽ�����
		virtual void Render(CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag);

	protected:
		void _SetTransformDirty();

		bool m_bIsTransformDirty;

		D3DXMATRIX m_LocalMatrix;
		D3DXMATRIX m_WorldMatrix;

		CSceneNode* m_pParent;

		CRectangle3D m_LocalRect;
		CRectangle3D m_WorldRect;
	private:
		std::list<CSceneNode*> m_Children;
	};

	inline CSceneNode* CSceneNode::GetParent()const
	{
		return m_pParent;
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
}