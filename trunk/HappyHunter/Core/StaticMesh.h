#pragma once

#include "debug.h"
#include "BasicString.h"
#include "Sprite.h"
#include "RenderMethod.h"
#include "Mesh.h"
#include "ShadowVolume.h"

namespace zerO
{
	class CStaticMesh : public CSprite
	{
	public:
		CStaticMesh(void);
		~CStaticMesh(void);

	public:
		CMesh& GetMesh();

		void SetShadowVisible(bool bValue);

		bool Create(const PBASICCHAR meshFile);
		bool Destroy();

		void Clone(CStaticMesh& StaticMesh)const;

		virtual bool ApplyForRender();
		virtual void Update();
		virtual void Render(CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag);

		void SetEffectFile(const BASICSTRING& file);

		const BASICSTRING& GetEffectFile() const;
		const CRenderMethod& GetRenderMethod() const;

	private:
		CRenderMethod			m_RenderMethod;		// ��Ⱦ����
		BASICSTRING				m_strEffectFile;	// Ч���ļ�
		CMesh*                  m_pMesh;
		CShadowVolume*          m_pShadow;

		bool                    m_bIsCreated;
		bool                    m_bIsVisibleShadow;
		bool                    m_bIsCulled;
	};

	//---------------------------------------------------------------------------
	// ���ú���
	//---------------------------------------------------------------------------

	inline void CStaticMesh::SetEffectFile(const BASICSTRING& file)
	{
		m_strEffectFile = file;
	}
		
	inline const BASICSTRING& CStaticMesh::GetEffectFile() const
	{
		return m_strEffectFile;
	}

	//---------------------------------------------------------------------------
	// ��ȡ����
	//---------------------------------------------------------------------------

	inline CMesh& CStaticMesh::GetMesh()
	{
		return *m_pMesh;
	}

	inline const CRenderMethod& CStaticMesh::GetRenderMethod() const
	{
		return m_RenderMethod;
	}

	inline void CStaticMesh::SetShadowVisible(bool bValue)
	{
		m_bIsVisibleShadow = bValue;
	}
}
