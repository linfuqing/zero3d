#pragma once

#include "basicutils.h"

namespace zerO
{
	class CXML
	{
	public:
		CXML(void);
		CXML(PBASICCHAR pcBuffer);

		~CXML(void);

		static bool IsXML(PBASICCHAR pcSource);

		operator const PBASICCHAR()const;
		operator const CBasicString&()const;

		const PBASICCHAR GetNameSpace()const;
		void SetNameSpace(const BASICCHAR* pNameSpace);

		bool Create();

		const PBASICCHAR GetAttribute(CBasicString& Output, const PBASICCHAR pcLabel);

		CXML* GetChild(CXML& Output, const BASICCHAR* pcLabel, const BASICCHAR* pcNameSpace = NULL);

	//private:

		static bool __GetNameSpace(
			CBasicString& sOutput, 
			const BASICCHAR* pcSource,
			PUINT puBegin = NULL,
			PUINT puEnd   = NULL);

		static bool __GetNameSpace(
			UINT& uBegin,
			UINT& uEnd,
			const BASICCHAR* pcSource, 
			const BASICCHAR* pcLabel);

		CBasicString m_sNameSpace;
		CBasicString m_sText;
	};

	inline const PBASICCHAR CXML::GetNameSpace()const
	{
		return (PBASICCHAR)m_sNameSpace;
	}

	inline void CXML::SetNameSpace(const BASICCHAR* pNameSpace)
	{
		m_sNameSpace = pNameSpace;
	}

	inline CXML::operator const PBASICCHAR()const
	{
		return (PBASICCHAR)m_sText.c_str();
	}

	inline CXML::operator const CBasicString&()const
	{
		return m_sText;
	}
}
