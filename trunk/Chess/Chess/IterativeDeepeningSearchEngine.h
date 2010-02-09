#pragma once
//#include "searchengine.h"
#include "HistoryHeuristicSearchEngine.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CIterativeDeepeningSearchEngine :
	public CHistoryHeuristicSearchEngine<TYPE, WIDTH, HEIGHT>
{
public:
	CIterativeDeepeningSearchEngine(void) :
	  m_pnTopScore(NULL),
	  m_bIterativeDeepening(FALSE),
	  m_bReady(NULL)
	{
	}
	~CIterativeDeepeningSearchEngine(void)
	{
		delete m_pnTopScore;
	}

	inline VOID SetIterativeDeepening(const BOOL bIterativeDeepening)
	{
		m_bIterativeDeepening = bIterativeDeepening && m_pfnSort;
		m_bReady              = bIterativeDeepening;

		if(bIterativeDeepening && m_pMoveGenerator)
			m_pnTopScore = new INT[m_pMoveGenerator->m_uMaxMove];
		else
		{
			delete m_pnTopScore;
			m_pnTopScore = NULL;
		}
	}

	inline virtual VOID SetSortType( VOID (*pfnSort)(SEARCHMOVE gOutput[], SEARCHMOVE gMove[], INT ngScore[], const UINT uSize) )
	{
		m_bIterativeDeepening = m_pnTopScore && pfnSort;

		CHistoryHeuristicSearchEngine<TYPE, WIDTH, HEIGHT>::SetSortType(pfnSort);
	}

	inline virtual VOID SetMoveGenerator(CMoveGenerator<TYPE, WIDTH, HEIGHT>* const pMoveGenerator)
	{
		if(m_pnTopScore)
		{
			delete m_pnTopScore;

			m_pnTopScore = new INT[pMoveGenerator->m_uMaxMove];
		}

		if(m_bReady)
		{
			m_pnTopScore = new INT[pMoveGenerator->m_uMaxMove];
			m_bIterativeDeepening = m_pnTopScore && m_pfnSort;
		}

		CHistoryHeuristicSearchEngine<TYPE, WIDTH, HEIGHT>::SetMoveGenerator(pMoveGenerator);
	}
protected:
	UINT m_uCount;
	UINT m_uDepth;

	BOOL m_bIterativeDeepening;

	PINT m_pnTopScore;
private:
	BOOL m_bReady;
};
