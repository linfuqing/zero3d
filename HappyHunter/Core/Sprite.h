#pragma once

#include "SceneNode.h"
#include "d3dutils.h"
#include "BitFlag.h"

namespace zerO
{
	class CSprite :
		public CSceneNode
	{
		typedef enum
		{
			ROTATION = 0,
			POSITION,
			SCALE,

			TRANSFORM,

			RIGHT,
			UP,
			FORWARD,

			WORLD_RIGHT,
			WORLD_UP,
			WORLD_FORWARD

		}DIRTYFLAG;
	public:
		CSprite(void);
		~CSprite(void);

		void SetTransform(const D3DXMATRIX& Matrix);

		void SetPosition(const D3DXVECTOR3& Position);
		void SetScale(const D3DXVECTOR3& Scale);
		void SetRotation(const D3DXVECTOR3& Rotation);

		void SetDirection(const D3DXVECTOR3& Direction);
		void SetSceneDirection(const D3DXVECTOR3& Direction);

		const D3DXVECTOR3& GetWorldRight();
		const D3DXVECTOR3& GetWorldUp();
		const D3DXVECTOR3& GetWorldForward();

		const D3DXVECTOR3& GetPosition();
		const D3DXVECTOR3& GetScale();
		const D3DXVECTOR3& GetRotation();

		void Clone(CSprite& Sprite)const;

		void Right(FLOAT fNumSteps);
		void Up(FLOAT fNumSteps);
		void Forward(FLOAT fNumSteps);

		void Update();

		void UpdateTransform();

	protected:
		D3DXVECTOR3 m_WorldRight;
		D3DXVECTOR3 m_WorldUp;
		D3DXVECTOR3 m_WorldForward;
		//D3DXVECTOR3 m_WorldPosition;

		D3DXVECTOR3 m_Position;
		D3DXVECTOR3 m_Rotation;
		D3DXVECTOR3 m_Scale;

		D3DXQUATERNION m_Quaternion;

		UINT32 m_uDirtyFlag;
	};

	inline void CSprite::SetTransform(const D3DXMATRIX& Matrix)
	{
		m_bIsTransformDirty = true;

		CLEAR_BIT(m_uDirtyFlag, TRANSFORM);

		SET_BIT(m_uDirtyFlag, ROTATION);
		SET_BIT(m_uDirtyFlag, POSITION);
		SET_BIT(m_uDirtyFlag, SCALE);

		SET_BIT(m_uDirtyFlag, RIGHT  );
		SET_BIT(m_uDirtyFlag, UP     );
		SET_BIT(m_uDirtyFlag, FORWARD);

		m_LocalMatrix = Matrix;
	}

	inline void CSprite::SetPosition(const D3DXVECTOR3& Position)
	{
		if( !TEST_BIT(m_uDirtyFlag, TRANSFORM) && TEST_BIT(m_uDirtyFlag, POSITION) )
		{
			D3DXMatrixDecompose(&m_Scale, &m_Quaternion, &m_Position, &m_LocalMatrix);

			CLEAR_MASK(m_uDirtyFlag, TRANSFORM);
		}

		m_Position = Position;

		SET_BIT(m_uDirtyFlag, TRANSFORM);
		SET_BIT(m_uDirtyFlag, POSITION);

		m_bIsTransformDirty = true;
	}

	inline void CSprite::SetScale(const D3DXVECTOR3& Scale)
	{
		if( !TEST_BIT(m_uDirtyFlag, TRANSFORM) && TEST_BIT(m_uDirtyFlag, SCALE) )
		{
			D3DXMatrixDecompose(&m_Scale, &m_Quaternion, &m_Position, &m_LocalMatrix);

			CLEAR_MASK(m_uDirtyFlag, TRANSFORM);
		}

		m_Scale = Scale;
		
		SET_BIT(m_uDirtyFlag, TRANSFORM);
		SET_BIT(m_uDirtyFlag, SCALE);

		m_bIsTransformDirty = true;
	}

	inline void CSprite::SetRotation(const D3DXVECTOR3& Rotation)
	{
		if( !TEST_BIT(m_uDirtyFlag, TRANSFORM) && TEST_BIT(m_uDirtyFlag, ROTATION) )
		{
			if( TEST_BIT(m_uDirtyFlag, POSITION) && TEST_BIT(m_uDirtyFlag, SCALE) )
				MatrixDecompose(&m_Scale, &m_Rotation, &m_Position, m_LocalMatrix);
			else
				QuaternionToEular(m_Rotation, m_Quaternion);

			CLEAR_MASK(m_uDirtyFlag, TRANSFORM);
		}

		m_Rotation = Rotation;

		SET_BIT(m_uDirtyFlag, TRANSFORM);
		SET_BIT(m_uDirtyFlag, ROTATION);

		m_bIsTransformDirty = true;
	}

	inline const D3DXVECTOR3& CSprite::GetWorldRight()
	{
		if( TEST_BIT(m_uDirtyFlag, WORLD_RIGHT) )
		{
			m_WorldRight.x   = m_WorldMatrix._11;
			m_WorldRight.y   = m_WorldMatrix._12;
			m_WorldRight.z   = m_WorldMatrix._13;

			if(m_WorldMatrix._14)
				m_WorldRight /= m_WorldMatrix._14;

			CLEAR_BIT(m_uDirtyFlag, WORLD_RIGHT);
		}

		return m_WorldRight;
	}

	inline const D3DXVECTOR3& CSprite::GetWorldUp()
	{
		if( TEST_BIT(m_uDirtyFlag, WORLD_UP) )
		{
			m_WorldUp.x      = m_WorldMatrix._21;
			m_WorldUp.y      = m_WorldMatrix._22;
			m_WorldUp.z      = m_WorldMatrix._23;

			if(m_WorldMatrix._24)
				m_WorldUp /= m_WorldMatrix._24;

			TEST_BIT(m_uDirtyFlag, WORLD_UP);
		}

		return m_WorldUp;
	}

	inline const D3DXVECTOR3& CSprite::GetWorldForward()
	{
		if( TEST_BIT(m_uDirtyFlag, WORLD_FORWARD) )
		{
			m_WorldForward.x = m_WorldMatrix._31;
			m_WorldForward.y = m_WorldMatrix._32;
			m_WorldForward.z = m_WorldMatrix._33;

			if(m_WorldMatrix._34)
				m_WorldForward /= m_WorldMatrix._34;

			TEST_BIT(m_uDirtyFlag, WORLD_FORWARD);
		}

		return m_WorldForward;
	}

	inline const D3DXVECTOR3& CSprite::GetPosition()
	{
		if( !TEST_BIT(m_uDirtyFlag, TRANSFORM) && TEST_BIT(m_uDirtyFlag, POSITION) )
		{
			D3DXMatrixDecompose(&m_Scale, &m_Quaternion, &m_Position, &m_LocalMatrix);

			CLEAR_MASK(m_uDirtyFlag, TRANSFORM);
		}

		return m_Position;
	}

	inline const D3DXVECTOR3& CSprite::GetScale()
	{
		if( !TEST_BIT(m_uDirtyFlag, TRANSFORM) && TEST_BIT(m_uDirtyFlag, SCALE) )
		{
			D3DXMatrixDecompose(&m_Scale, &m_Quaternion, &m_Position, &m_LocalMatrix);

			CLEAR_MASK(m_uDirtyFlag, TRANSFORM);
		}

		return m_Scale;
	}

	inline const D3DXVECTOR3& CSprite::GetRotation()
	{
		if( !TEST_BIT(m_uDirtyFlag, TRANSFORM) && TEST_BIT(m_uDirtyFlag, ROTATION) )
		{
			if( TEST_BIT(m_uDirtyFlag, POSITION) && TEST_BIT(m_uDirtyFlag, SCALE) )
				MatrixDecompose(&m_Scale, &m_Rotation, &m_Position, m_LocalMatrix);
			else
				QuaternionToEular(m_Rotation, m_Quaternion);

			CLEAR_MASK(m_uDirtyFlag, TRANSFORM);
		}

		return m_Rotation;
	}
}
