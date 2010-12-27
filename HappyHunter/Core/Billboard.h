#pragma once

#include "Sprite.h"
#include "VertexBuffer.h"
#include "RenderMethod.h"

namespace zerO
{
	class CBillboard :
		public CSprite
	{
		typedef struct
		{
			D3DXVECTOR3 Position;
			D3DXVECTOR2 UV;
		}VERTEX;
	public:
		typedef enum
		{
			UNLOCK = 0,
			LOCK_XYZ
		}LOCKTYPE;

		CBillboard(void);
		~CBillboard(void);

		void SetLocalType(LOCKTYPE Type);

		CRenderMethod& GetRenderMethod();

		void SetupAnimation(UINT uFramesPerAnimation, UINT uLength);

		void Play(UINT uIndex = 0, INT nTimes = 0, FLOAT fFPS = 24.0f);
		void Stop();
		void Pause();

		void Clone(CBillboard& Billboard)const;

		bool Create(FLOAT fWidth, FLOAT fHeight, const D3DXVECTOR3* pCenter = NULL);

		bool Destroy();

		void Update();

		bool ApplyForRender();

		void Render(CRenderQueue::LPRENDERENTRY pEntry, UINT32 uFlag);

	private:
		FLOAT          m_fWidth;
		FLOAT          m_fHeight;
		FLOAT          m_fOffsetU;
		FLOAT          m_fOffsetV;

		FLOAT          m_fTime;
		FLOAT          m_fSecondPerFrame;

		UINT           m_uTimesU;
		UINT           m_uTimesV;

		CRectangle2D   m_CurrentUV;
		CRectangle2D   m_MaxUV;

		bool           m_bIsPlay;
		bool           m_bIsCreated;

		LOCKTYPE       m_LockType;

		VERTEX         m_RenderData[4];
		CVertexBuffer* m_pVertexBuffer;
		CRenderMethod  m_RenderMethod;
	};

	inline void CBillboard::SetLocalType(LOCKTYPE Type)
	{
		m_LockType = Type;
	}

	inline CRenderMethod& CBillboard::GetRenderMethod()
	{
		return m_RenderMethod;
	}

	inline void CBillboard::SetupAnimation(UINT uFramesPerAnimation, UINT uLength)
	{
		m_fOffsetU = 1.0f / uFramesPerAnimation;
		m_fOffsetV = 1.0f / uLength;

		m_MaxUV.Set(0.0f, 1.0f, 0.0f, m_fOffsetV);
	}

	inline void CBillboard::Play(UINT uIndex, INT nTimes, FLOAT fFPS)
	{
		m_bIsPlay         = true;

		m_fSecondPerFrame = 1.0f / fFPS;
		m_fTime           = m_fSecondPerFrame;

		m_uTimesU         = nTimes < - 1 ? 0 : (UINT)(nTimes + 1);

		if(uIndex)
		{
			m_MaxUV.Set(0.0f, 1.0f, m_fOffsetV * (uIndex - 1), m_fOffsetV * uIndex);
			m_CurrentUV.Set(0.0f, m_fOffsetU, 0.0f, m_fOffsetV); 
		}
	}

	inline void CBillboard::Stop()
	{
		m_uTimesU = 1;

		m_CurrentUV.Set(0.0f, m_fOffsetU, 0.0f, m_fOffsetV);
	}

	inline void CBillboard::Pause()
	{
		m_bIsPlay = false;
	}
}
