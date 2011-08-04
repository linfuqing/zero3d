#pragma once

#include "Geometry.h"
#include "XML.h"

namespace zerO
{
	class CCollada :
		public CGeometry
	{
	public:
		CCollada(CSceneNode* pParent = NULL, UINT8 uFlag = CGeometry::POSITION | CGeometry::INFO | CGeometry::STATIC_VERTEX | CGeometry::STATIC_INDEX);
		~CCollada(void);

		bool Create(const PUINT8 pData);

	private:
		CXML m_Collada;
	};
}
