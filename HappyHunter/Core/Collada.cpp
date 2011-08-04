#include "StdAfx.h"
#include "Collada.h"

using namespace zerO;

CCollada::CCollada(CSceneNode* pParent, zerO::UINT8 uFlag) :
CGeometry(pParent, uFlag)
{
}

CCollada::~CCollada(void)
{
}

bool CCollada::Create(const zerO::PUINT8 pData)
{
	m_Collada = (PBASICCHAR)pData;

	/*CXML Temp;

	if( m_Collada.GetChild(Temp, TEXT("asset") && Temp.GetChild(Temp, TEXT("asset") )*/

	return true;
}
