//--------------------------------------------------------------------------------------
// File: Sample.cpp
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

#include "DXUT.h"
#include "resource.h"

#include "SDKmisc.h"

#include "core.h"

ID3DXFont*                 g_pFont = NULL;          //ID3DXFont�������
ID3DXSprite*               g_pTextSprite = NULL;    //ID3DXSprite�ı��������

zerO::CGameHost g_Game;

//zerO::CCrossPlane g_CrossPlane;
//zerO::CCrossPlane g_CopyPlane;
//zerO::CBillboard g_Billboard;
//zerO::CBillboard g_Copyboard;
zerO::CStaticMesh g_Mesh;
zerO::CStaticMesh g_OcclusionBox;
//zerO::CSurface   g_Surface;

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

	//��������
    V_RETURN( D3DXCreateFont( pd3dDevice, 15, 0, FW_BOLD, 1, FALSE, DEFAULT_CHARSET, 
                         OUT_DEFAULT_PRECIS, DEFAULT_QUALITY, DEFAULT_PITCH | FF_DONTCARE, 
                         L"Arial", &g_pFont ) );

	//����ģʽ��������Ҫ����һ��GameHost
	zerO::CGameHost::DEVICESETTINGS DeviceSettings;
	memcpy( &DeviceSettings, &DXUTGetDeviceSettings(), sizeof(zerO::CGameHost::DEVICESETTINGS) );

	if( !g_Game.Create(DXUTGetD3D9Object(), pd3dDevice, DeviceSettings, 0xff) )
		return S_FALSE;

	CAMERA.SetProjection(D3DX_PI / 4.0f, 1.0f, 0.5f, 3000.0f);

	g_Mesh.SetEffectFile( TEXT("ItemEffect.fx") );
	g_Mesh.Create( TEXT("sphere0.x") );

	// g_Billboard.Create(800, 600);

	///*g_CrossPlane.Create(800, 600, 5);*/

	// D3DMATERIAL9 Matrial;
	// memset( &Matrial, 0, sizeof(D3DMATERIAL9) );
 //    Matrial.Diffuse.r = Matrial.Ambient.r = 0.0f;
 //    Matrial.Diffuse.g = Matrial.Ambient.g = 1.0f;
 //    Matrial.Diffuse.b = Matrial.Ambient.b = 1.0f;
 //    Matrial.Diffuse.a = Matrial.Ambient.a = 1.0f;

	// g_Surface.SetMaterial(Matrial);
	// g_Surface.LoadTexture(TEXT("�ϰ��壨��ɫ��.png"), 0);
	// g_Billboard.GetRenderMethod().SetSurface(&g_Surface);
	// g_Billboard.GetRenderMethod().LoadEffect( TEXT("EffectTexture.fx") );
	// g_Billboard.SetupAnimation(16, 1);
	// g_Billboard.Play(0, 10);
	// /*g_CrossPlane.GetRenderMethod().SetSurface(&g_Surface);
	// g_CrossPlane.GetRenderMethod().LoadEffect( TEXT("EffectTexture.fx") );

	// g_CrossPlane.Clone(g_CopyPlane);
	// g_CopyPlane.SetPosition( D3DXVECTOR3(500.0f, 0.0f, 0.0f) );*/

	// g_Billboard.Clone(g_Copyboard);
	// g_Copyboard.SetPosition( D3DXVECTOR3(500.0f, 0.0f, 0.0f) );

		 //���õƹ�
	 D3DXVECTOR3 vecDir;
     D3DLIGHT9 light;
	 ZeroMemory( &light, sizeof(D3DLIGHT9) );
     light.Type       = D3DLIGHT_DIRECTIONAL;
     light.Diffuse.r  = 1.0f;
     light.Diffuse.g  = 1.0f;
     light.Diffuse.b  = 1.0f;
	 vecDir = D3DXVECTOR3(-1.0f, -1.0f, 2.0f);
     D3DXVec3Normalize( (D3DXVECTOR3*)&light.Direction, &vecDir );
	 light.Position = D3DXVECTOR3(-1.0f, -1.0f, 2.0f);
     light.Range       = 1000.0f;

	 LIGHTMANAGER.SetLight(light, 0);
	 LIGHTMANAGER.SetAmbient(0x00808080);

	 //GAMEHOST.SetLightEnable(true);

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Create any D3D9 resources that won't live through a device reset (D3DPOOL_DEFAULT) 
// or that are tied to the back buffer size 
//--------------------------------------------------------------------------------------
HRESULT CALLBACK OnD3D9ResetDevice( IDirect3DDevice9* pd3dDevice, const D3DSURFACE_DESC* pBackBufferSurfaceDesc,
                                    void* pUserContext )
{
	HRESULT hr;

		//�ָ�����
    if( g_pFont )
        V_RETURN( g_pFont->OnResetDevice() );
   
	//����ID3DXSprite�ӿڶ���
    V_RETURN( D3DXCreateSprite( pd3dDevice, &g_pTextSprite ) );

	//�Զ����ؽ���δ��ȫ��
	if( !GAMEHOST.Restore(*pBackBufferSurfaceDesc) )
		return S_FALSE;

    return S_OK;
}


//--------------------------------------------------------------------------------------
// Handle updates to the scene.  This is called regardless of which D3D API is used
//--------------------------------------------------------------------------------------
void CALLBACK OnFrameMove( double fTime, float fElapsedTime, void* pUserContext )
{
	GAMEHOST.Update(fElapsedTime);

	g_Mesh.Update();

	static FLOAT x = 0, y = 0, z = 0, RotationY = 0, RotationX = 0;

	CAMERA.SetRotation( 
		D3DXVECTOR3(RotationX / 180 * D3DX_PI, RotationY / 180 * D3DX_PI, 0.0f) );

	if( DXUTIsKeyDown(VK_UP) )
		RotationX += 1.0f;
	
	if( DXUTIsKeyDown(VK_DOWN) )
		RotationX -= 1.0f;

	if( DXUTIsKeyDown(VK_LEFT) )
		CAMERA.Right (- 1.0f);

	if( DXUTIsKeyDown(VK_RIGHT) )
		CAMERA.Right (  1.0f);

	if( DXUTIsKeyDown('W') )
		/*z += 10.0f;*/
		CAMERA.Forward(1.0f);

	if( DXUTIsKeyDown('S') )
		CAMERA.Forward(-1.0f);

	if( DXUTIsKeyDown('A') )
		RotationY -= 1.0f;

	if( DXUTIsKeyDown('D') )
		RotationY += 1.0f;

	/*g_Billboard.Update();
	g_Copyboard.Update();*/
	/*g_CrossPlane.Update();
	g_CopyPlane.Update();*/
}

//-----------------------------------------------------------------------------
// Desc: ��Ⱦ�ı�
//-----------------------------------------------------------------------------
void RenderText()
{
    CDXUTTextHelper txtHelper( g_pFont, g_pTextSprite, 15 );

    //��ʾ��ǰDirect3D�豸״̬����Ⱦ֡����
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
    V( pd3dDevice->Clear( 0, NULL, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER, D3DCOLOR_ARGB( 0, 45, 50, 170 ), 1.0f, 0 ) );

    // Render the scene
    if( SUCCEEDED( pd3dDevice->BeginScene() ) )
    {
		//��ʼ��Ⱦ
		g_Game.BeginRender();

		g_Mesh.ApplyForRender();
		//g_Billboard.ApplyForRender();
		//g_Copyboard.ApplyForRender();
		/*g_CrossPlane.ApplyForRender();
		g_CopyPlane.ApplyForRender();*/

		//������Ⱦ
		g_Game.EndRender();

		//��Ⱦ�ı��Ϳؼ�
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
    return 0;
}


//--------------------------------------------------------------------------------------
// Release D3D9 resources created in the OnD3D9ResetDevice callback 
//--------------------------------------------------------------------------------------
void CALLBACK OnD3D9LostDevice( void* pUserContext )
{
	if( g_pFont )
        g_pFont->OnLostDevice();
    SAFE_RELEASE( g_pTextSprite );

	//�Զ����ͷ�
	DEBUG_ASSERT(GAMEHOST.Disable(), "Disable error.");
}


//--------------------------------------------------------------------------------------
// Release D3D9 resources created in the OnD3D9CreateDevice callback 
//--------------------------------------------------------------------------------------
void CALLBACK OnD3D9DestroyDevice( void* pUserContext )
{
	SAFE_RELEASE( g_pFont );

	GAMEHOST.Destroy();
	//�Զ�������
	DEBUG_ASSERT(GAMEHOST.Destroy(), "Destroy error.");
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

    // Start the render loop
    DXUTMainLoop();

    // TODO: Perform any application-level cleanup here

    return DXUTGetExitCode();
}


