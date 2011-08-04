//--------------------------------------------------------------------------------------
// File: Sample.cpp
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------
#include "DXUT.h"
#include "resource.h"
#include "core.h"
#include "HDREffect.h"
//#include "UnderWaterEffect.h"

#include "SDKmisc.h"

#define NUM_LIGHTS 100


ID3DXFont*                 g_pFont = NULL;          //ID3DXFont字体对象
ID3DXSprite*               g_pTextSprite = NULL;    //ID3DXSprite文本精灵对象

LPDIRECT3DVERTEXBUFFER9    g_pBackgroundVB;         //背景矩形顶点缓冲区
LPDIRECT3DTEXTURE9         g_pBackgroundTexture;    //背景纹理
LPDIRECT3DVERTEXBUFFER9    g_pWaterVB;              //水波网格模型顶点缓冲区
LPDIRECT3DTEXTURE9         g_psBumpMap;             //凹凸纹理
D3DXMATRIXA16              g_matBumpMat;            //世界矩阵

const UINT g_n = 2;                            //水波网格模型x轴方向的顶点数目
const UINT g_m = 2;                            //水波网格模型y轴方向的顶点数目
const UINT g_nTriangles = (g_n-1)*(g_m-1)*2;   //水波网格模型的三角形数目

//-----------------------------------------------------------------------------
// Desc: 顶点结构与顶点格式
//-----------------------------------------------------------------------------
struct VERTEX
{
    D3DXVECTOR3 p;
    //float tu, tv;
    static const DWORD FVF;
};
const DWORD VERTEX::FVF = D3DFVF_XYZ;// | D3DFVF_TEX1;

inline DWORD F2DW( FLOAT f ) { return *((DWORD*)&f); }

//-----------------------------------------------------------------------------
// Desc: 创建凹凸纹理对象
//-----------------------------------------------------------------------------
HRESULT CreateBumpMap(IDirect3DDevice9* pd3dDevice)
{
	HRESULT hr = S_OK;
	UINT iWidth  = 256;
	UINT iHeight = 256;

	//创建凹凸纹理
   V_RETURN( pd3dDevice->CreateTexture( iWidth, iWidth, 1, 0, D3DFMT_V8U8, 
	                                    D3DPOOL_MANAGED, &g_psBumpMap, NULL ));

	//填充纹理元素 
    D3DLOCKED_RECT d3dlr;
    g_psBumpMap->LockRect( 0, &d3dlr, 0, 0 );
    CHAR* pDst = (CHAR*)d3dlr.pBits;
    CHAR  iDu, iDv;

    for( DWORD y=0; y<iHeight; y++ )
    {
        CHAR* pPixel = pDst;

        for( DWORD x=0; x<iWidth; x++ )
        {
            float fx = x/(FLOAT)iWidth - 0.5f;
            float fy = y/(FLOAT)iHeight - 0.2f;

            float r = sqrtf( fx*fx + fy*fy );

            iDu = (CHAR)( 64 * cosf( 300.0f * r ) * expf( -r * 5.0f ) );
            iDu = iDu + (CHAR)( 32 * cosf( 150.0f * ( fx + fy ) ) );
            iDu = iDu +(CHAR)( 16 * cosf( 140.0f * ( fx * 0.85f - fy ) ) );

            iDv = (CHAR)( 64 * sinf( 300.0f * r ) * expf( -r * 5.0f ) );
            iDv = iDv + (CHAR)( 32 * sinf( 150.0f * ( fx + fy ) ) );
            iDv = iDv + (CHAR)( 16 * sinf( 140.0f * ( fx * 0.85f - fy ) ) );

            *pPixel++ = iDu;
            *pPixel++ = iDv;
        }
        pDst += d3dlr.Pitch;
    }
    g_psBumpMap->UnlockRect(0);

	return hr;
}


//-----------------------------------------------------------------------------
// Desc: 设置纹理层渲染状态
//-----------------------------------------------------------------------------
HRESULT SetEMBMStates(IDirect3DDevice9* pd3dDevice, float fTime)
{
    //设置纹理层 0 的纹理渲染状态
    pd3dDevice->SetTexture( 0, g_psBumpMap );
	pd3dDevice->SetTextureStageState( 0, D3DTSS_COLOROP,   D3DTOP_BUMPENVMAPLUMINANCE );
	
	static float r = 0.04f;
    g_matBumpMat._11 =  r * cosf( (float)fTime * 9.0f );
    g_matBumpMat._12 = -r * sinf( (float)fTime * 9.0f );
    g_matBumpMat._21 =  r * sinf( (float)fTime * 9.0f );
    g_matBumpMat._22 =  r * cosf( (float)fTime * 9.0f );

    pd3dDevice->SetTextureStageState( 0, D3DTSS_BUMPENVMAT00,   F2DW( g_matBumpMat._11 ) );
	pd3dDevice->SetTextureStageState( 0, D3DTSS_BUMPENVMAT01,   F2DW( g_matBumpMat._12 ) );
	pd3dDevice->SetTextureStageState( 0, D3DTSS_BUMPENVMAT10,   F2DW( g_matBumpMat._21 ) );
	pd3dDevice->SetTextureStageState( 0, D3DTSS_BUMPENVMAT11,   F2DW( g_matBumpMat._22 ) );
	pd3dDevice->SetTextureStageState( 0, D3DTSS_BUMPENVLSCALE,  F2DW(0.8f) );
	pd3dDevice->SetTextureStageState( 0, D3DTSS_BUMPENVLOFFSET, F2DW(0.0f) );
	
	//设置纹理层 1 的纹理渲染状态
	pd3dDevice->SetTexture( 1, g_pBackgroundTexture );
	pd3dDevice->SetTextureStageState( 1, D3DTSS_COLOROP,   D3DTOP_SELECTARG1 );
	pd3dDevice->SetTextureStageState( 1, D3DTSS_COLORARG1, D3DTA_TEXTURE );
	pd3dDevice->SetTextureStageState( 1, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_CAMERASPACEPOSITION | 1 );
	pd3dDevice->SetTextureStageState( 1, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT3|D3DTTFF_PROJECTED );
	
	//设置纹理坐标变换矩阵
	static D3DXMATRIXA16 mat;
	mat._11 = 0.8f; mat._12 = 0.0f; mat._13 = 0.0f;
	mat._21 = 0.0f; mat._22 = 0.8f; mat._23 = 0.0f;
	mat._31 = 0.5f; mat._32 =-0.5f; mat._33 = 1.0f;
	mat._41 = 0.0f; mat._42 = 0.0f; mat._43 = 0.0f;
	pd3dDevice->SetTransform( D3DTS_TEXTURE1, &mat );
		
	return S_OK;
}

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

	//创建背景纹理
	V_RETURN( D3DXCreateTextureFromFile( pd3dDevice, L"Lake.bmp", &g_pBackgroundTexture ));
	
    //创建凹凸纹理
     CreateBumpMap(pd3dDevice);
    if( NULL == g_psBumpMap )
        return E_FAIL;

    //创建背景矩形顶点缓冲区
    V_RETURN( pd3dDevice->CreateVertexBuffer( 4*sizeof(VERTEX),
                                              D3DUSAGE_WRITEONLY, VERTEX::FVF,
                                              D3DPOOL_MANAGED, &g_pBackgroundVB, NULL ));

	//填充背景矩形顶点缓冲区
    VERTEX* v;
    g_pBackgroundVB->Lock( 0, 0, (void**)&v, 0 );
    v[0].p  = D3DXVECTOR3(-1000.0f,    0.0f, 0.0f );
    v[1].p  = D3DXVECTOR3(-1000.0f, 1000.0f, 0.0f );
    v[2].p  = D3DXVECTOR3( 1000.0f,    0.0f, 0.0f );
    v[3].p  = D3DXVECTOR3( 1000.0f, 1000.0f, 0.0f );
    //v[0].tu = 0.0f; v[0].tv = 147/256.0f;
    //v[1].tu = 0.0f; v[1].tv = 0.0f;
    //v[2].tu = 1.0f; v[2].tv = 147/256.0f;
    //v[3].tu = 1.0f; v[3].tv = 0.0f;
    g_pBackgroundVB->Unlock();
  
	//创建水波网格模型顶点缓冲区
    /*V_RETURN( pd3dDevice->CreateVertexBuffer( g_nTriangles*3*sizeof(VERTEX),
                                              D3DUSAGE_WRITEONLY, VERTEX::FVF,
                                              D3DPOOL_MANAGED, &g_pWaterVB, NULL ));

	//填充水波网格模型顶点缓冲区
    g_pWaterVB->Lock( 0, 0, (void**)&v, 0 );
    float dX = 2000.0f/(g_n-1);
    float dZ = 1250.0f/(g_m-1);
    float x0 = -1000;
    float z0 = -1250;
    float dU = 1.0f/(g_n-1);
    float dV = 0.7f/(g_m-1);
    UINT k = 0;
    for (UINT z=0; z < (g_m-1); z++)
    {
        for (UINT x=0; x < (g_n-1); x++)
        {
            v[k].p  = D3DXVECTOR3(x0 + x*dX, 0.0f, z0 + z*dZ );
            v[k].tu = x*dU;
            v[k].tv = z*dV;
            k++;
            v[k].p  = D3DXVECTOR3(x0 + x*dX, 0.0f, z0 + (z+1)*dZ );
            v[k].tu = x*dU;
            v[k].tv = (z+1)*dV;
            k++;
            v[k].p  = D3DXVECTOR3(x0 + (x+1)*dX, 0.0f, z0 + (z+1)*dZ );
            v[k].tu = (x+1)*dU;
            v[k].tv = (z+1)*dV;
            k++;
            v[k].p  = D3DXVECTOR3(x0 + x*dX, 0.0f, z0 + z*dZ );
            v[k].tu = x*dU;
            v[k].tv = z*dV;
            k++;
            v[k].p  = D3DXVECTOR3(x0 + (x+1)*dX, 0.0f, z0 + (z+1)*dZ );
            v[k].tu = (x+1)*dU;
            v[k].tv = (z+1)*dV;
            k++;
            v[k].p  = D3DXVECTOR3(x0 + (x+1)*dX, 0.0f, z0 + z*dZ );
            v[k].tu = (x+1)*dU;
            v[k].tv = z*dV;
            k++;
        }
    }
    g_pWaterVB->Unlock();*/

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

		//恢复字体
    if( g_pFont )
        V_RETURN( g_pFont->OnResetDevice() );
   
	//创建ID3DXSprite接口对象
    V_RETURN( D3DXCreateSprite( pd3dDevice, &g_pTextSprite ) );
/*
	//设置世界变换矩阵
	D3DXMATRIXA16 matWorld;
	D3DXMatrixIdentity( &matWorld );
	pd3dDevice->SetTransform( D3DTS_WORLD, &matWorld );

	//设置观察矩阵
	D3DXMATRIXA16 matView;
	D3DXVECTOR3 vEyePt(    0.0f, 400.0f, -1650.0f );
	D3DXVECTOR3 vLookatPt( 0.0f,   0.0f,     0.0f );
	D3DXVECTOR3 vUpVec(    0.0f,   1.0f,     0.0f );
	D3DXMatrixLookAtLH( &matView, &vEyePt, &vLookatPt, &vUpVec );
	pd3dDevice->SetTransform( D3DTS_VIEW, &matView );

	//设置投影矩阵
	D3DXMATRIXA16 matProj;
	D3DXMatrixPerspectiveFovLH( &matProj, 1.00f, 1.0f, 1.0f, 10000.0f );
	pd3dDevice->SetTransform( D3DTS_PROJECTION, &matProj );*/

	//设置纹理过滤方式
    pd3dDevice->SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
    pd3dDevice->SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );
    pd3dDevice->SetSamplerState( 1, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
    pd3dDevice->SetSamplerState( 1, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );

    return S_OK;
}

zerO::FLOAT g_fCameraSpeed;

//--------------------------------------------------------------------------------------
// Handle updates to the scene.  This is called regardless of which D3D API is used
//--------------------------------------------------------------------------------------
void CALLBACK OnFrameMove( double fTime, float fElapsedTime, void* pUserContext )
{
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

	static float y = 0;

	//设置世界变换矩阵
	D3DXMATRIXA16 matWorld;
	D3DXMatrixIdentity( &matWorld );
	pd3dDevice->SetTransform( D3DTS_WORLD, &matWorld );

	//设置观察矩阵
	D3DXMATRIXA16 matView;
	D3DXVECTOR3 vEyePt(    0.0f, 0, y - 100 );
	D3DXVECTOR3 vLookatPt( 0.0f,   100.0f,     0.0f );
	D3DXVECTOR3 vUpVec(    0.0f,   1.0f,     0.0f );
	D3DXMatrixLookAtLH( &matView, &vEyePt, &vLookatPt, &vUpVec );
	pd3dDevice->SetTransform( D3DTS_VIEW, &matView );

	//设置投影矩阵
	D3DXMATRIXA16 matProj;
	D3DXMatrixPerspectiveFovLH( &matProj, 1.00f, 1.0f, 0.0f, 10000.0f );
	pd3dDevice->SetTransform( D3DTS_PROJECTION, &matProj );

	//y ++;

    // Clear the render target and the zbuffer 
    V( pd3dDevice->Clear( 0, NULL, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER | D3DCLEAR_STENCIL, D3DCOLOR_ARGB( 0, 45, 50, 170 ), 1.0f, 0 ) );

    // Render the scene
    if( SUCCEEDED( pd3dDevice->BeginScene() ) )
    {
		//为渲染背景举行设置纹理渲染状态
		pd3dDevice->SetTexture( 0, g_pBackgroundTexture );
		pd3dDevice->SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
		pd3dDevice->SetTextureStageState( 0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1 );
		pd3dDevice->SetTextureStageState( 1, D3DTSS_COLOROP,   D3DTOP_DISABLE );

		pd3dDevice->SetTextureStageState( 0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_CAMERASPACEPOSITION );
		pd3dDevice->SetTextureStageState( 0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT3|D3DTTFF_PROJECTED );

		pd3dDevice->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_BORDER);
		pd3dDevice->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_BORDER);
		pd3dDevice->SetSamplerState(0, D3DSAMP_ADDRESSW, D3DTADDRESS_BORDER);

		D3DXVECTOR2 Scale(1.0f, 1.0f);

		//D3DXVec2Normalize(&Scale, &Scale);
		//设置纹理坐标变换矩阵
		static D3DXMATRIXA16 mat;
		mat._11 = Scale.x; mat._12 = 0.0f; mat._13 = 0.0f;
		mat._21 = 0.0f; mat._22 = -Scale.y; mat._23 = 0.0f;
		mat._31 = 0.5f; mat._32 = 0.5f; mat._33 = 1.0f;
		mat._41 = 0.0f; mat._42 = 0.0f; mat._43 = 0.0f;
		pd3dDevice->SetTransform( D3DTS_TEXTURE0, &mat );

		//渲染背景矩形
		pd3dDevice->SetFVF( VERTEX::FVF );
		pd3dDevice->SetStreamSource( 0, g_pBackgroundVB, 0, sizeof(VERTEX) );
		pd3dDevice->DrawPrimitive( D3DPT_TRIANGLESTRIP, 0, 2 );

		//为渲染水波设置纹理渲染状态
		//SetEMBMStates( pd3dDevice, (float)fTime );

		//渲染水波网格模型
		//pd3dDevice->SetFVF( VERTEX::FVF );
		//pd3dDevice->SetStreamSource( 0, g_pWaterVB, 0, sizeof(VERTEX) );
		//pd3dDevice->DrawPrimitive( D3DPT_TRIANGLELIST, 0, g_nTriangles );

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
	if( g_pFont )
        g_pFont->OnLostDevice();

    SAFE_RELEASE( g_pTextSprite );
}


//--------------------------------------------------------------------------------------
// Release D3D9 resources created in the OnD3D9CreateDevice callback 
//--------------------------------------------------------------------------------------
void CALLBACK OnD3D9DestroyDevice( void* pUserContext )
{
	SAFE_RELEASE( g_pFont );

	SAFE_RELEASE( g_pBackgroundTexture );
    SAFE_RELEASE( g_psBumpMap );
    SAFE_RELEASE( g_pBackgroundVB );
    SAFE_RELEASE( g_pWaterVB );
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


