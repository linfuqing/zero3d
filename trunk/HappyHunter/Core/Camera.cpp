#include "StdAfx.h"
#include "Camera.h"
#include "GameHost.h"

using namespace zerO;

void FRUSTUM::ExtractFromMatrix(const D3DXMATRIX& Matrix)
{
	Left.a   = Matrix._14 + Matrix._11;
	Left.b   = Matrix._24 + Matrix._21;
	Left.c   = Matrix._34 + Matrix._31;
	Left.d   = Matrix._44 + Matrix._41;

	Right.a  = Matrix._14 - Matrix._11;
	Right.b  = Matrix._24 - Matrix._21;
	Right.c  = Matrix._34 - Matrix._31;
	Right.d  = Matrix._44 - Matrix._41;

	Top.a    = Matrix._14 - Matrix._12;
	Top.b    = Matrix._24 - Matrix._22;
	Top.c    = Matrix._34 - Matrix._32;
	Top.d    = Matrix._44 - Matrix._42;

	Bottom.a = Matrix._14 + Matrix._12;
	Bottom.b = Matrix._24 + Matrix._22;
	Bottom.c = Matrix._34 + Matrix._32;
	Bottom.d = Matrix._44 + Matrix._42;

	Far.a    = Matrix._14 - Matrix._13;
	Far.b    = Matrix._24 - Matrix._23;
	Far.c    = Matrix._34 - Matrix._33;
	Far.d    = Matrix._44 - Matrix._43;

	Near.a   = Matrix._13;
	Near.b   = Matrix._23;
	Near.c   = Matrix._33;
	Near.d   = Matrix._43;
}

CCamera::CCamera(void) :
m_WorldPosition(0.0f, 0.0f, 0.0f),
m_fFOV(0.0f),
m_fAspect(0.0f),
m_fNearPlane(0.0f),
m_fFarPlane(0.0f)
{
	D3DXMatrixIdentity(&m_ViewMatrix);
	D3DXMatrixIdentity(&m_ProjectionMatrix);
	D3DXMatrixIdentity(&m_ViewProjectionMatrix);
}

CCamera::~CCamera(void)
{
}

void CCamera::SetProjection(
							zerO::FLOAT fFOV, 
							zerO::FLOAT fNearPlane,
							zerO::FLOAT fFarPlane,
							zerO::FLOAT fAspect)
{
	if(fAspect <= 0)
		fAspect = (FLOAT)GAMEHOST.GetBackBufferSurfaceDesc().Width / GAMEHOST.GetBackBufferSurfaceDesc().Height;

	m_fFOV       = fFOV;
	m_fAspect    = fAspect;
	m_fNearPlane = fNearPlane;
	m_fFarPlane  = fFarPlane;

	D3DXMatrixPerspectiveFovLH(&m_ProjectionMatrix, fFOV, fAspect, fNearPlane, fFarPlane);

	D3DXMatrixInverse(&m_InverseProjectionMatrix, NULL, &m_ProjectionMatrix);

	static D3DXVECTOR3 p0(-1.0f,1.0f,1.0f);
	static D3DXVECTOR3 p1(-1.0f,-1.0f,1.0f);
	static D3DXVECTOR3 p2(1.0f,-1.0f,1.0f);
	static D3DXVECTOR3 p3(1.0f,1.0f,1.0f);
	static D3DXVECTOR3 p4(-1.0f,1.0f,0.0f);
	static D3DXVECTOR3 p5(-1.0f,-1.0f,0.0f);
	static D3DXVECTOR3 p6(1.0f,-1.0f,0.0f);
	static D3DXVECTOR3 p7(1.0f,1.0f,0.0f);

	D3DXVec3TransformCoord(&m_FarPlanePoints[0], &p0, &m_InverseProjectionMatrix);
	D3DXVec3TransformCoord(&m_FarPlanePoints[1], &p1, &m_InverseProjectionMatrix);
	D3DXVec3TransformCoord(&m_FarPlanePoints[2], &p2, &m_InverseProjectionMatrix);
	D3DXVec3TransformCoord(&m_FarPlanePoints[3], &p3, &m_InverseProjectionMatrix);
	D3DXVec3TransformCoord(&m_FarPlanePoints[4], &p4, &m_InverseProjectionMatrix);
	D3DXVec3TransformCoord(&m_FarPlanePoints[5], &p5, &m_InverseProjectionMatrix);
	D3DXVec3TransformCoord(&m_FarPlanePoints[6], &p6, &m_InverseProjectionMatrix);
	D3DXVec3TransformCoord(&m_FarPlanePoints[7], &p7, &m_InverseProjectionMatrix);

	m_bIsTransformDirty = true;
}

void CCamera::SetProjection()
{
	SetProjection(m_fFOV, m_fNearPlane, m_fFarPlane);

	m_bIsTransformDirty = true;
}

void CCamera::ModifyProjectionMatrix(const D3DXPLANE& WorldClipPlane)
{
    /*D3DXVECTOR4 q;
	zerO::FLOAT* fMatrix = (zerO::FLOAT*)m_ProjectionMatrix;

    // Calculate the clip-space corner point opposite the clipping plane
    // as (sgn(clipPlane.x), sgn(clipPlane.y), 1, 1) and
    // transform it into camera space by multiplying it
    // by the inverse of the projection matrix
    
    q.x = ( SIGN(ClipPlane.a) + fMatrix[8]) / fMatrix[0];
    q.y = ( SIGN(ClipPlane.b) + fMatrix[9]) / fMatrix[5];
    q.z = - 1.0F;
    q.w = ( 1.0F + fMatrix[10]) / fMatrix[14];
    
    // Calculate the scaled plane vector
    D3DXVECTOR4 c = ClipPlane * ( 2.0f / D3DXPlaneDot(&ClipPlane, &q) );
    
    // Replace the third row of the projection matrix
    fMatrix[2] = c.x;
    fMatrix[6] = c.y;
    fMatrix[10] = c.z + 1.0F;
    fMatrix[14] = c.w;

    m_ProjectionMatrix = D3DXMATRIX(fMatrix);*/
	D3DXMATRIXA16 ClipProjectionMatrix;
    
    D3DXMATRIXA16 WorldToProjection = m_ViewProjectionMatrix;

	D3DXPLANE Plane;

    // m_clip_plane is plane definition (world space)
    D3DXPlaneNormalize(&Plane, &WorldClipPlane);

    D3DXMatrixInverse(&WorldToProjection, NULL, &WorldToProjection);
    D3DXMatrixTranspose(&WorldToProjection, &WorldToProjection);


    D3DXVECTOR4 ClipPlane(Plane.a, Plane.b, Plane.c, Plane.d);
    D3DXVECTOR4 ProjectionClipPlane;

    // transform clip plane into projection space
    D3DXVec4Transform(&ProjectionClipPlane, &ClipPlane, &WorldToProjection);
    D3DXMatrixIdentity(&ClipProjectionMatrix);


    if (ProjectionClipPlane.w == 0)  // or less than a really small value
    {
        // plane is perpendicular to the near plane
        return;
    }

    if (ProjectionClipPlane.w > 0)
    {
        // flip plane to point away from eye
        //D3DXVECTOR4 clipPlane(-Plane.a, -Plane.b, -Plane.c, -Plane.d);
		ClipPlane.x = - Plane.a;
		ClipPlane.y = - Plane.b;
		ClipPlane.z = - Plane.c;
		ClipPlane.w = - Plane.d;

        // transform clip plane into projection space
        D3DXVec4Transform(&ProjectionClipPlane, &ClipPlane, &WorldToProjection);

    }

    // put projection space clip plane in Z column
    ClipProjectionMatrix(0, 2) = ProjectionClipPlane.x;
    ClipProjectionMatrix(1, 2) = ProjectionClipPlane.y;
    ClipProjectionMatrix(2, 2) = ProjectionClipPlane.z;
    ClipProjectionMatrix(3, 2) = ProjectionClipPlane.w;

    // multiply into projection matrix
    m_ProjectionMatrix *= ClipProjectionMatrix;
}

void CCamera::GetRayByScreenPosition(D3DXVECTOR3* pRayPosition, D3DXVECTOR3* pRayDirection, zerO::FLOAT fScreenX, zerO::FLOAT fScreenY)
{
	if(pRayPosition || pRayDirection)
	{
		FLOAT x = fScreenX / (GAMEHOST.GetBackBufferSurfaceDesc().Width  * 0.5f) - 1.0f;
		FLOAT y = fScreenY / (GAMEHOST.GetBackBufferSurfaceDesc().Height * 0.5f) - 1.0f;
		D3DXVECTOR4 NearPosition(x * m_fNearPlane, y * m_fNearPlane, 0.0f, m_fNearPlane), FarPosition(x * m_fFarPlane, y * m_fFarPlane, 1.0f, m_fFarPlane);

		if(pRayPosition)
		{
			D3DXVec4Transform(&NearPosition, &NearPosition, &m_InverseViewProjectionMatrix);

			pRayPosition->x = NearPosition.x;
			pRayPosition->y = NearPosition.y;
			pRayPosition->z = NearPosition.z;
		}

		if(pRayDirection)
		{
			D3DXVec4Transform(&FarPosition, &FarPosition, &m_InverseViewProjectionMatrix);

			FarPosition -= NearPosition;

			pRayDirection->x = FarPosition.x;
			pRayDirection->y = FarPosition.y;
			pRayDirection->z = FarPosition.z;

			D3DXVec3Normalize(pRayDirection, pRayDirection);
		}
	}
}

void CCamera::UpdateTransform()
{
	m_LocalRect.Set(
		m_Position.x, m_Position.x, 
		m_Position.y, m_Position.y, 
		m_Position.z, m_Position.z);

	m_LocalRect.Union(m_FarPlanePoints[0]);
	m_LocalRect.Union(m_FarPlanePoints[1]);
	m_LocalRect.Union(m_FarPlanePoints[2]);
	m_LocalRect.Union(m_FarPlanePoints[3]);
	m_LocalRect.Union(m_FarPlanePoints[4]);
	m_LocalRect.Union(m_FarPlanePoints[5]);
	m_LocalRect.Union(m_FarPlanePoints[6]);
	m_LocalRect.Union(m_FarPlanePoints[7]);

	CSprite::UpdateTransform();

	m_WorldPosition.x = m_WorldMatrix._41;
	m_WorldPosition.y = m_WorldMatrix._42;
	m_WorldPosition.z = m_WorldMatrix._43;

	if(m_WorldMatrix._44)
		m_WorldPosition /= m_WorldMatrix._44;

	D3DXMatrixInverse(&m_ViewMatrix, NULL, &m_WorldMatrix);

	D3DXMatrixMultiply(&m_ViewProjectionMatrix, &m_ViewMatrix, &m_ProjectionMatrix);

	m_Frustum.ExtractFromMatrix(m_ViewProjectionMatrix);

	D3DXMatrixMultiply(&m_InverseViewProjectionMatrix, &m_InverseProjectionMatrix, &m_WorldMatrix);
}