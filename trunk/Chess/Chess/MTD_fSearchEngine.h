#pragma once
#include "alphabetaengine.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CMTD_fSearchEngine :
	public CAlphaBetaEngine<TYPE, WIDTH, HEIGHT>
{
public:

	CMTD_fSearchEngine(void)
	{
	}

	~CMTD_fSearchEngine(void)
	{
	}

	virtual VOID SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side = NEGATIVE_SIDE)
	{
		m_pMover->m_Board.SetBoard(&Board);

		m_Side = Side;

		if(m_pMover->m_pTranspositionTable)
			m_pMover->m_pTranspositionTable->Initialize(m_pMover->m_Board);

		if(m_bHistoryHeuristic)
			memset( m_pHistory, 0, sizeof(m_pHistory) );

		INT nGuess = m_nMaxDepth % 2 ? -m_pEveluation->m_nMAX_VALUE : m_pEveluation->m_nMAX_VALUE;
		if(m_bIterativeDeepening)
		{
			m_uDepth = m_uCount = 0;
			for(m_nMaxDepth = 1; m_nMaxDepth <= m_nSearchDepth; m_nMaxDepth++)
			{
				nGuess = MTD_f(nGuess, m_nMaxDepth);
			}
		}
		else
		{
			m_nMaxDepth = m_nSearchDepth;

			MTD_f(nGuess, m_nMaxDepth);
		}

		m_BestType = m_pMover->MakeMove(m_pBestMove);

		Board.SetBoard(&m_pMover->m_Board);
	}

private:
	INT MTD_f(INT nGuess, UINT uDepth)
	{
		INT nUpperBound =  m_pEveluation->m_nMAX_VALUE,
			nLowerBound = -m_pEveluation->m_nMAX_VALUE,
			nBeta;

		while(nLowerBound < nUpperBound)
		{
			nBeta = nGuess == nLowerBound ? nGuess + 1 : nGuess;

			nGuess = _AlphaBeta(uDepth, nBeta - 1, nBeta);

			if(nGuess < nBeta)
				nUpperBound = nGuess;
			else
				nLowerBound = nGuess;
		}

		return nGuess;
	}
};
