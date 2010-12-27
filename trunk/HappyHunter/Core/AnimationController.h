#pragma once

#include "Resource.h"

namespace zerO
{
	class CAnimationController :
		public CResource
	{
	public:
		CAnimationController(void);
		~CAnimationController(void);

		bool Create(const LPD3DXANIMATIONCONTROLLER pAnimationController);
		bool Destroy(); 
		bool Disable(); 
		bool Restore();

		void Update();

		LPD3DXANIMATIONCONTROLLER GetAnimationController()const;

		// ͨ�������趨����
		void SetAnimation( UINT index, DWORD dwControlPlayTime = 0, bool bSmooth = true, FLOAT fSmoothTranstionTime = 0.25f );
		// ͨ�������趨����
		void SetAnimationByName( LPSTR pName, DWORD dwControlPlayTime = 0, bool bSmooth = true, FLOAT fSmoothTranstionTime = 0.25f );
		// ����ƽ������
		void AnimationChangeSmooth(LPD3DXANIMATIONSET pAnimSet, FLOAT fSmoothTranstionTime = 0.25f);
		// �õ���ǰ���ڲ��ŵĶ����Ĳ��Ŵ���
		UINT GetPlayTime();
		// �����ƻ�ȡ����ID
		UINT GetAnimIndex( char sString[] );
		// �����Ƿ��ܲ���
		bool CanPlay(LPSTR pName, DWORD count);

	private:
		LPD3DXANIMATIONCONTROLLER	m_pAnimController;
		bool						m_bPlayAnim;
		
		UINT						m_uCurrentTrack;		// ��ǰ����
		FLOAT						m_fTimeCurrent;			// ��ǰʱ��	
		UINT						m_uPlayTime;			// ��ǰ�������Ŵ���	
		FLOAT						m_fFrameTime;			// ��ǰ��������ʱ��	
		FLOAT64						m_lfTotalFrameTime;		// ��ǰ�����ܲ���ʱ��
		UINT						m_uControlPlayTime;		// ��ǰ�����趨���Ŵ���(0Ϊ�ظ�����)��
		char						m_szASName[64];			// ��������
		std::string					m_strNowAnimSetName;	// ��ǰ��������
	};

	inline LPD3DXANIMATIONCONTROLLER CAnimationController::GetAnimationController()const
	{
		return m_pAnimController;
	}
}
