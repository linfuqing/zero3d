#pragma once

#include "debug.h"
#include "datatype.h"
#include "coretype.h"
#include "LightManager.h"
#include "FogManager.h"
#include "color.h"
//#include "Camera.h"
#include "SceneManager.h"
#include "SceneObject.h"
#include <vector>
#include <list>

namespace zerO
{

#define GAMEHOST     zerO::CGameHost::GetInstance()
#define DIRECT       GAMEHOST.GetDirect()
#define DEVICE       GAMEHOST.GetDevice()
#define CAMERA       GAMEHOST.GetCamera()
#define RENDERQUEUE  GAMEHOST.GetRenderQueue()
#define ELAPSEDTIME  GAMEHOST.GetElapsedTime()
#define TIME         GAMEHOST.GetTime()
#define LIGHTMANAGER GAMEHOST.GetLightManager()
#define FOGMANAGER   GAMEHOST.GetFogManager()

	class CResource;
	class CRenderQueue;
	//class CSceneNode;
	//class CCamera;
	class CBackground;
	class CWater;
	class CShadow;
	class CVertexBuffer;
	class CTexture;
	class CFullScreenEffect;
	class CTexturePrinter;

	///
	// 主渲染框架类，单件模式，包含资源池，帧渲染调用，
	// 其中资源池采用链表与静态数组结合，以便使用索引句柄进行快速查找与插入。
	// 各种情况继承CGameHost然后重写Create方法.
	///
	class CGameHost
	{
		typedef struct
		{
			D3DXVECTOR4 Position;
			D3DCOLOR    Color;
			D3DXVECTOR2 UV;
		}VERTEX, * LPVERTEX;
	public:
		typedef struct
		{
			UINT AdapterOrdinal;
			D3DDEVTYPE DeviceType;
			D3DFORMAT AdapterFormat;
			DWORD BehaviorFlags;
			D3DPRESENT_PARAMETERS pp;
		}DEVICESETTINGS, * LPDEVICESETTINGS;

		CGameHost(void);
		~CGameHost(void);

		static bool IsGameHostCreated();

		IDirect3D9& GetDirect();
		IDirect3DDevice9& GetDevice();
		CRenderQueue& GetRenderQueue();
		static CGameHost& GetInstance();

		bool GetLightEnable()const;
		bool GetFogEnable()const;
		//bool GetSceneEnable()const;

		FLOAT GetElapsedTime()const;
		FLOAT64 GetTime()const;

		CCamera& GetCamera();

		CSceneNode& GetScene();

		CBackground* GetBackground()const;

		CWater* GetWater()const;

		CTexturePrinter* GetTexturePrinter()const;

		CLightManager& GetLightManager();
		CFogManager& GetFogManager();

		const D3DCAPS9& GetCaps()const;
		const DEVICESETTINGS& GetDeviceSettings()const;
		const D3DSURFACE_DESC& GetBackBufferSurfaceDesc()const;

		void SetLightEnable(bool bValue);
		void SetFogEnable(bool bValue);
		//void SetSceneEnable(bool bValue);

		void SetShadowColor(ARGBCOLOR Color);

		void SetBackground(CBackground* pBackground);

		void SetWater(CWater* pWater);

		void SetFullScreenEffect(CFullScreenEffect* pFullScreenEffect);

		RESOURCEHANDLE AddResource(CResource* const pResource, RESOURCETYPE Type);
		CResource* GetResource(RESOURCEHANDLE Handle, RESOURCETYPE Type);
		void RemoveResource(const CResource* pResource, RESOURCETYPE Type);

		void AddShadow(CShadow* const pShadow);
		void RemoveShadow(CShadow* const pShadow);

		void AddSceneManager(CSceneManager& SceneManager);
		void RemoveSceneManager(CSceneManager& SceneManager);

		void AddSceneObject(CSceneObject& SceneObject);
		void RemoveSceneObject(CSceneObject& SceneObject);

		void FillFullScreen(ARGBCOLOR Color = 0);

		virtual bool Destroy(); 
		virtual bool Disable(); 
		virtual bool Restore(const D3DSURFACE_DESC& BackBufferSurfaceDesc); 

		virtual bool Create(LPDIRECT3D9 pDirect, LPDIRECT3DDEVICE9 pDevice, const DEVICESETTINGS& DeviceSettings, UINT uMaxQueue);
		virtual bool Update(FLOAT fElapsedTime);
		virtual bool UpdateCamera();
		virtual bool UpdateBeforeRender();
		//virtual bool BeginRender();
		//virtual bool EndRender();
		virtual bool RenderBackground();
		virtual bool RenderScene();
		virtual bool Render();
	private:
		LPDIRECT3D9 m_pDirect;
		LPDIRECT3DDEVICE9 m_pDevice;
		D3DCAPS9 m_Caps;
		DEVICESETTINGS m_DeviceSettings;
		D3DSURFACE_DESC m_DeviceSurfaceDest;
		FLOAT m_fElapsedTime;
		FLOAT64 m_fTime;

		static CGameHost* sm_pInstance;

		std::vector<CResource*> m_ResourceList[TOTAL_RESOURCE_TYPES];

		std::list<CShadow*>     m_ShadowList;
		std::list<CSceneManager*> m_SceneManagerList;
		std::list<CSceneObject*> m_SceneObjectList;

		CRenderQueue* m_pRenderQueue;

		CSceneNode m_Scene;

		CSceneManagerEntry* m_pSearchList;

		CCamera* m_pCamera;

		CBackground* m_pBackground;

		CWater* m_pWater;

		CLightManager m_LightManager;
		CFogManager   m_FogManager;

		CVertexBuffer* m_pVertexBuffer;

		CTexture* m_pRenderTarget;

		CTexturePrinter* m_pTexturePrinter;

		CFullScreenEffect* m_pFullScreenEffect;

		bool m_bLightEnable;
		bool m_bFogEnable;
		//bool m_bSceneEnable;

		ARGBCOLOR m_ShadowColor;
	};

	inline bool CGameHost::IsGameHostCreated()
	{
		return sm_pInstance != NULL;
	}

	inline IDirect3D9& CGameHost::GetDirect()
	{
		DEBUG_ASSERT(m_pDirect, "The game host has not yet been created.");

		return *m_pDirect;
	}

	inline IDirect3DDevice9& CGameHost::GetDevice()
	{
		DEBUG_ASSERT(m_pDevice, "The game host has not yet been created.");

		return *m_pDevice;
	}

	inline CRenderQueue& CGameHost::GetRenderQueue()
	{
		return *m_pRenderQueue;
	}

	inline CGameHost& CGameHost::GetInstance()
	{
		DEBUG_ASSERT(sm_pInstance, "The game host has not yet been defined.");

		return *sm_pInstance;
	}

	inline const D3DCAPS9& CGameHost::GetCaps()const
	{
		return m_Caps;
	}

	inline bool CGameHost::GetLightEnable()const
	{
		return m_bLightEnable;
	}

	inline bool CGameHost::GetFogEnable()const
	{
		return m_bFogEnable;
	}

	/*inline bool CGameHost::GetSceneEnable()const
	{
		return m_bSceneEnable;
	}*/

	inline CCamera& CGameHost::GetCamera()
	{
		return *m_pCamera;
	}

	inline CSceneNode& CGameHost::GetScene()
	{
		return m_Scene;
	}

	inline CBackground* CGameHost::GetBackground()const
	{
		return m_pBackground;
	}

	inline CTexturePrinter* CGameHost::GetTexturePrinter()const
	{
		return m_pTexturePrinter;
	}

	inline const CGameHost::DEVICESETTINGS& CGameHost::GetDeviceSettings()const
	{
		return m_DeviceSettings;
	}

	inline const D3DSURFACE_DESC& CGameHost::GetBackBufferSurfaceDesc()const
	{
		return m_DeviceSurfaceDest;
	}

	inline FLOAT CGameHost::GetElapsedTime()const
	{
		return m_fElapsedTime;
	}

	inline FLOAT64 CGameHost::GetTime()const
	{
		return m_fTime;
	}

	inline CLightManager& CGameHost::GetLightManager()
	{
		return m_LightManager;
	}

	inline CFogManager& CGameHost::GetFogManager()
	{
		return m_FogManager;
	}

	inline void CGameHost::SetBackground(CBackground* pBackground)
	{
		m_pBackground = pBackground;
	}

	inline void CGameHost::SetWater(CWater* pWater)
	{
		m_pWater = pWater;
	}

	inline void CGameHost::SetFullScreenEffect(CFullScreenEffect* pFullScreenEffect)
	{
		m_pFullScreenEffect = pFullScreenEffect;
	}

	inline void CGameHost::SetLightEnable(bool bValue)
	{
		m_bLightEnable = bValue;
	}

	inline void CGameHost::SetFogEnable(bool bValue)
	{
		m_bFogEnable = bValue;
	}

	/*inline void CGameHost::SetSceneEnable(bool bValue)
	{
		m_bSceneEnable = bValue;
	}*/

	inline void CGameHost::SetShadowColor(ARGBCOLOR Color)
	{
		m_ShadowColor = Color;
	}
}
