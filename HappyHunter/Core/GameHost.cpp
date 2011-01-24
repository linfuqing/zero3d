#include "StdAfx.h"
#include "GameHost.h"
#include "Resource.h"
#include "Camera.h"
#include "RenderQueue.h"
#include "Background.h"
#include "Water.h"
#include "Shadow.h"
#include "VertexBuffer.h"
#include "Texture.h"
#include "FullScreenEffect.h"
#include "TexturePrinter.h"

using namespace zerO;

CGameHost* CGameHost::sm_pInstance = NULL;

CGameHost::CGameHost(void) :
m_pDevice(NULL),
//m_pScene(NULL),
m_pBackground(NULL),
m_pWater(NULL),
m_pVertexBuffer(NULL),
m_pFullScreenEffect(NULL),
m_bLightEnable(false),
m_bFogEnable(false),
//m_bSceneEnable(false),
m_fTime(0),
m_ShadowColor(0x7f000000)
{
	DEBUG_ASSERT(!sm_pInstance, "Only one instance of CGameHost is permitted.");

	sm_pInstance = this;
}

CGameHost::~CGameHost(void)
{
	sm_pInstance = NULL;

	Destroy();
}

RESOURCEHANDLE CGameHost::AddResource(CResource* const pResource, RESOURCETYPE Type)
{
	DEBUG_ASSERT(pResource, "pResource can not be NULL.");

	m_ResourceList[Type].push_back(pResource);

	return m_ResourceList[Type].size();
}

CResource* CGameHost::GetResource(RESOURCEHANDLE Handle, RESOURCETYPE Type)
{
	return m_ResourceList[Type][Handle - 1];
}

void CGameHost::RemoveResource(const CResource* pResource, RESOURCETYPE Type)
{
	DEBUG_ASSERT(pResource, "pResource can not be NULL.");

	for(std::vector<CResource*>::iterator i = m_ResourceList[Type].begin(); i != m_ResourceList[Type].end();)
	{
		if(*i == pResource)
			i = m_ResourceList[Type].erase(i);
		else
			i ++;
	}
}

void CGameHost::AddShadow(CShadow* const pShadow)
{
	DEBUG_ASSERT(pShadow, "pShadow can not be NULL.");

	m_ShadowList.push_back(pShadow);
}

void CGameHost::RemoveShadow(CShadow* const pShadow)
{
	DEBUG_ASSERT(pShadow, "pShadow can not be NULL.");

	m_ShadowList.remove(pShadow);
}

void CGameHost::AddSceneManager(CSceneManager& SceneManager)
{
	m_SceneManagerList.push_back(&SceneManager);
}

void CGameHost::RemoveSceneManager(CSceneManager& SceneManager)
{
	m_SceneManagerList.remove(&SceneManager);
}

void CGameHost::AddSceneObject(CSceneObject& SceneObject)
{
	m_SceneObjectList.push_back(&SceneObject);
}

void CGameHost::RemoveSceneObject(CSceneObject& SceneObject)
{
	m_SceneObjectList.remove(&SceneObject);
}

bool CGameHost::Destroy()
{
	UINT uTotalResourceTypes = TOTAL_RESOURCE_TYPES;

	UINT uIndex;
	std::vector<CResource*>::iterator Iteractor;
	for(uIndex = 0; uIndex < uTotalResourceTypes; uIndex ++)
		for(Iteractor = m_ResourceList[uIndex].begin(); Iteractor != m_ResourceList[uIndex].end(); Iteractor ++)
			if( !(*Iteractor)->Destroy() )
				return false;

	for(std::list<CShadow*>::iterator i = m_ShadowList.begin(); i != m_ShadowList.end(); i ++)
		(*i)->Destroy();

	for(std::list<CSceneManager*>::iterator i = m_SceneManagerList.begin(); i != m_SceneManagerList.end(); i ++)
		(*i)->Destroy();

	for(std::list<CSceneObject*>::iterator i = m_SceneObjectList.begin(); i != m_SceneObjectList.end(); i ++)
		(*i)->Destroy();

	DEBUG_DELETE(m_pRenderQueue);
	DEBUG_DELETE(m_pCamera);
	//DEBUG_DELETE(m_pScene);
	DEBUG_DELETE(m_pVertexBuffer);
	DEBUG_DELETE(m_pTexturePrinter);
	//DEBUG_DELETE(m_pFullScreenEffect);

	m_pRenderQueue              = NULL;
	m_pCamera                   = NULL;
	//m_pScene                    = NULL;
	m_pVertexBuffer             = NULL;
	m_pFullScreenEffect         = NULL;
	m_pTexturePrinter           = NULL;

	for(INT i = 0; i < TOTAL_RESOURCE_TYPES; i ++)
		m_ResourceList[i].clear();

	m_ShadowList.clear();

	m_SceneManagerList.clear();

	m_SceneObjectList.clear();

	return true;
}

bool CGameHost::Disable()
{
	UINT uTotalResourceTypes = TOTAL_RESOURCE_TYPES;

	UINT uIndex;
	std::vector<CResource*>::iterator Iteractor;
	for(uIndex = 0; uIndex < uTotalResourceTypes; uIndex ++)
		for(Iteractor = m_ResourceList[uIndex].begin(); Iteractor != m_ResourceList[uIndex].end(); Iteractor ++)
			if( !(*Iteractor)->Disable() )
				return false;

	return true;
}

bool CGameHost::Restore(const D3DSURFACE_DESC& BackBufferSurfaceDesc)
{
	memcpy( &m_DeviceSurfaceDest, &BackBufferSurfaceDesc, sizeof(D3DSURFACE_DESC) );

	UINT uTotalResourceTypes = TOTAL_RESOURCE_TYPES;

	UINT uIndex;
	std::vector<CResource*>::iterator Iteractor;
	for(uIndex = 0; uIndex < uTotalResourceTypes; uIndex ++)
		for(Iteractor = m_ResourceList[uIndex].begin(); Iteractor != m_ResourceList[uIndex].end(); Iteractor ++)
			if( !(*Iteractor)->Restore() )
				return false;

	CAMERA.SetProjection();

	LPVERTEX pVertices;

	FLOAT sx = (FLOAT)BackBufferSurfaceDesc.Width;
    FLOAT sy = (FLOAT)BackBufferSurfaceDesc.Height;

	if( m_pVertexBuffer->Lock(0, (void**)&pVertices) )
	{
		pVertices[0].Position = D3DXVECTOR4(  0, sy, 0.0f, 1.0f );
		pVertices[1].Position = D3DXVECTOR4(  0,  0, 0.0f, 1.0f );
		pVertices[2].Position = D3DXVECTOR4( sx, sy, 0.0f, 1.0f );
		pVertices[3].Position = D3DXVECTOR4( sx,  0, 0.0f, 1.0f );

		pVertices[0].UV       = D3DXVECTOR2(0.0f, 1.0f);
		pVertices[1].UV       = D3DXVECTOR2(0.0f, 0.0f);
		pVertices[2].UV       = D3DXVECTOR2(1.0f, 1.0f);
		pVertices[3].UV       = D3DXVECTOR2(1.0f, 0.0f);

		pVertices[0].Color    = m_ShadowColor;
		pVertices[1].Color    = m_ShadowColor;
		pVertices[2].Color    = m_ShadowColor;
		pVertices[3].Color    = m_ShadowColor;

		m_pVertexBuffer->Unlock();
	}

	return true;
}

bool CGameHost::Create(LPDIRECT3D9 pDirect, LPDIRECT3DDEVICE9 pDevice, const DEVICESETTINGS& DeviceSettings, zerO::UINT uMaxQueue)
{
	if(pDirect == NULL || pDevice == NULL || uMaxQueue == 0)
		return false;

	m_pDevice = pDevice;
	m_pDirect = pDirect;

	memcpy( &m_DeviceSettings, &DeviceSettings, sizeof(DeviceSettings) );

	m_DeviceSurfaceDest.Format              = m_DeviceSettings.pp.BackBufferFormat;
	m_DeviceSurfaceDest.Width               = m_DeviceSettings.pp.BackBufferWidth;
	m_DeviceSurfaceDest.Height              = m_DeviceSettings.pp.BackBufferHeight;
	m_DeviceSurfaceDest.MultiSampleQuality  = m_DeviceSettings.pp.MultiSampleQuality;
	m_DeviceSurfaceDest.MultiSampleQuality  = m_DeviceSettings.pp.MultiSampleType;

	m_pDirect->GetDeviceCaps(m_DeviceSettings.AdapterOrdinal, m_DeviceSettings.DeviceType, &m_Caps);

	DEBUG_NEW( m_pRenderQueue, CRenderQueue(uMaxQueue) );
	//DEBUG_NEW( m_pScene, CSceneNode );
	DEBUG_NEW(m_pCamera, CCamera);

	DEBUG_NEW(m_pVertexBuffer, CVertexBuffer);
	DEBUG_NEW(m_pTexturePrinter, CTexturePrinter);
	//DEBUG_NEW(m_pFullScreenEffect, CFullScreenEffect);

	if( !m_pVertexBuffer->Create(4, sizeof(VERTEX), D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED, NULL, D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_TEX1) )
	{
		Destroy();
		return false;
	}

	if( !m_pTexturePrinter->Create() )
	{
		Destroy();

		return false;
	}

	m_pTexturePrinter->AddTexture();

	return true;
}

bool CGameHost::Update(zerO::FLOAT fElapsedTime)
{
	m_fElapsedTime = fElapsedTime;

	m_fTime += fElapsedTime;

	//m_pCamera->Update();

	m_Scene.Update();

	UpdateCamera();

	//if(m_pBackground)
	//	m_pBackground->Update();

	//if(m_pWater)
	//	m_pWater->Update();

	return true;
}

bool CGameHost::UpdateCamera()
{
	m_pCamera->Update();

	m_pDevice->SetTransform( D3DTS_VIEW, &CAMERA.GetViewMatrix() );

		//设置投影矩阵
	m_pDevice->SetTransform( D3DTS_PROJECTION, &CAMERA.GetProjectionMatrix() );

	m_pSearchList = NULL;
	if( !m_SceneManagerList.empty() )
	{
		CSceneManagerEntry* pEntry = NULL;
		std::list<CSceneManager*>::iterator i = m_SceneManagerList.begin();
		m_pSearchList = (*i)->SearchObject(m_pCamera->GetWorldRectangle(), (LPFRUSTUM)&m_pCamera->GetFrustum(), &pEntry);

		for(++ i; i != m_SceneManagerList.end(); i ++)
			(*i)->SearchObject(CAMERA.GetWorldRectangle(), (LPFRUSTUM)&CAMERA.GetFrustum(), &pEntry);

		pEntry = m_pSearchList;
		while(pEntry)
		{
			pEntry->Update();

			pEntry = pEntry->GetNext();
		}
	}

	m_Scene.UpdateViewSpace();

	if(m_pBackground)
		m_pBackground->UpdateViewSpace();

	if(m_pWater)
		m_pWater->UpdateViewSpace();

	return true;
}

bool CGameHost::UpdateBeforeRender()
{
	for(std::list<CSceneObject*>::iterator i = m_SceneObjectList.begin(); i != m_SceneObjectList.end(); i ++)
		(*i)->UpdateBeforeRender();

	return true;
}

/*bool CGameHost::BeginRender()
{
	if(m_bLightEnable)
		m_LightManager.Activate();
	else
		m_pDevice->SetRenderState(D3DRS_LIGHTING, FALSE);

	if(m_bFogEnable)
		m_FogManager.Activate();
	else
		m_pDevice->SetRenderState(D3DRS_FOGENABLE, FALSE);

	if(m_pFullScreenEffect || m_pWater)
	{
		m_pTexturePrinter->Begin();
		m_pTexturePrinter->Activate(0, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER | D3DCLEAR_STENCIL);
	}

	if(m_pBackground)
	{
		m_pDevice->SetRenderState(D3DRS_ZWRITEENABLE, FALSE);
		m_pDevice->SetRenderState( D3DRS_FOGENABLE, m_pBackground->GetFogEnable() );
		m_pBackground->Render();
		m_pDevice->SetRenderState(D3DRS_ZWRITEENABLE, TRUE);
		m_pDevice->SetRenderState(D3DRS_FOGENABLE, m_bFogEnable);
	}

	return true;
}

bool CGameHost::EndRender()
{
	m_pRenderQueue->Render();

	if( !m_ShadowList.empty() )
	{
		m_pDevice->SetTransform( D3DTS_VIEW, &CAMERA.GetViewMatrix() );

		//设置投影矩阵
		m_pDevice->SetTransform( D3DTS_PROJECTION, &CAMERA.GetProjectionMatrix() );

		for(std::list<CShadow*>::const_iterator i = m_ShadowList.begin(); i != m_ShadowList.end(); i ++)
		{
			(*i)->Update();
			(*i)->Render();
		}

		//关闭深度测试, 启用Alpha混合
		m_pDevice->SetRenderState( D3DRS_ZENABLE,          FALSE );
		m_pDevice->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		m_pDevice->SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA );
		m_pDevice->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA );
		m_pDevice->SetRenderState( D3DRS_BLENDOP, D3DBLENDOP_ADD);

		m_pDevice->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
		m_pDevice->SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);

		m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
		m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);

		//设置模板相关渲染状态
		m_pDevice->SetRenderState( D3DRS_STENCILENABLE,    TRUE );
		m_pDevice->SetRenderState( D3DRS_STENCILREF,  0x1 );
		m_pDevice->SetRenderState( D3DRS_STENCILFUNC, D3DCMP_LESSEQUAL );
		m_pDevice->SetRenderState( D3DRS_STENCILPASS, D3DSTENCILOP_KEEP );

		//渲染一个灰色矩形, 只有通过模板测试的像素才会被渲染到颜色缓冲区,表示阴影
		m_pVertexBuffer->Activate(0, 0, true);

		m_pDevice->DrawPrimitive( D3DPT_TRIANGLESTRIP, 0, 2 );

		//恢复渲染状态
		m_pDevice->SetRenderState( D3DRS_ZENABLE,          TRUE );
		m_pDevice->SetRenderState( D3DRS_ALPHABLENDENABLE, FALSE );
		m_pDevice->SetRenderState( D3DRS_STENCILENABLE,    FALSE );

		m_pDevice->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
		m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
	}

	if(m_pWater)
	{
		//m_pTexturePrinter->End(CTexturePrinter::RENDER_SURFACE);
		//m_pTexturePrinter->End();

		m_pWater->Render();

		//m_pTexturePrinter->End();
	}
	//else if(m_pFullScreenEffect)
	//	m_pTexturePrinter->End();

	if(m_pFullScreenEffect)
	{
		m_pTexturePrinter->End();

		m_pFullScreenEffect->Render(*m_pTexturePrinter);
	}

	return true;
}*/

bool CGameHost::RenderBackground()
{
	if(m_pBackground)
	{
		m_pBackground->UpdateViewSpace();

		m_pDevice->SetRenderState(D3DRS_ZWRITEENABLE, FALSE);
		m_pDevice->SetRenderState(D3DRS_FOGENABLE, m_pBackground->GetFogEnable() ? TRUE : FALSE);
		m_pBackground->Render();
		m_pDevice->SetRenderState(D3DRS_ZWRITEENABLE, TRUE);
		m_pDevice->SetRenderState(D3DRS_FOGENABLE, m_bFogEnable ? TRUE : FALSE);

		return true;
	}

	return false;
}

bool CGameHost::RenderScene()
{
	if(m_pSearchList)
	{
		CSceneManagerEntry* pEntry = m_pSearchList;
		while(pEntry)
		{
			pEntry->AddedToRenderQueue();

			pEntry = pEntry->GetNext();
		}
	}

	m_Scene.AddedToRenderQueue();

	m_pRenderQueue->Render();

	if( !m_ShadowList.empty() )
	{
		m_pDevice->SetTransform( D3DTS_VIEW, &CAMERA.GetViewMatrix() );

		//设置投影矩阵
		m_pDevice->SetTransform( D3DTS_PROJECTION, &CAMERA.GetProjectionMatrix() );

		for(std::list<CShadow*>::const_iterator i = m_ShadowList.begin(); i != m_ShadowList.end(); i ++)
		{
			(*i)->Update();
			(*i)->Render();
		}

		//关闭深度测试, 启用Alpha混合
		m_pDevice->SetRenderState( D3DRS_ZENABLE,          FALSE );
		m_pDevice->SetRenderState( D3DRS_ZWRITEENABLE,     FALSE );
		m_pDevice->SetRenderState( D3DRS_ALPHABLENDENABLE, TRUE );
		m_pDevice->SetRenderState( D3DRS_SRCBLEND,  D3DBLEND_SRCALPHA );
		m_pDevice->SetRenderState( D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA );
		m_pDevice->SetRenderState( D3DRS_BLENDOP, D3DBLENDOP_ADD);

		m_pDevice->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_DIFFUSE);
		m_pDevice->SetTextureStageState(0, D3DTSS_COLOROP, D3DTOP_SELECTARG1);

		m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
		m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1);

		//设置模板相关渲染状态
		m_pDevice->SetRenderState( D3DRS_STENCILENABLE,    TRUE );
		m_pDevice->SetRenderState( D3DRS_STENCILREF,  0x1 );
		m_pDevice->SetRenderState( D3DRS_STENCILFUNC, D3DCMP_LESSEQUAL );
		m_pDevice->SetRenderState( D3DRS_STENCILPASS, D3DSTENCILOP_KEEP );

		//渲染一个灰色矩形, 只有通过模板测试的像素才会被渲染到颜色缓冲区,表示阴影
		m_pVertexBuffer->Activate(0, 0, true);

		m_pDevice->DrawPrimitive( D3DPT_TRIANGLESTRIP, 0, 2 );

		//恢复渲染状态
		m_pDevice->SetRenderState( D3DRS_ZENABLE,          TRUE );
		m_pDevice->SetRenderState( D3DRS_ZWRITEENABLE,     TRUE );
		m_pDevice->SetRenderState( D3DRS_ALPHABLENDENABLE, FALSE );
		m_pDevice->SetRenderState( D3DRS_STENCILENABLE,    FALSE );

		m_pDevice->SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
		m_pDevice->SetTextureStageState(0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE);
	}

	return true;
}

bool CGameHost::Render()
{
	UpdateBeforeRender();

	if(m_bLightEnable)
		m_LightManager.Activate();
	else
		m_pDevice->SetRenderState(D3DRS_LIGHTING, FALSE);

	if(m_bFogEnable)
		m_FogManager.Activate();
	else
		m_pDevice->SetRenderState(D3DRS_FOGENABLE, FALSE);

	if(m_pFullScreenEffect)
		m_pTexturePrinter->Activate(0, D3DCLEAR_TARGET/* | D3DCLEAR_ZBUFFER | D3DCLEAR_STENCIL*/);

	RenderBackground();

	RenderScene();

	if(m_pWater)
		m_pWater->Render(m_pFullScreenEffect ? true : false);

	if(m_pFullScreenEffect)
	{
		//m_pTexturePrinter->End(CTexturePrinter::RENDER_SURFACE);

		m_pFullScreenEffect->Render(*m_pTexturePrinter);
	}

	return true;
}

void CGameHost::FillFullScreen(ARGBCOLOR Color)
{
	LPVERTEX pVertices;

	if( m_pVertexBuffer->Lock(0, (void**)&pVertices) )
	{
		pVertices[0].Color    = Color;
		pVertices[1].Color    = Color;
		pVertices[2].Color    = Color;
		pVertices[3].Color    = Color;

		m_pVertexBuffer->Unlock();
	}

	m_pDevice->SetRenderState(D3DRS_ZWRITEENABLE, FALSE);

	m_pVertexBuffer->Activate(0, 0, true);

	m_pDevice->DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2);

	m_pDevice->SetRenderState(D3DRS_ZWRITEENABLE, TRUE);
}