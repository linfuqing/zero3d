#pragma once

#include <list>
#include "datatype.h"

namespace zerO
{
	class CSyntaxParser
	{
	public:
		typedef struct MATCHINGSYMBOL
		{
			BASICCHAR Left;
			BASICCHAR Right;

			bool operator==(const MATCHINGSYMBOL& MatchingSymbol)
			{
				return Left == MatchingSymbol.Left && Right == MatchingSymbol.Right;
			}
		}MATCHINGSYMBOL;

		typedef struct MATCHINGINFO
		{
			UINT uPosition;
			UINT uLines;
			MATCHINGSYMBOL Symbol;
			bool bIsNoMatchLeft;
			MATCHINGINFO* pNext;

			bool operator==(const MATCHINGINFO& MatchingInfo)
			{
				return uPosition == MatchingInfo.uPosition && uLines == MatchingInfo.uLines && Symbol == MatchingInfo.Symbol && bIsNoMatchLeft == MatchingInfo.bIsNoMatchLeft;
			}
		}MATCHINGINFO, * LPMATCHINGINFO;

		CSyntaxParser(void);
		~CSyntaxParser(void);

		void Add(const MATCHINGSYMBOL& MatchingSymbol);
		void Remove(const MATCHINGSYMBOL& MatchingSymbol); 

		bool CheckMatchingSymbols(const BASICCHAR* pcSource, LPMATCHINGINFO* ppMatchingInfo = NULL);
	private:
		bool __CheckMatchingSymbol(
			PBASICCHAR* pcHead, 
			const MATCHINGSYMBOL& MatchingSymbol,
			bool* pbIsMatch = NULL,
			LPMATCHINGINFO* ppMatchingInfoHead = NULL, 
			LPMATCHINGINFO* ppMatchingInfoTail = NULL,
			PUINT puPosition = NULL,
			PUINT puLines    = NULL);

		std::list<MATCHINGSYMBOL> m_MatchingSymbolsPool;
	};

	__forceinline void CSyntaxParser::Add(const MATCHINGSYMBOL& MatchingSymbol)
	{
		m_MatchingSymbolsPool.push_back(MatchingSymbol);
	}

	__forceinline void CSyntaxParser::Remove(const MATCHINGSYMBOL& MatchingSymbol)
	{
		m_MatchingSymbolsPool.remove(MatchingSymbol);
	}
}