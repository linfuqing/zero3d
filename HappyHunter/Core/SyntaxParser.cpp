#include "StdAfx.h"
#include "SyntaxParser.h"
#include "debug.h"

using namespace zerO;

CSyntaxParser::CSyntaxParser(void)
{
}

CSyntaxParser::~CSyntaxParser(void)
{
}

//bool CSyntaxParser::CheckMatchingSymbols(const BASICCHAR* pcSource, LPMATCHINGINFO* ppMatchingInfo, bool* pbIsMatching, const BASICCHAR** ppcResult)
//{
//	UINT uIndex, uPosition = 0, uNumLines = 0;
//
//	LPMATCHINGINFO pMatchingInfo;
//
//	std::list<MATCHINGSYMBOL>::const_iterator i;
//
//	bool bIsTopLevel = false, bResult = true;
//
//	if(!pbIsMatching)
//	{
//		UINT uLength;
//
//		DEBUG_NEW(pbIsMatching, bool[uLength = m_MatchingSymbolsPool.size()]);
//
//		for(uIndex = 0; uIndex < uLength; uIndex ++)
//			pbIsMatching[uIndex] = true;
//
//		bIsTopLevel = true;
//	}
//
//	while(*pcSource)
//	{
//		uIndex = 0;
//
//		for(i = m_MatchingSymbolsPool.begin(); i != m_MatchingSymbolsPool.end(); i ++)
//		{
//			if(*pcSource == i->Left && pbIsMatching[uIndex])
//			{
//				pbIsMatching[uIndex] = false;
//
//				if(ppcResult)
//					*ppcResult = pcSource;
//
//				pcSource ++;
//
//				while(!pbIsMatching[uIndex] && *pcSource)
//					bResult = bResult && CheckMatchingSymbols(pcSource, ppMatchingInfo, pbIsMatching, &pcSource);
//
//				if( !(*pcSource) )
//				{
//					if(ppMatchingInfo)
//					{
//						DEBUG_NEW(pMatchingInfo, MATCHINGINFO);
//						
//						pMatchingInfo->uPosition      = uPosition;
//						pMatchingInfo->uLines         = uNumLines;
//						pMatchingInfo->Symbol         = *i;
//						pMatchingInfo->bIsNoMatchLeft = false;
//
//						if(*ppMatchingInfo)
//							(*ppMatchingInfo)->pNext = pMatchingInfo;
//
//						*ppMatchingInfo = pMatchingInfo;
//					}
//
//					if(ppcResult)
//						*ppcResult = pcSource;
//
//					return false;
//				}
//			}
//			else if(*pcSource == i->Right)
//			{
//				if(pbIsMatching[uIndex])
//				{
//					if(ppMatchingInfo)
//					{
//						DEBUG_NEW(pMatchingInfo, MATCHINGINFO);
//							
//						pMatchingInfo->uPosition      = uPosition;
//						pMatchingInfo->uLines         = uNumLines;
//						pMatchingInfo->Symbol         = *i;
//						pMatchingInfo->bIsNoMatchLeft = false;
//
//						if(*ppMatchingInfo)
//							(*ppMatchingInfo)->pNext = pMatchingInfo;
//
//						*ppMatchingInfo = pMatchingInfo;
//					}
//
//					bResult = false;
//				}
//				else
//				{
//					pbIsMatching[uIndex] = true;
//
//					if(ppcResult)
//						*ppcResult = pcSource;
//
//					return bResult;
//				}
//			}
//
//			uIndex ++;
//		}
//
//		uPosition ++;
//
//		if( *pcSource == TEXT('\n') )
//			uNumLines ++;
//
//		pcSource ++;
//	}
//
//	if(ppcResult)
//		*ppcResult = pcSource;
//
//	if(bIsTopLevel)
//	{
//		DEBUG_DELETE_ARRAY(pbIsMatching);
//
//		return bResult;
//	}
//
//	return false;
//}

bool CSyntaxParser::CheckMatchingSymbols(const BASICCHAR* pcSource, LPMATCHINGINFO* ppMatchingInfo)
{
	const BASICCHAR* pcTemp;
	LPMATCHINGINFO pMatchingInfoTail;
	UINT uPosition = 0, uLines = 0;

	bool bResult = true;

	for(std::list<MATCHINGSYMBOL>::const_iterator i = m_MatchingSymbolsPool.begin(); i != m_MatchingSymbolsPool.end(); i ++)
	{
		pcTemp    = pcSource;
		uPosition = 0;
		uLines    = 0;
		bResult   = __CheckMatchingSymbol((PBASICCHAR*)&pcTemp, *i, NULL, ppMatchingInfo, &pMatchingInfoTail, &uPosition, &uLines) && bResult;
	}

	return bResult;
}

bool CSyntaxParser::__CheckMatchingSymbol(
	PBASICCHAR* pcHead, 
	const MATCHINGSYMBOL& MatchingSymbol,
	bool* pbIsMatch,
	LPMATCHINGINFO* ppMatchingInfoHead, 
	LPMATCHINGINFO* ppMatchingInfoTail,
	zerO::PUINT puPosition,
	zerO::PUINT puLines
	)
{
	if( !pcHead && !(*pcHead) )
	{
		DEBUG_WARNING("");

		return false;
	}

	LPMATCHINGINFO pMatchingInfo;

	bool bIsMatch, bResult = true; 

	UINT uPosition, uLines;

	while(**pcHead)
	{
		if( **pcHead == MatchingSymbol.Left && ( MatchingSymbol.Left != MatchingSymbol.Right || (!pbIsMatch || *pbIsMatch) ) )
		{
			bIsMatch = false;

			uPosition = *puPosition;
			uLines    = *puLines;

			(*puPosition) ++;

			if( **pcHead == TEXT('\n') )
				(*puLines) ++;

			(*pcHead) ++;

			while(!bIsMatch && **pcHead)
				bResult = bResult && __CheckMatchingSymbol(pcHead, MatchingSymbol, &bIsMatch, ppMatchingInfoHead, ppMatchingInfoTail, puPosition, puLines);

			if( !(**pcHead) || !bIsMatch)
			{
				if(ppMatchingInfoHead)
				{
					DEBUG_NEW(pMatchingInfo, MATCHINGINFO);
					
					pMatchingInfo->uPosition      = uPosition;
					pMatchingInfo->uLines         = uLines;
					pMatchingInfo->Symbol         = MatchingSymbol;
					pMatchingInfo->bIsNoMatchLeft = false;
					pMatchingInfo->pNext          = NULL;

					if(!ppMatchingInfoTail)
						ppMatchingInfoTail = ppMatchingInfoHead;

					if( !(*ppMatchingInfoHead) )
						*ppMatchingInfoHead = *ppMatchingInfoTail = pMatchingInfo;
					else
						(*ppMatchingInfoTail)->pNext = pMatchingInfo;

					*ppMatchingInfoTail = pMatchingInfo;
				}

				return false;
			}
		}
		else if(**pcHead == MatchingSymbol.Right)
		{
			if( (!pbIsMatch || *pbIsMatch) )
			{
				if(ppMatchingInfoHead)
				{
					DEBUG_NEW(pMatchingInfo, MATCHINGINFO);
					
					pMatchingInfo->uPosition      = *puPosition;
					pMatchingInfo->uLines         = *puLines;
					pMatchingInfo->Symbol         = MatchingSymbol;
					pMatchingInfo->bIsNoMatchLeft = true;
					pMatchingInfo->pNext          = NULL;

					if(!ppMatchingInfoTail)
						ppMatchingInfoTail = ppMatchingInfoHead;

					if( !(*ppMatchingInfoHead) )
						*ppMatchingInfoHead = pMatchingInfo;
					else
						(*ppMatchingInfoTail)->pNext = pMatchingInfo;

					*ppMatchingInfoTail = pMatchingInfo;
				}

				bResult = false;
			}
			else
			{
				if(pbIsMatch)
					*pbIsMatch = true;

				return bResult;
			}
		}

		(*puPosition) ++;

		if( **pcHead == TEXT('\n') )
			(*puLines) ++;

		(*pcHead) ++;
	}

	return bResult;
}