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
m_Scale(0.0f, 0.0f, 0.0f),
m_uDirtyFlag(0)
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
	if(m_uDirtyFlag)
	{
		D3DXMATRIX Matrix;

		D3DXMatrixIdentity(&m_LocalMatrix);

		if( TEST_BIT(m_uDirtyFlag, SCALE) )
		{
			D3DXMatrixScaling(&Matrix, m_Scale.x, m_Scale.y, m_Scale.z);

			m_LocalMatrix *= Matrix;
		}

		if( TEST_BIT(m_uDirtyFlag, ROTATION) )
		{
			D3DXQuaternionRotationYawPitchRoll(&m_Quaternion, m_Rotation.y, m_Rotation.x, m_Rotation.z);

			D3DXMatrixRotationQuaternion(&Matrix, &m_Quaternion);

			m_LocalMatrix *= Matrix;
		}

		if( TEST_BIT(m_uDirtyFlag, POSITION) )
		{
			D3DXMatrixTranslation(&Matrix, m_Position.x, m_Position.y, m_Position.z);

			m_LocalMatrix *= Matrix;
		}

		m_bIsTransformDirty = true;
	}

	CSceneNode::Update();

	m_WorldRight.x   = m_WorldMatrix._11;
	m_WorldRight.y   = m_WorldMatrix._12;
	m_WorldRight.z   = m_WorldMatrix._13;

	if(m_WorldMatrix._14)
		m_WorldRight /= m_WorldMatrix._14;

	m_WorldUp.x      = m_WorldMatrix._21;
	m_WorldUp.y      = m_WorldMatrix._22;
	m_WorldUp.z      = m_WorldMatrix._23;

	if(m_WorldMatrix._24)
		m_WorldUp /= m_WorldMatrix._24;

	m_WorldForward.x = m_WorldMatrix._31;
	m_WorldForward.y = m_WorldMatrix._32;
	m_WorldForward.z = m_WorldMatrix._33;

	if(m_WorldMatrix._34)
		m_WorldForward /= m_WorldMatrix._34;
}

void CSprite::Right(zerO::FLOAT fNumSteps)
{
	D3DXVECTOR3 Right(m_LocalMatrix._11, m_LocalMatrix._12, m_LocalMatrix._13);

	if(m_LocalMatrix._14)
		Right /= m_LocalMatrix._14;

	D3DXVec3Normalize(&Right, &Right);

	Right *= fNumSteps;

	m_Position += Right;

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

	SET_BIT(m_uDirtyFlag, POSITION);
}