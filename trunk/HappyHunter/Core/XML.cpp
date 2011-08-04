#include "StdAfx.h"
#include "XML.h"

using namespace zerO;

CXML::CXML(void)
{
}

CXML::CXML(PBASICCHAR pcBuffer)
{
	DEBUG_ASSERT(IsXML(pcBuffer), "Error XML.");

	m_sText = pcBuffer;
}

CXML::~CXML(void)
{
}

bool CXML::IsXML(PBASICCHAR pcSource)
{
	return true;
}

bool CXML::Create()
{
	return true;
}

//CXML* CXML::GetAttribute(CXML& Output, const PBASICCHAR pcLabel)
//{
//	CBasicString sLabel(pcLabel), 
//		sBegin(TEXT('<') + sLabel), 
//		sEnd( TEXT("</") + sLabel + TEXT('>') );
//
//	UINT uBegin, uEnd;
//
//	if( ( uBegin = m_sText.find(sBegin) ) != CBasicString::npos )
//	{
//		uEnd = m_sText.find(sEnd, uBegin);
//
//		if(uEnd == CBasicString::npos)
//			uEnd = m_sText.find(TEXT("/>"), uBegin);
//	}
//	else
//	{
//		if( ( uBegin = m_sText.find(sLabel) ) == CBasicString::npos )
//		{
//			DEBUG_WARNING("No the label!");
//
//			return NULL;
//		}
//
//		uEnd = m_sText.find(TEXT(' '), uBegin);
//
//		if( uEnd == CBasicString::npos)
//			uEnd = m_sText.find(TEXT("/>"), uBegin);
//
//		sEnd = TEXT("");
//	}
//
//	if( uEnd == CBasicString::npos || m_sText.find(TEXT('<'), uBegin + sBegin.size() + 1) < uEnd )
//	{
//		DEBUG_WARNING("bad label!");
//
//		return NULL;
//	}
//
//	Output.m_sText       = m_sText.substr(uBegin, uEnd + sEnd.size() - uBegin);
//	Output.m_pcNameSpace = pcLabel;
//
//	return &Output;
//}

const PBASICCHAR CXML::GetAttribute(CBasicString& Output, const PBASICCHAR pcLabel)
{
	CBasicString sLabel(pcLabel);

	UINT uBegin, uEnd = CBasicString::npos, uSize = sLabel.size();

	/*if( CBasicString::npos == ( uBegin = m_sText.find( sLabel                                 ) ) || ( uEnd   = m_sText.find( TEXT('>') ) ) < uBegin || 
		CBasicString::npos == ( uBegin = m_sText.find( TEXT('\"'), sLabel.size() + uBegin + 1 ) ) ||
		CBasicString::npos == ( uEnd   = m_sText.find( TEXT('\"'),              ++ uBegin     ) ) )
	{
		DEBUG_WARNING("No the label!");

		return NULL;
	}

	return (const PBASICCHAR)( Output = m_sText.substr(uBegin, uEnd - uBegin) ).c_str();*/

	if( CBasicString::npos != ( uBegin = m_sText.find(sLabel) ) )
	{
		if( m_sText[uBegin += uSize] == TEXT('=') && m_sText[++ uBegin] == TEXT('\"') )
			uEnd = m_sText.find( TEXT('\"'),                      ++ uBegin );
		else if( m_sText[uBegin] == TEXT('>') )
			uEnd = m_sText.find( TEXT("</") + sLabel + TEXT('>'), ++ uBegin );

		if(CBasicString::npos != uEnd)
			return (const PBASICCHAR)( Output = m_sText.substr(uBegin, uEnd - uBegin) ).c_str();
	}
	else
		DEBUG_WARNING("No the label!");

	return NULL;
}

CXML* CXML::GetChild(CXML& Output, const BASICCHAR* pcLabel, const BASICCHAR* pcNameSpace)
{
	CBasicString sNameSpace, sLabel(pcLabel);

	UINT uBegin = 0, uEnd = 0, uMinBegin = 0, uMaxEnd = m_sText.size() - 1;

	PBASICCHAR pcSource = (PBASICCHAR)m_sText;

	if(!pcNameSpace)
		pcNameSpace = (PBASICCHAR)m_sNameSpace;

	if( __GetNameSpace(uMinBegin, uMaxEnd, pcSource, pcNameSpace) )
	{
		uMinBegin ++;

		while(uEnd < uMaxEnd)
		{
			uMinBegin += uEnd;

			if( !__GetNameSpace(sNameSpace, pcSource + uMinBegin, &uBegin, &uEnd) )
				break;

			if(sLabel == sNameSpace)
			{
				Output.m_sNameSpace = pcLabel;
				Output.m_sText      = m_sText.substr(uMinBegin + uBegin, uEnd - uBegin + 1);

				return &Output;
			}
		}
	}

	return NULL;
}

//CXML* CXML::GetChild(CXML& Output, const PBASICCHAR pcLabel)
//{
//	CBasicString sLabel(pcLabel), 
//		sBegin(TEXT('<') + sLabel), 
//		sEnd( TEXT("</") + sLabel + TEXT('>') );
//
//	UINT uBegin, uEnd;
//
//	if( ( uBegin = m_sText.find(sBegin) ) != CBasicString::npos )
//	{
//		uEnd = m_sText.find(sEnd, uBegin);
//
//		if(uEnd == CBasicString::npos)
//			uEnd = m_sText.find(TEXT("/>"), uBegin);
//
//		if( uEnd == CBasicString::npos || m_sText.find(TEXT('<'), uBegin + sBegin.size() + 1) < uEnd )
//		{
//			DEBUG_WARNING("bad label!");
//
//			return NULL;
//		}
//
//		Output.m_sText       = m_sText.substr(uBegin, uEnd + sEnd.size() - uBegin);
//		Output.m_pcNameSpace = pcLabel;
//
//		return &Output;
//	}
//
//	return NULL;
//}

bool CXML::__GetNameSpace(CBasicString& sOutput, const BASICCHAR* pcSource, zerO::PUINT puBegin, zerO::PUINT puEnd)
{
	UINT uBegin = 0, uEnd;

	bool bIsFindNameSpacePosition = false;

	const BASICCHAR* pcTemp = pcSource;

	while(*pcTemp)
	{
		if(!bIsFindNameSpacePosition)
		{
			if( *pcTemp == TEXT('<') && isalpha( *(pcTemp + 1) ) )
			{
				bIsFindNameSpacePosition = true;

				pcTemp ++;

				uEnd = uBegin + 2;
			}
			else
				uBegin ++;
		}
		else
		{
			if( *pcTemp == TEXT(' ') || *pcTemp == TEXT('>') )
			{
				sOutput.assign(pcSource, uBegin + 1, uEnd - uBegin - 1);

				if(puBegin)
					*puBegin = uBegin;

				if(puEnd)
				{
					if( *pcTemp == TEXT(' ') )
					{
						while(*++pcTemp)
						{
							uEnd ++;

							if( *pcTemp == TEXT('/') && *pcTemp == TEXT('>') )
							{
								uEnd ++;

								break;
							}
						}
					}
					else
						uEnd += STRSTR( pcTemp, ( TEXT("</") + sOutput + TEXT('>') ).c_str() ) - pcTemp + 2/*(2("</")+1('>')-1)*/ + sOutput.size();

					*puEnd = uEnd;

					/*bIsFindNameSpacePosition = false;

					while(*++pcTemp)
					{
						uEnd ++;

						if(!bIsFindNameSpacePosition)
						{
							if( *pcTemp == TEXT('<') )
								bIsFindNameSpacePosition = true;
							else if( *pcTemp == TEXT('/') && *pcTemp == TEXT('>') )
							{
								*puEnd = uEnd + 1;

								break;
							}
						}
						else
						{
							*puEnd = (UINT)STRSTR( pcTemp, ( TEXT("</") + sOutput + TEXT('>') ).c_str() );

							if(*puEnd)
							{
								*puEnd = (PBASICCHAR)(*puEnd) - pcTemp + uEnd;

								break;
							}
							else
								return false;
						}
					}*/
				}

				return true;
			}
			else
				uEnd ++;
		}

		pcTemp ++;
	}

	return false;
}

bool CXML::__GetNameSpace(
						  zerO::UINT& uBegin,
						  zerO::UINT& uEnd,
						  const BASICCHAR* pcSource, 
						  const BASICCHAR* pcLabel)
{
	CBasicString sSource(pcSource), sLabel(pcLabel);

	if( ( uBegin = sSource.find(TEXT('<') + sLabel) ) != CBasicString::npos )
	{
		if(sSource[uBegin + sLabel.size() + 1] == '>')
		{
			uEnd  = sSource.find( (TEXT("</") + sLabel + TEXT('>') ).c_str(), uBegin);

			uEnd += 2 + sLabel.size();
		}
		else
		{
			uEnd = sSource.find( TEXT("/>"), uBegin);

			uEnd ++;
		}

		return true;
	}

	return false;
}