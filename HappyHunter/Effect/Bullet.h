#pragma once
#include "particlesystem.h"

namespace zerO
{
	///
	// �ӵ�����
	// Velocity: ���ٶ�
	// Rectangle: ��Χ��
	///
	typedef struct BULLETPARAMETERS
	{
		D3DXVECTOR3 Velocity;
		CRectangle3D Rectangle;
		D3DXVECTOR3* pOldData;
		UINT uOldDataLength;
		UINT uOldDataIndex;
		bool bIsFree;

		BULLETPARAMETERS() :
		pOldData(NULL),
			uOldDataLength(0)
		{
		}

		~BULLETPARAMETERS()
		{
			DEBUG_DELETE_ARRAY(pOldData);
		}
	}BULLETPARAMETERS;


	///
	//�ӵ���
	///
	class CBullet : 
		public CParticleSystem<BULLETPARAMETERS>
	{
	public:
		typedef enum
		{
			RANDOM_CUBE,
			RANDOM_CIRCLE
		}OFFSETTYPE;

		CBullet(void);
		~CBullet(void);

		//�ӵ����ٶ�
		FLOAT GetSpeed()const;

		//�ӵ��ܵ�������
		FLOAT GetGravity()const;

		//ƫ�ư뾶,�������,�������ð뾶�ڽ�������ĳ�ʼλ�õ��趨(���ӵ����ڲ�ͬλ�ó���)
		FLOAT GetOffsetRadius()const;

		//�ӵ��Ĵ�С
		FLOAT GetSize()const;

		OFFSETTYPE GetOffsetType()const;

		//���е�����(�����ȴ����),���һ���Է�������ӵ�
		UINT  GetMaxinumNumber()const;

		//β�͵��ܶ�
		UINT  GetStep()const;

		//β�͵Ķ���,����Խ��,β��Խ��.
		UINT  GetLength()const;

		//�ӳ�ʼλ�÷ɳ�ȥʱ���ӵ��ļ��ٶ�
		const D3DXVECTOR3& GetAcceleration()const;

		//�ӵ�����λ��
		const D3DXVECTOR3& GetSource()const;

		//�ӵ�����
		const D3DXVECTOR3& GetDirection()const;

		void SetSpeed(FLOAT fSpeed);
		void SetGravity(FLOAT fGravity);
		void SetOffsetRadius(FLOAT fOffsetRadius);
		void SetSize(FLOAT fSize);

		void SetOffsetType(OFFSETTYPE Type);

		void SetMaxinumNumber(UINT uMaxNum);
		void SetStep(UINT uStep);
		void SetLength(UINT uLength);

		void SetSource(const D3DXVECTOR3& Source);
		void SetDirection(const D3DXVECTOR3& Direction);

		LPPARTICLE FindHitParticle(const CRectangle3D Rect)const;

		bool FreeHitParticle(const CRectangle3D Rect)const;

		///
		// ���
		///
		void Shoot();

		///
		// ��������
		// uMaxNum  ���еĴ�С,ÿ������ܷ�������ӵ�
		// uFlush   ÿ����Ⱦ���������
		// uDiscard Buffer������
		// fSize    ���ӵĴ�С
		// ����     �ɹ�����true, ʧ�ܷ���false.
		///
		bool Create(UINT uMaxNum, UINT uFlush, UINT uDiscard, FLOAT fSize);

		void Update();

		void Render(CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag);
	private:
		void __BuildAcceleration();

		FLOAT m_fSpeed;
		FLOAT m_fGravity;
		FLOAT m_fOffsetRadius;

		OFFSETTYPE m_OffsetType;

		UINT  m_uStep;
		UINT  m_uLength;

		D3DXVECTOR3 m_Acceleration;
		D3DXVECTOR3 m_Source;
		D3DXVECTOR3 m_Direction;

		bool m_bIsAccelerationDirty;
	};

	inline FLOAT CBullet::GetSpeed()const
	{
		return m_fSpeed;
	}

	inline FLOAT CBullet::GetGravity()const
	{
		return m_fGravity;
	}

	inline FLOAT CBullet::GetOffsetRadius()const
	{
		return m_fOffsetRadius;
	}

	inline FLOAT CBullet::GetSize()const
	{
		return m_fPointSize;
	}

	inline CBullet::OFFSETTYPE CBullet::GetOffsetType()const
	{
		return m_OffsetType;
	}

	inline UINT CBullet::GetMaxinumNumber()const
	{
		return m_uMaxNumParticles;
	}

	inline UINT CBullet::GetStep()const
	{
		return m_uStep;
	}

	inline UINT CBullet::GetLength()const
	{
		return m_uLength;
	}

	inline const D3DXVECTOR3& CBullet::GetAcceleration()const
	{
		return m_Acceleration;
	}

	inline const D3DXVECTOR3& CBullet::GetSource()const
	{
		return m_Source;
	}

	inline const D3DXVECTOR3& CBullet::GetDirection()const
	{
		return m_Direction;
	}

	inline void CBullet::SetSpeed(FLOAT fSpeed)
	{
		m_fSpeed = fSpeed;

		m_bIsAccelerationDirty = true;
	}

	inline void CBullet::SetGravity(FLOAT fGravity)
	{
		m_fGravity = fGravity;
	}

	inline void CBullet::SetOffsetRadius(FLOAT fOffsetRadius)
	{
		m_fOffsetRadius = fOffsetRadius;
	}

	inline void CBullet::SetSize(FLOAT fSize)
	{
		m_fPointSize = fSize;
	}

	inline void CBullet::SetOffsetType(OFFSETTYPE Type)
	{
		m_OffsetType = Type;
	}

	inline void CBullet::SetMaxinumNumber(UINT uMaxNum)
	{
		m_uMaxNumParticles = uMaxNum;
	}

	inline void CBullet::SetStep(UINT uStep)
	{
		m_uStep = uStep;
	}

	inline void CBullet::SetLength(UINT uLength)
	{
		m_uLength = uLength;
	}

	inline void CBullet::SetSource(const D3DXVECTOR3& Source)
	{
		m_Source = Source;
	}

	inline void CBullet::SetDirection(const D3DXVECTOR3& Direction)
	{
		m_Direction = Direction;

		m_bIsAccelerationDirty = true;
	}

	inline void CBullet::Shoot()
	{
		m_uNumEmitedPerFrame = 1;
	}

	inline void CBullet::__BuildAcceleration()
	{
		D3DXVec3Normalize(&m_Direction, &m_Direction);

		m_Acceleration = m_Direction;

		m_Acceleration *= m_fSpeed;
	}
}
