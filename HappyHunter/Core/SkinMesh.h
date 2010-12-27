#pragma once

#include "debug.h"
#include "BasicString.h"
#include "Effect.h"
#include "Texture.h"
#include "Sprite.h"
#include "RenderMethod.h"
#include "Model.h"

namespace zerO
{
	class CSkinMesh : public CSprite
	{
	public:
		CSkinMesh();
		virtual ~CSkinMesh();

	public:
		CModel* GetModel()const;

		void SetShadowVisible(bool bValue);

		void Clone(CSkinMesh& SkinMesh)const;

		bool Create(const PBASICCHAR fileName);
		bool Create(CModel* const pModel);
		bool Destroy();
		bool ApplyForRender();
		void Update();
		void Render(CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag);

		void SetEffectFile(const BASICSTRING& file);

		const BASICSTRING& GetEffectFile() const;
		CEffect* GetEffect() const;
		
		LPD3DXMESH GetMesh()const;

		//// ͨ�������趨����
		//void SetAnimation( UINT index, DWORD dwControlPlayTime = 0, bool bSmooth = true );
		//// ͨ�������趨����
		//void SetAnimationByName( LPSTR pName, DWORD dwControlPlayTime = 0, bool bSmooth = true );
		//// ����ƽ������
		//void AnimationChangeSmooth(LPD3DXANIMATIONSET pAnimSet);
		//// �õ���ǰ���ڲ��ŵĶ����Ĳ��Ŵ���
		//DWORD GetPlayTime();
		//// �����ƻ�ȡ����ID
		//DWORD GetAnimIndex( char sString[] );
		//// �����Ƿ��ܲ���
		//bool CanPlay(LPSTR pName, DWORD count);

	private:
		void __ApplyForRenderFrame(LPD3DXFRAME pFrame);
		void __ApplyForRenderMeshContainer(LPD3DXMESHCONTAINER pMeshContainerBase, LPD3DXFRAME pFrameBase);

		VOID __DrawFrame( LPD3DXFRAME pFrame, CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag );
		VOID __DrawMeshContainer( LPD3DXMESHCONTAINER pMeshContainerBase, LPD3DXFRAME pFrameBase, CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag );

		void __Draw(CRenderQueue::LPRENDERENTRY pEntry, zerO::UINT32 uFlag);

		CEffect*					m_pEffect;
		CModel*                     m_pModel;
		BASICSTRING					m_strEffectFile;		// Ч���ļ�

		bool                        m_bIsCreated;
		bool                        m_bIsVisibleShadow;
	};

	//---------------------------------------------------------------------------
	// ���ú���
	//---------------------------------------------------------------------------

	inline void CSkinMesh::SetEffectFile(const BASICSTRING& file)
	{
		m_strEffectFile = file;
	}
		
	inline const BASICSTRING& CSkinMesh::GetEffectFile() const
	{
		return m_strEffectFile;
	}

	//---------------------------------------------------------------------------
	// ��ȡ����
	//---------------------------------------------------------------------------

	inline CEffect* CSkinMesh::GetEffect() const
	{ 
		return m_pEffect;
	}

	inline CModel* CSkinMesh::GetModel()const
	{
		return m_pModel;
	}

	inline void CSkinMesh::SetShadowVisible(bool bValue)
	{
		m_bIsVisibleShadow = bValue;
	}
}