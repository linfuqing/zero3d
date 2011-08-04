#include "StdAfx.h"
#include "SceneObject.h"
#include "GameHost.h"

using namespace zerO;

CSceneObject::CSceneObject(void)
{
	GAMEHOST.AddSceneObject(*this);
}

CSceneObject::~CSceneObject(void)
{
	Destroy();
}

bool CSceneObject::Destroy()
{
	return true;
}

void CSceneObject::UpdateBeforeRender()
{
}