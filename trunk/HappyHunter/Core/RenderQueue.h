#pragma once

#include "GameHost.h"

namespace zerO
{
	class CSceneNode;

	///
	// ��Ⱦ���У��ṩ������Ⱦ��ˮ�������Ż�.
	// ����CSenceNode��������Ⱦ���л�ȡһ����Ⱦ��,�ȶ�����ʱ����д����Ⱦ��������Ż�������Ⱦ.
	///
	class CRenderQueue
	{
	public:

		typedef enum
		{
			//Ч���ļ�
			EFFECT = 0,
			//Ч��Pass
			EFFECT_PASS,
			//Ч������
			EFFECT_PARAM,
			//ϸ�ڲ��
			EFFECT_LOD,
			MODEL,
			MODEL_PARAMA,
			MODEL_PARAMB,
			SURFACE,
			PARENT,

			TOTAL_ACTIVATE_FLAGS
		}ACTIVATEFLAG;

		///
		// ��Ⱦ��ṹ��.
		///
		typedef struct RENDERENTRY
		{
			//�ڴ漯�л�
#pragma pack(1)
			union
			{
				struct
				{
					UINT32 uSortValueA;
					UINT32 uSortValueB;
					UINT32 uSortValueC;
				};

				struct
				{
					// uSortValueA
					UINT8 uDetailLevel: 4;	

					//ö��TYPE�е�ģ������.
					UINT8 uModelType  : 2;		
					UINT8 uBoneCount  : 2;

					UINT8 uRenderPass;			
					RESOURCEHANDLE hEffect;	

					// uSortValueB

					//�ڶ������㻺���ģ�Ϳ��
					UINT16 uModelParamA;	

					//��һ�����㻺���ģ�;��
					RESOURCEHANDLE hModel;		

					// uSortValueC
					RESOURCEHANDLE hSurface;	

					//���������ģ���Ӽ�
					UINT16 uModelParamB;		
				};
			};

			CSceneNode*	pParent;
			UINT32	uUserData;
#pragma pack()
			typedef enum
			{
				BUFFER_TYPE = 0,	
				MODEL_TYPE,		
				PARTICLE_TYPE
			}TYPE;

			void Clear()
			{
				uSortValueA = 0;
				uSortValueB = 0;
				uSortValueC = 0;
			}
		}RENDERENTRY, * LPRENDERENTRY;

		CRenderQueue(UINT uMaxRenderEntries);
		~CRenderQueue(void);

		bool Destroy();

		//������Ⱦ���д���Ⱦ��ػ�ȡһ����Ⱦ��.
		LPRENDERENTRY LockRenderEntry();

		//����������Ⱦ�������Ⱦ�б�����,
		void UnLockRenderEntry(LPRENDERENTRY pEntry);

		//�����Ⱦ�б�.
		void Reset();

		//��Ⱦ��Ⱦ�б��е���Ⱦ��.
		void Render();

	private:
		UINT m_uActiveEntries;
		UINT m_uMaxRenderEntries;

		bool m_bIsLockEntry;

		LPRENDERENTRY  m_pEntryPool;
		LPRENDERENTRY* m_ppEntryList;
	};

	inline void CRenderQueue::Reset()
	{
		m_uActiveEntries = 0;
	}
}
