#include "StdAfx.h"
#include "Water.h"
#include "Camera.h"
#include "TexturePrinter.h"

using namespace zerO;

zerO::UINT CWater::sm_uRefractionMap = 0;
zerO::UINT CWater::sm_uReflectionMap = 0;

CWater::CWater(void) :
m_uRefractionMap(0),
m_uReflectionMap(0),
m_pBumpMap(NULL),
m_pfnRefractionReset(NULL),
m_pfnReflectionReset(NULL),
m_Plane(0, 1.0f, 0.0f, 0.0f)
{
	GAMEHOST.SetWater(this);

	D3DXMatrixIdentity(&m_Matrix);
}

CWater::~CWater(void)
{
}

bool CWater::Create(
					zerO::FLOAT fWidth, 
					zerO::FLOAT fHeight, 
					zerO::UINT uSegmentsX, 
					zerO::UINT uSegmentsY,
					CTexture::RESET pfnRefractionReset,
					CTexture::RESET pfnReflectionReset)
{
	m_pfnRefractionReset = pfnRefractionReset;
	m_pfnReflectionReset = pfnReflectionReset;

	if(pfnRefractionReset)
		m_uRefractionMap = GAMEHOST.GetTexturePrinter()->AddTexture(pfnRefractionReset);
	else
	{
		if(!sm_uRefractionMap)
			sm_uRefractionMap = GAMEHOST.GetTexturePrinter()->AddTexture();

		m_uRefractionMap = sm_uRefractionMap;
	}

	if(pfnReflectionReset)
		m_uReflectionMap = GAMEHOST.GetTexturePrinter()->AddTexture(pfnReflectionReset);
	else
	{
		if(!sm_uReflectionMap)
			sm_uReflectionMap = GAMEHOST.GetTexturePrinter()->AddTexture();

		m_uReflectionMap = sm_uReflectionMap;
	}

	m_Surface.SetTexture(GAMEHOST.GetTexturePrinter()->GetTexture(m_uRefractionMap), 1);

	m_Surface.SetTexture(GAMEHOST.GetTexturePrinter()->GetTexture(m_uReflectionMap), 0);

	return m_Geometry.CreatePlane(fWidth, fHeight, uSegmentsX + 1, uSegmentsY + 1);
}

void CWater::UpdateViewSpace()
{
	D3DXVECTOR3 Position = CAMERA.GetWorldPosition();
	
	m_Matrix._41 = Position.x;
	m_Matrix._43 = Position.z;
}

void CWater::Render(bool bIsRenderToTexture)
{
	CEffect* pEffect = m_RenderMethod.GetEffect();

	if(!pEffect)
		return;

	GAMEHOST.GetTexturePrinter()->RnederToTexture(m_uRefractionMap);

	GAMEHOST.GetTexturePrinter()->Begin();

	GAMEHOST.GetTexturePrinter()->Activate(m_uReflectionMap, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER | D3DCLEAR_STENCIL);

	m_Plane = D3DXPLANE(0.0f, 1.0f, 0.0f, 0.0f);

	TransformPlane(m_Plane, m_Plane, m_Matrix);

	D3DXMATRIX Matrix;

	D3DXMatrixReflect(&Matrix, &m_Plane);

	D3DXMATRIX World = CAMERA.GetLocalMatrix();
	CAMERA.SetTransform(CAMERA.GetWorldMatrix() * Matrix);

	CAMERA.Update();

	DEVICE.SetRenderState(D3DRS_CULLMODE, D3DCULL_CW);

	GAMEHOST.RenderBackground();

	//CAMERA.ModifyProjectionMatrix(m_Plane);

	GAMEHOST.UpdateCamera();

	D3DXPLANE Plane = D3DXPLANE(0.0f, 1.0f, 0.0f, 0.0f);

	TransformPlane( Plane, Plane, m_Matrix * CAMERA.GetViewProjectionMatrix() );

	DEVICE.SetClipPlane(0, (float*)&Plane);
	DEVICE.SetRenderState(D3DRS_CLIPPLANEENABLE, TRUE);

	GAMEHOST.RenderScene();

	DEVICE.SetRenderState(D3DRS_CLIPPLANEENABLE, FALSE);

	//CAMERA.SetProjection();

	DEVICE.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

	CAMERA.SetTransform(World);

	CAMERA.Update();

	if(bIsRenderToTexture)
	{
		GAMEHOST.GetTexturePrinter()->End(CTexturePrinter::DEPTH_STENCIL_SURFACE);

		GAMEHOST.GetTexturePrinter()->Activate(0);
	}
	else
		GAMEHOST.GetTexturePrinter()->End();

	DEVICE.SetVertexShader(NULL);
	DEVICE.SetPixelShader(NULL);

	pEffect->SetSurface(&m_Surface);

	pEffect->Begin();
	pEffect->SetMatrix( CEffect::WORLD, m_Matrix );
	pEffect->SetMatrix( CEffect::WORLD_VIEW_PROJECTION, m_Matrix * CAMERA.GetViewProjectionMatrix() );

	UINT uTotalPass = pEffect->GetTechniqueDesc().Passes, i;

	for (i = 0; i < uTotalPass; i ++)
	{
		pEffect->GetEffect()->BeginPass(i);

		m_Geometry.Draw(false);

		pEffect->GetEffect()->EndPass();
	}

	pEffect->End();

	DEVICE.SetVertexShader(NULL);
	DEVICE.SetPixelShader(NULL);
}