//--------------------------------------------------------------------------------------
// File: Sample.cpp
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------
#include "DXUT.h"
#include "resource.h"
#include "core.h"
#include "HDREffect.h"
#include "Water.h"
//#include "UnderWaterEffect.h"

#include "SDKmisc.h"

#define NUM_LIGHTS 100


ID3DXFont*                 g_pFont = NULL;          //ID3DXFont字体对象
ID3DXSprite*               g_pTextSprite = NULL;    //ID3DXSprite文本精灵对象

zerO::CGameHost g_Game;

zerO::CHDREffect/*CUnderWaterEffect*/ g_Effect;

zerO::CStaticMesh g_Mesh;
zerO::CStaticMesh g_Light[NUM_LIGHTS];

zerO::CSkyBox g_SkyBox;
zerO::CSurface g_SkyBoxSurface;

zerO::CWater g_Water;
zerO::CTexture g_WaterBumpMap;

//阴影举行顶点结构和顶点格式
struct SHADOWVERTEX
{
    D3DXVECTOR4 p;
    D3DCOLOR    color;

    static const DWORD FVF = D3DFVF_XYZRHW | D3DFVF_DIFFUSE;
};

//--------------------------------------------------------------------------------------
// Rejects any D3D9 devices that aren't acceptable to the app by returning false
//--------------------------------------------------------------------------------------
bool CALLBACK IsD3D9DeviceAcceptable( D3DCAPS9* pCaps, D3DFORMAT AdapterFormat, D3DFORMAT BackBufferFormat,
                                      bool bWindowed, void* pUserContext )
{
    // Typically want to skip back buffer formats that don't support alpha blending
    IDirect3D9* pD3D = DXUTGetD3D9Object();
    if( FAILED( pD3D->CheckDeviceFormat( pCaps->AdapterOrdinal, pCaps->DeviceType,
                                         AdapterFormat, D3DUSAGE_QUERY_POSTPIXELSHADER_BLENDING,
                                         D3DRTYPE_TEXTURE, BackBufferFormat ) ) )
        return false;

    return true;
}


//--------------------------------------------------------------------------------------
// Before a device is created, modify the device settings as needed
//--------------------------------------------------------------------------------------
bool CALLBACK ModifyDeviceSettings( DXUTDeviceSettings* pDeviceSettings, void* pUserContext )
{

	//为当前设备设置深度模板缓冲区格式
	pDeviceSettings->d3d9.pp.AutoDepthStencilFormat = D3DFMT_D24S8;

    return true;
}

//--------------------------------------------------------------------------------------
// Create any D3D9 resources that will live through a device reset (D3DPOOL_MANAGED)
// and aren't tied to the back buffer size
//--------------------------------------------------------------------------------------
HRESULT CALLBACK OnD3D9CreateDevice( IDirect3DDevice9* pd3dDevice, const D3DSURFACE_DESC* pBackBufferSurfaceDesc,
                                     void* pUserContext )
{
	HRESULT hr;

	//创建字体
    V_RETURN( D3DXCreateFont( pd3dDevice, 15, 0, FW_BOLD, 1, FALSE, DEFAULT_CHARSET, 
                         OUT_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, 
                         L"Arial", &g_pFont ) );

	//单件模式：首先需要构建一个GameHost
	zerO::CGameHost::DEVICESETTINGS DeviceSettings;
	memcpy( &DeviceSettings, &DXUTGetDeviceSettings().d3d9, sizeof(zerO::CGameHost::DEVICESETTINGS) );

	if( !g_Game.Create(DXUTGetD3D9Object(), pd3dDevice, DeviceSettings, 0xff) )
		return S_FALSE;

	CAMERA.SetProjection(D3DX_PI / 4.0f, (zerO::FLOAT)DeviceSettings.pp.BackBufferWidth / DeviceSettings.pp.BackBufferHeight, 0.5f, 300000.0f);

	D3DXVECTOR3 Postion(20000.0f, 0.0f, - 1000.0f);

	CAMERA.SetPosition(Postion);

	FOGMANAGER.SetColor(0x7f7f007f);
	//FOGMANAGER.SetColor(0);
	//FOGMANAGER.SetExpFog(0.4f);
	FOGMANAGER.SetLinearFog(30000.0f, 100000.0f);
	GAMEHOST.SetFogEnable(true);

	zerO::UINT i;

	for(i = 0; i < NUM_LIGHTS; i ++)
	{
		g_Light[i].SetEffectFile( TEXT("BaseEffect.fx") );
		g_Light[i].CreateSphere(1000, 10, 10);
		
		g_Light[i].SetPosition( D3DXVECTOR3(72455.102f * (rand() * 1.0f / RAND_MAX) - 36227.551f, 72455.102f * (rand() * 1.0f / RAND_MAX) - 36227.551f, 164494.532f * (rand() * 1.0f / RAND_MAX) - 82247.266f) );
	}

	g_Mesh.SetEffectFile( TEXT("ItemEffect.fx") );

	g_Mesh.Create( TEXT("scene.x") );

	g_Effect.Create(6);
	//GAMEHOST.SetFullScreenEffect(&g_Effect);

	g_Water.Create(100000.0f, 100000.0f, 1, 1);
	if( !g_Water.GetRenderMethod().LoadEffect( TEXT("WaterEffect.fx") ) )
		return S_FALSE;

	g_WaterBumpMap.Load( TEXT("wavesbump.dds") );
	g_Water.SetBumpMap(&g_WaterBumpMap);

	g_SkyBox.Create(10.0f);

	//g_SkyBox.SetFogEnable(true);

	g_SkyBox.SetCloudSpeed(0.01f, 0.01f);

	D3DMATERIAL9 Matrial;
	memset( &Matrial, 0, sizeof(D3DMATERIAL9) );
	Matrial.Diffuse.r = Matrial.Ambient.r = 1.0f;
	Matrial.Diffuse.g = Matrial.Ambient.g = 1.0f;
	Matrial.Diffuse.b = Matrial.Ambient.b = 1.0f;
	Matrial.Diffuse.a = Matrial.Ambient.a = 1.0f;

	g_SkyBoxSurface.SetMaterial(Matrial);

	for(i = 0; i < NUM_LIGHTS; i ++)
	{
		Matrial.Ambient.r = rand() * 1.0f / RAND_MAX;
		Matrial.Ambient.g = rand() * 1.0f / RAND_MAX;
		Matrial.Ambient.b = rand() * 1.0f / RAND_MAX;

		switch( (INT)(rand() * 1.0f / RAND_MAX * 3) )
		{
		case 0:
			Matrial.Ambient.r = 1.0f;
			break;
		case 1:
			Matrial.Ambient.g = 1.0f;
			break;
		case 2:
			Matrial.Ambient.b = 1.0f;
			break;
		}
		//Matrial.Ambient.r = rand() * 1.0f / RAND_MAX < 0.5f ? Matrial.Ambient.r : 1.0f;
		//Matrial.Ambient.g = rand() * 1.0f / RAND_MAX < 0.5f ? Matrial.Ambient.g : 1.0f;
		//Matrial.Ambient.b = rand() * 1.0f / RAND_MAX < 0.5f ? Matrial.Ambient.b : 1.0f;

		g_Light[i].GetMesh().GetSurfaces()[0].SetMaterial(Matrial);
	}

	//g_SkyBoxSurface.LoadTexture(TEXT("blue_0005.png"), 0);
	////g_Surface.LoadTexture(TEXT("blue_0005.png"), 1);
	//g_SkyBoxSurface.LoadTexture(TEXT("blue_0001.png"), 2);
	//g_SkyBoxSurface.LoadTexture(TEXT("blue_0003.png"), 3);
	//g_SkyBoxSurface.LoadTexture(TEXT("blue_0002.png"), 4);
	//g_SkyBoxSurface.LoadTexture(TEXT("blue_0004.png"), 5);
	//g_SkyBoxSurface.LoadTexture(TEXT("Cloud1.png"), 6);

	/*g_SkyBoxSurface.LoadTexture(TEXT("night/afx_darksky_UP.jpg"), 0);
	g_SkyBoxSurface.LoadTexture(TEXT("night/afx_darksky_DN.jpg"), 1);
	g_SkyBoxSurface.LoadTexture(TEXT("night/afx_darksky_LF.jpg"), 2);
	g_SkyBoxSurface.LoadTexture(TEXT("night/afx_darksky_RT.jpg"), 3);
	g_SkyBoxSurface.LoadTexture(TEXT("night/afx_darksky_FR.jpg"), 4);
	g_SkyBoxSurface.LoadTexture(TEXT("night/afx_darksky_BK.jpg"), 5);*/
	//g_SkyBoxSurface.LoadTexture(TEXT("night/Cloud.tga"), 6);

	g_SkyBoxSurface.LoadTexture(TEXT("noon/cloudy_noon_UP.dds"), 0);
	g_SkyBoxSurface.LoadTexture(TEXT("noon/cloudy_noon_DN.dds"), 1);
	g_SkyBoxSurface.LoadTexture(TEXT("noon/cloudy_noon_LF.dds"), 2);
	g_SkyBoxSurface.LoadTexture(TEXT("noon/cloudy_noon_RT.dds"), 3);
	g_SkyBoxSurface.LoadTexture(TEXT("noon/cloudy_noon_FR.dds"), 5);
	g_SkyBoxSurface.LoadTexture(TEXT("noon/cloudy_noon_BK.dds"), 4);
	//g_SkyBoxSurface.LoadTexture(TEXT("Cloud1.png"), 6);

	/*g_SkyBoxSurface.LoadTexture(TEXT("sky_blue/blue_0005.jpg"), 0);
	g_SkyBoxSurface.LoadTexture(TEXT("sky_blue/blue_0006.jpg"), 1);
	g_SkyBoxSurface.LoadTexture(TEXT("sky_blue/blue_0004.jpg"), 2);
	g_SkyBoxSurface.LoadTexture(TEXT("sky_blue/blue_0002.jpg"), 3);
	g_SkyBoxSurface.LoadTexture(TEXT("sky_blue/blue_0003.jpg"), 5);
	g_SkyBoxSurface.LoadTexture(TEXT("sky_blue/blue_0001.jpg"), 4);*/
	//g_SkyBoxSurface.LoadTexture(TEXT("Cloud1.png"), 6);

	g_SkyBox.GetRenderMethod().SetSurface(&g_SkyBoxSurface);
	g_SkyBox.GetRenderMethod().LoadEffect( TEXT("EffectTexture.fx") );

	LIGHTMANAGER.SetAmbient(0xffffffff);

	GAMEHOST.SetLightEnable(true);

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Create any D3D9 resources that won't live through a device reset (D3DPOOL_DEFAULT) 
// or that are tied to the back buffer size 
//--------------------------------------------------------------------------------------
HRESULT CALLBACK OnD3D9ResetDevice( IDirect3DDevice9* pd3dDevice, const D3DSURFACE_DESC* pBackBufferSurfaceDesc,
                                    void* pUserContext )
{

	//自动化重建
	if( !GAMEHOST.Restore(*pBackBufferSurfaceDesc) )
		return S_FALSE;

	HRESULT hr;

		//恢复字体
    if( g_pFont )
        V_RETURN( g_pFont->OnResetDevice() );
   
	//创建ID3DXSprite接口对象
    V_RETURN( D3DXCreateSprite( pd3dDevice, &g_pTextSprite ) );

    return S_OK;
}

zerO::FLOAT g_fCameraSpeed;

//--------------------------------------------------------------------------------------
// Handle updates to the scene.  This is called regardless of which D3D API is used
//--------------------------------------------------------------------------------------
void CALLBACK OnFrameMove( double fTime, float fElapsedTime, void* pUserContext )
{
	//设置灯光, 实时更新光源位置
	D3DLIGHT9 light;
    ZeroMemory( &light, sizeof(D3DLIGHT9) );
    light.Type       = D3DLIGHT_POINT;  
    light.Diffuse.r  = 1.0f;
    light.Diffuse.g  = 1.0f;
    light.Diffuse.b  = 1.0f;

	//light.Direction.x = - 1.0f;
	//light.Direction.y =  -1.0f;
	//light.Direction.z = 1.0f;

	static float h = 10000;
	float lx,ly,lz;           //光源位置
	lx = 1000.0f * sinf(timeGetTime()/360.0f);
	ly = 1000.0f;
	lz = 1000.0f * cosf(timeGetTime()/360.0f);
	light.Position= D3DXVECTOR3(lx,ly,lz);
	light.Direction = D3DXVECTOR3(lx, 1000, lz);

    light.Range        = 100.0f;
	light.Attenuation0 = 0.9f;
    light.Attenuation1 = 0.0f;

	LIGHTMANAGER.SetLight(light, 0);

	g_fCameraSpeed = 100.0f;

	//g_Mesh.Update();

	//for(zerO::UINT i = 0; i < NUM_LIGHTS; i ++)
	//	g_Light[i].Update();

	static FLOAT x = 0, y = 0, z = 0, RotationY = 0, RotationX = 0;

	CAMERA.SetRotation( 
		D3DXVECTOR3(RotationX / 180 * D3DX_PI, RotationY / 180 * D3DX_PI, 0.0f) );
	/*CAMERA.SetPosition( 
		D3DXVECTOR3(CAMERA.GetPosition().x, 
		g_TerrainSystem.GetTerrain()->GetHeight(CAMERA.GetPosition().x, CAMERA.GetPosition().z) + 100.0f, 
		CAMERA.GetPosition().z) );*/

	if( DXUTIsKeyDown(VK_UP) )
		RotationX += 1.0f;
	
	if( DXUTIsKeyDown(VK_DOWN) )
		RotationX -= 1.0f;

	BOOL bIsHit;
	zerO::FLOAT fDistance;

	HRESULT hr;

	if( DXUTIsKeyDown(VK_LEFT) )
	{
		hr = D3DXIntersect(g_Mesh.GetMesh().GetMesh(), &CAMERA.GetWorldPosition(), &-CAMERA.GetWorldRight(), (BOOL*)&bIsHit, NULL, NULL , NULL, &fDistance, NULL, NULL);

		if( SUCCEEDED(hr) && bIsHit )
		{
			if(fDistance > 1000.0f)
				CAMERA.Right(- g_fCameraSpeed);
		}
		else
			CAMERA.Right(- g_fCameraSpeed);
	}

	if( DXUTIsKeyDown(VK_RIGHT) )
	{
		hr = D3DXIntersect(g_Mesh.GetMesh().GetMesh(), &CAMERA.GetWorldPosition(), &CAMERA.GetWorldRight(), (BOOL*)&bIsHit, NULL, NULL , NULL, &fDistance, NULL, NULL);

		if( SUCCEEDED(hr) && bIsHit )
		{
			if(fDistance > 1000.0f)
				CAMERA.Right(  g_fCameraSpeed);
		}
		else
			CAMERA.Right(  g_fCameraSpeed);
	}
	
	if( DXUTIsKeyDown('W') )
	{
		hr = D3DXIntersect(g_Mesh.GetMesh().GetMesh(), &CAMERA.GetWorldPosition(), &CAMERA.GetWorldForward(), (BOOL*)&bIsHit, NULL, NULL , NULL, &fDistance, NULL, NULL);

		if( SUCCEEDED(hr) && bIsHit )
		{
			if(fDistance > 1000.0f)
				CAMERA.Forward(  g_fCameraSpeed);
		}
		else
			CAMERA.Forward(  g_fCameraSpeed);
	}

	if( DXUTIsKeyDown('S') )
	{
		hr = D3DXIntersect(g_Mesh.GetMesh().GetMesh(), &CAMERA.GetWorldPosition(), &-CAMERA.GetWorldForward(), (BOOL*)&bIsHit, NULL, NULL , NULL, &fDistance, NULL, NULL);

		if( SUCCEEDED(hr) && bIsHit )
		{
			if(fDistance > 1000.0f)
				CAMERA.Forward(- g_fCameraSpeed);
		}
		else
			CAMERA.Forward(- g_fCameraSpeed);
	}

	if( DXUTIsKeyDown('A') )
		RotationY -= 1.0f;

	if( DXUTIsKeyDown('D') )
		RotationY += 1.0f;

	GAMEHOST.Update(fElapsedTime);
}

//-----------------------------------------------------------------------------
// Desc: 渲染文本
//-----------------------------------------------------------------------------
void RenderText()
{
    CDXUTTextHelper txtHelper( g_pFont, g_pTextSprite, 15 );

    //显示当前Direct3D设备状态和渲染帧速率
    txtHelper.Begin();
    txtHelper.SetInsertionPos( 5, 5 );
    txtHelper.SetForegroundColor( D3DXCOLOR( 1.0f, 1.0f, 0.0f, 1.0f ) );
    txtHelper.DrawTextLine( DXUTGetFrameStats(true) );
    txtHelper.DrawTextLine( DXUTGetDeviceStats() );

    txtHelper.End();
}

//--------------------------------------------------------------------------------------
// Render the scene using the D3D9 device
//--------------------------------------------------------------------------------------
void CALLBACK OnD3D9FrameRender( IDirect3DDevice9* pd3dDevice, double fTime, float fElapsedTime, void* pUserContext )
{
    HRESULT hr;

    // Clear the render target and the zbuffer 
    V( pd3dDevice->Clear( 0, NULL, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER | D3DCLEAR_STENCIL, D3DCOLOR_ARGB( 0, 45, 50, 170 ), 1.0f, 0 ) );

    // Render the scene
    if( SUCCEEDED( pd3dDevice->BeginScene() ) )
    {
		//开始渲染
		//g_Game.BeginRender();

		//g_Mesh.ApplyForRender();

		//for(zerO::UINT i = 0; i < NUM_LIGHTS; i ++)
		//	g_Light[i].ApplyForRender();

		//结束渲染
		//g_Game.EndRender();
		g_Game.Render();

		//渲染文本和控件
        DXUT_BeginPerfEvent( DXUT_PERFEVENTCOLOR, L"HUD / Stats" ); 
        RenderText();
        DXUT_EndPerfEvent();

        V( pd3dDevice->EndScene() );
    }
}


//--------------------------------------------------------------------------------------
// Handle messages to the application 
//--------------------------------------------------------------------------------------
LRESULT CALLBACK MsgProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam,
                          bool* pbNoFurtherProcessing, void* pUserContext )
{
	switch(lParam)
	{
	//case WM_LBUTTONUP:
	//	break;
	case WM_MBUTTONDBLCLK:
		
		break;
	}

    return 0;
}


//--------------------------------------------------------------------------------------
// Release D3D9 resources created in the OnD3D9ResetDevice callback 
//--------------------------------------------------------------------------------------
void CALLBACK OnD3D9LostDevice( void* pUserContext )
{
	//自动化释放
	DEBUG_ASSERT(GAMEHOST.Disable(), "Disable error.");

	if( g_pFont )
        g_pFont->OnLostDevice();

    SAFE_RELEASE( g_pTextSprite );
}


//--------------------------------------------------------------------------------------
// Release D3D9 resources created in the OnD3D9CreateDevice callback 
//--------------------------------------------------------------------------------------
void CALLBACK OnD3D9DestroyDevice( void* pUserContext )
{
	//自动化销毁
	DEBUG_ASSERT(GAMEHOST.Destroy(), "Destroy error.");

	SAFE_RELEASE( g_pFont );
}


//--------------------------------------------------------------------------------------
// Initialize everything and go into a render loop
//--------------------------------------------------------------------------------------
INT WINAPI wWinMain( HINSTANCE, HINSTANCE, LPWSTR, int )
{
    // Enable run-time memory check for debug builds.
#if defined(DEBUG) | defined(_DEBUG)
    _CrtSetDbgFlag( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF );
#endif

    // Set the callback functions
    DXUTSetCallbackD3D9DeviceAcceptable( IsD3D9DeviceAcceptable );
    DXUTSetCallbackD3D9DeviceCreated( OnD3D9CreateDevice );
    DXUTSetCallbackD3D9DeviceReset( OnD3D9ResetDevice );
    DXUTSetCallbackD3D9FrameRender( OnD3D9FrameRender );
    DXUTSetCallbackD3D9DeviceLost( OnD3D9LostDevice );
    DXUTSetCallbackD3D9DeviceDestroyed( OnD3D9DestroyDevice );
    DXUTSetCallbackDeviceChanging( ModifyDeviceSettings );
    DXUTSetCallbackMsgProc( MsgProc );
    DXUTSetCallbackFrameMove( OnFrameMove );

    // TODO: Perform any application-level initialization here

    // Initialize DXUT and create the desired Win32 window and Direct3D device for the application
    DXUTInit( true, true ); // Parse the command line and show msgboxes
    DXUTSetHotkeyHandling( true, true, true );  // handle the default hotkeys
    DXUTSetCursorSettings( true, true ); // Show the cursor and clip it when in full screen
    DXUTCreateWindow( L"Sample" );
    DXUTCreateDevice( true, 640, 480 );

	//DXUTToggleFullScreen();

    // Start the render loop
    DXUTMainLoop();

    // TODO: Perform any application-level cleanup here

    return DXUTGetExitCode();
}


