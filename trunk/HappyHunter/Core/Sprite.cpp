#include "StdAfx.h"
#include "Sprite.h"
#include "d3dutils.h"

using namespace zerO;

CSprite::CSprite(void) :
m_WorldRight(1.0f, 0.0f, 0.0f),
m_WorldUp(0.0f, 1.0f, 0.0f),
m_WorldForward(0.0f, 0.0f, 1.0f),

m_Position(0.0f, 0.0f, 0.0f),
m_Rotation(0.0f, 0.0f, 0.0f),
m_Scale(1.0f, 1.0f, 1.0f),
m_uDirtyFlag(0xffffffff)
{
}

CSprite::~CSprite(void)
{
}

void CSprite::Clone(CSprite& Sprite)const
{
	CSceneNode::Clone(Sprite);

	Sprite.m_Position   = m_Position;
	Sprite.m_Rotation   = m_Rotation;
	Sprite.m_Scale      = m_Scale;
	Sprite.m_uDirtyFlag = m_uDirtyFlag;
}

void CSprite::SetDirection(const D3DXVECTOR3& Direction)
{
	D3DXVECTOR3 Rotation(0.0f, 0.0f, m_Rotation.z);

	DirectionToRotation(Rotation.x, Rotation.y, Direction);

	SetRotation(Rotation);
}

void CSprite::SetSceneDirection(const D3DXVECTOR3& Direction)
{
	SetDirection( D3DXVECTOR3(- Direction.x, - Direction.y, - Direction.z) );
}

void CSprite::Update()
{
	if( TEST_BIT(m_uDirtyFlag, TRANSFORM) )
	{
		if( TEST_BIT(m_uDirtyFlag, SCALE) || TEST_BIT(m_uDirtyFlag, ROTATION) )
		{
			D3DXMATRIX Matrix;

			D3DXMatrixScaling(&m_LocalMatrix, m_Scale.x, m_Scale.y, m_Scale.z);

			if( TEST_BIT(m_uDirtyFlag, ROTATION) )
			{
				D3DXQuaternionRotationYawPitchRoll(&m_Quaternion, m_Rotation.y, m_Rotation.x, m_Rotation.z);

				CLEAR_BIT(m_uDirtyFlag, ROTATION);
			}

			D3DXMatrixRotationQuaternion(&Matrix, &m_Quaternion);

			m_LocalMatrix *= Matrix;

			m_LocalMatrix._41 = m_Position.x;
			m_LocalMatrix._42 = m_Position.y;
			m_LocalMatrix._43 = m_Position.z;
			//m_LocalMatrix._44 = m_Position.w;

			CLEAR_BIT(m_uDirtyFlag, SCALE);

			SET_BIT(m_uDirtyFlag, RIGHT  );
			SET_BIT(m_uDirtyFlag, UP     );
			SET_BIT(m_uDirtyFlag, FORWARD);
		}
		else if( TEST_BIT(m_uDirtyFlag, POSITION) )
		{
			m_LocalMatrix._41 = m_Position.x;
			m_LocalMatrix._42 = m_Position.y;
			m_LocalMatrix._43 = m_Position.z;
			//m_LocalMatrix._44 = m_Position.w;

			CLEAR_BIT(m_uDirtyFlag, POSITION);
		}

		CLEAR_BIT(m_uDirtyFlag, TRANSFORM);

		m_bIsTransformDirty = true;
	}

	CSceneNode::Update();
}

void CSprite::UpdateTransform()
{
	CSceneNode::UpdateTransform();

	SET_BIT(m_uDirtyFlag, WORLD_RIGHT  );
	SET_BIT(m_uDirtyFlag, WORLD_UP     );
	SET_BIT(m_uDirtyFlag, WORLD_FORWARD);
}

void CSprite::Right(zerO::FLOAT fNumSteps)
{
	D3DXVECTOR3 Right(m_LocalMatrix._11, m_LocalMatrix._12, m_LocalMatrix._13);

	if(m_LocalMatrix._14)
		Right /= m_LocalMatrix._14;

	D3DXVec3Normalize(&Right, &Right);

	Right *= fNumSteps;

	m_Position += Right;

	SET_BIT(m_uDirtyFlag, TRANSFORM);
	SET_BIT(m_uDirtyFlag, POSITION);
}

void CSprite::Up(zerO::FLOAT fNumSteps)
{
	D3DXVECTOR3 Up(m_LocalMatrix._21, m_LocalMatrix._22, m_LocalMatrix._23);

	if(m_LocalMatrix._24)
		Up /= m_LocalMatrix._24;

	D3DXVec3Normalize(&Up, &Up);

	Up *= fNumSteps;

	m_Position += Up;

	SET_BIT(m_uDirtyFlag, TRANSFORM);
	SET_BIT(m_uDirtyFlag, POSITION);
}

void CSprite::Forward(zerO::FLOAT fNumSteps)
{
	D3DXVECTOR3 Forward(m_LocalMatrix._31, m_LocalMatrix._32, m_LocalMatrix._33);

	if(m_LocalMatrix._34)
		Forward /= m_LocalMatrix._34;

	D3DXVec3Normalize(&Forward, &Forward);

	Forward *= fNumSteps;

	m_Position += Forward;

	SET_BIT(m_uDirtyFlag, TRANSFORM);
	SET_BIT(m_uDirtyFlag, POSITION);
}