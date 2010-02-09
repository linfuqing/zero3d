#pragma once
#include "searchengine.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CHistoryHeuristicSearchEngine :
	public CSearchEngine<TYPE, WIDTH, HEIGHT>
{
public:

	CHistoryHeuristicSearchEngine(void) :
	  m_pfnSort(NULL), 
		  m_pnProvisionalScore(NULL),
		  m_pHistory(NULL),
		  m_bHistoryHeuristic(FALSE)
	{
	}

	~CHistoryHeuristicSearchEngine(void)
	{
		delete m_pnProvisionalScore;
		delete m_pHistory;
	}

	inline VOID SetHistoryHeuristic(const BOOL bHistoryHeuristic)
	{
		m_bHistoryHeuristic   = bHistoryHeuristic && m_pfnSort;

		if(bHistoryHeuristic && m_pMoveGenerator)
			m_pnProvisionalScore  =  new INT[m_pMoveGenerator->m_uMaxMove];
		else if(bHistoryHeuristic && !m_pHistory)
			m_pHistory = new BOARD<BOARD<INT, WIDTH, HEIGHT>, WIDTH, HEIGHT>;
		else if(!bHistoryHeuristic)
		{
			delete m_pnProvisionalScore;
			delete m_pHistory;

			m_pHistory           = NULL;
			m_pnProvisionalScore = NULL;
		}	
	}

	inline virtual VOID SetSortType( VOID (*pfnSort)(SEARCHMOVE gOutput[], SEARCHMOVE gMove[], INT ngScore[], const UINT uSize) )
	{
		m_bHistoryHeuristic   = m_pnProvisionalScore && pfnSort;

		m_pfnSort             = pfnSort;
	}

	inline virtual VOID SetMoveGenerator(CMoveGenerator<TYPE, WIDTH, HEIGHT>* const pMoveGenerator)
	{
		if(m_pnProvisionalScore)
		{
			delete m_pnProvisionalScore;

			m_pnProvisionalScore = new INT[pMoveGenerator->m_uMaxMove];
		}

		if(m_pHistory && !m_pnProvisionalScore)
		{
			m_pnProvisionalScore = new INT[pMoveGenerator->m_uMaxMove];
			if(m_pfnSort)
				m_bHistoryHeuristic = TRUE;
		}

		m_pMoveGenerator     = pMoveGenerator;
	}
protected:
	VOID (*m_pfnSort)(SEARCHMOVE gOutput[], SEARCHMOVE gMove[], INT ngScore[], const UINT uSize);

	BOOL											  m_bHistoryHeuristic;

	PINT                                              m_pnProvisionalScore;
	BOARD<BOARD<INT, WIDTH, HEIGHT>, WIDTH, HEIGHT>*  m_pHistory;
};
