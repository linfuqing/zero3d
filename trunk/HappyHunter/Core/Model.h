#pragma once
#include "Resource.h"
#include "Surface.h"
#include "ShadowVolume.h"
#include "SceneNode.h"

namespace zerO
{
	//-----------------------------------------------------------------------------
	// Desc: �̳���DXDXFRAME�ṹ�Ľṹ
	//-----------------------------------------------------------------------------
	typedef struct MODELFRAME: public D3DXFRAME
	{
		D3DXMATRIXA16 CombinedTransformationMatrix;
		UINT          uIndex;
	}MODELFRAME, * LPMODELFRAME;

	//-----------------------------------------------------------------------------
	// Desc: �̳���D3DXMESHCONTAINER�ṹ�Ľṹ
	//-----------------------------------------------------------------------------
	typedef struct MODELCONTAINER: public D3DXMESHCONTAINER
	{
		CShadowVolume*       pShadow;
		UINT                 uIndex;
		LPMODELFRAME         pParent;
		PUINT8               puMeshBuffer;
		D3DXVECTOR3*         pTangentBuffer;
		D3DXVECTOR3*         pTangentInfo;
		PUINT                puNumBoneInfluences;
		LPDWORD*             ppdwVerticesIndices;
		PFLOAT*              ppfWeights;
		CSurface*            pSurfaces; 
		LPD3DXMESH           pOrigMesh;             //ԭ����
		LPD3DXATTRIBUTERANGE pAttributeTable;
		DWORD                NumAttributeGroups;    //��������
		DWORD                NumInfl;               //ÿ������������Ӱ����ٹ���
		LPD3DXBUFFER         pBoneCombinationBuf;   //������ϱ�
		D3DXMATRIX**         ppBoneMatrixPtrs;      //��Ź�������ϱ任����
		D3DXMATRIX*          pBoneOffsetMatrices;   //��Ź����ĳ�ʼ�任����
		DWORD                NumPaletteEntries;     //�ж��ٹ�������ʹ��(����)
		bool                 UseSoftwareVP;         //��ʶ�Ƿ�ʹ��������㴦��
	}MODELCONTAINER, * LPMODELCONTAINER;

	//-----------------------------------------------------------------------------
	// Desc: ����������.X�ļ����ؿ�ܲ�κ�����ģ������
	//-----------------------------------------------------------------------------
	class CAllocateHierarchy: public ID3DXAllocateHierarchy
	{
	private:
		HRESULT __AllocateName( LPCSTR Name, LPSTR *pNewName );
		HRESULT __GenerateSkinnedMesh(MODELCONTAINER *pMeshContainer);
		HRESULT __GenerateDeclMesh(MODELCONTAINER *pMeshContainer);

	public:
		typedef enum
		{
			HARDWARE,
			SOFTWARE
		}TYPE;

		UINT GetFramesNumber()const;
		UINT GetContainersNumber()const;
		TYPE GetType()const;

		STDMETHOD(CreateFrame)(THIS_ LPCSTR Name, LPD3DXFRAME *ppNewFrame);
		STDMETHOD(CreateMeshContainer)( THIS_ LPCSTR              Name, 
			CONST D3DXMESHDATA*       pMeshData,
			CONST D3DXMATERIAL*       pMaterials, 
			CONST D3DXEFFECTINSTANCE* pEffectInstances, 
			DWORD                     NumMaterials, 
			CONST DWORD *             pAdjacency, 
			LPD3DXSKININFO pSkinInfo, 
			LPD3DXMESHCONTAINER *ppNewMeshContainer);    
		STDMETHOD(DestroyFrame)(THIS_ LPD3DXFRAME pFrameToFree);
		STDMETHOD(DestroyMeshContainer)(THIS_ LPD3DXMESHCONTAINER pMeshContainerBase);

		CAllocateHierarchy(void);
		~CAllocateHierarchy(void);

	private:
		BASICCHAR					m_strFilePath[MAX_PATH];
		D3DXMATRIXA16*              m_pBoneMatrices;
		UINT                        m_NumBoneMatricesMax;
		UINT                        m_uNumContainers;
		TYPE                        m_Type;
		bool                        m_bIsShadow;
		CSceneNode*                 m_pParent;

		friend class CModel;
	};

	inline UINT CAllocateHierarchy::GetContainersNumber()const
	{
		return m_uNumContainers;
	}

	inline CAllocateHierarchy::TYPE CAllocateHierarchy::GetType()const
	{
		return m_Type;
	}

	///
	// ģ��:��������,��D3DXFRAME��D3DXMESHCONTAINER��װ.
	///
	class CModel :
		public CResource
	{
	public:
		CModel(void);
		~CModel(void);

		LPD3DXFRAME GetFrameRoot()const;

		LPMODELFRAME GetModelFrame(UINT uIndex)const;
		LPMODELCONTAINER GetModelContainer(UINT uIndex)const;

		LPD3DXMATRIX GetBoneMatrices()const;

		const CRectangle3D& GetRectangle()const;

		CAllocateHierarchy& GetAllocateHierarchy();

		bool Destroy(); 
		bool Disable(); 
		bool Restore();

		bool Create(const PBASICCHAR pcFileName, CSceneNode* pParent);

		bool Load(const PBASICCHAR pcFileName = NULL);

		void Update(FLOAT fElapsedAppTime);
		void Update(const LPD3DXMATRIX pMatrix);

		// ͨ�������趨����
		void SetAnimation( UINT index, DWORD dwControlPlayTime = 0, bool bSmooth = true );
		// ͨ�������趨����
		void SetAnimationByName( LPSTR pName, DWORD dwControlPlayTime = 0, bool bSmooth = true );
		// ����ƽ������
		void AnimationChangeSmooth(LPD3DXANIMATIONSET pAnimSet);
		// �õ���ǰ���ڲ��ŵĶ����Ĳ��Ŵ���
		UINT GetPlayTime();
		// �����ƻ�ȡ����ID
		UINT GetAnimIndex( char sString[] );
		// �����Ƿ��ܲ���
		bool CanPlay(LPSTR pName, DWORD count);
	private:
		bool __SetupFrame( LPD3DXFRAME pFrame );
		bool __SetupMeshContainer( LPD3DXMESHCONTAINER pMeshContainerBase );

		void __UpdateFrame(LPD3DXFRAME pFrameBase, const LPD3DXMATRIX pParentMatrix);

		void __ReleaseFrame(LPD3DXFRAME pFrame);

		CAllocateHierarchy			m_Alloc;
		LPD3DXFRAME					m_pFrameRoot;
		LPD3DXANIMATIONCONTROLLER	m_pAnimController;
		bool						m_bPlayAnim;
		
		UINT						m_uCurrentTrack;		// ��ǰ����
		FLOAT						m_fTimeCurrent;			// ��ǰʱ��	
		UINT						m_uPlayTime;			// ��ǰ�������Ŵ���	
		FLOAT						m_fFrameTime;			// ��ǰ��������ʱ��	
		FLOAT64						m_lfTotalFrameTime;		// ��ǰ�����ܲ���ʱ��
		UINT						m_uControlPlayTime;	// ��ǰ�����趨���Ŵ���(0Ϊ�ظ�����)��
		char						m_szASName[64];			// ��������
		std::string					m_strNowAnimSetName;	// ��ǰ��������

		LPMODELCONTAINER*           m_ppContainers;
		UINT                        m_uNumContainers;
		CRectangle3D                m_Rectangle;
	};

	inline LPD3DXFRAME CModel::GetFrameRoot()const
	{
		return m_pFrameRoot;
	}

	inline LPD3DXMATRIX CModel::GetBoneMatrices()const
	{
		return m_Alloc.m_pBoneMatrices;
	}

	inline LPMODELCONTAINER CModel::GetModelContainer(UINT uIndex)const
	{
		if( m_ppContainers && uIndex < m_Alloc.GetContainersNumber() )
			return m_ppContainers[uIndex];

		return NULL;
	}

	inline CAllocateHierarchy& CModel::GetAllocateHierarchy()
	{
		return m_Alloc;
	}

	inline const CRectangle3D& CModel::GetRectangle()const
	{
		return m_Rectangle;
	}
}
