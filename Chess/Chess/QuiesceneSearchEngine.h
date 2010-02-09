#pragma once
#include "historyheuristicsearchengine.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CQuiesceneSearchEngine :
	public CHistoryHeuristicSearchEngine<TYPE, WIDTH, HEIGHT>
{
public:

	CQuiesceneSearchEngine(void)
	{
	}

	~CQuiesceneSearchEngine(void)
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

		m_nMaxDepth = m_nSearchDepth;

		__QuiesceneSearch(0, -m_pEveluation->m_nMAX_VALUE, m_pEveluation->m_nMAX_VALUE);

		m_BestType = m_pMover->MakeMove(m_pBestMove);

		Board.SetBoard(&m_pMover->m_Board);
	}

private:
	INT __QuiesceneSearch(UINT uDepth, INT nAlpha, INT nBeta)
	{
		BOOL    bIsCurrentSide = uDepth % 2;
		INT				nScore = m_pEveluation->IsGameOver(m_pMover->m_Board, uDepth, m_Side, bIsCurrentSide);
		if(nScore)
			return nScore;

		if( m_pMover->m_bTranspositionTable && m_pMover->m_pTranspositionTable->LookUpHash(nScore, nAlpha, nBeta, uDepth, bIsCurrentSide) )
			return nScore;

		SEARCHSIDE CurrentSide = bIsCurrentSide ? SEARCHSIDE(!m_Side) : m_Side;

		nScore = m_pEveluation->Eveluate(m_pMover->m_Board, CurrentSide);

		if( uDepth == m_pMoveGenerator->m_uMaxPly || (m_nMaxDepth <= uDepth && nScore > nBeta) )
		{
			if(m_pMover->m_bTranspositionTable)
				m_pMover->m_pTranspositionTable->EnterHash(EXACT, nScore, uDepth, bIsCurrentSide);

			return nScore;
		}

		UINT i;
		LPSEARCHMOVE pMove;

		m_pMoveGenerator->m_nPly       = uDepth;
		m_pMoveGenerator->m_uMoveCount = 0;
		m_pMoveGenerator->CreatePossibleMove(m_pMover->m_Board, CurrentSide);

		if(m_bHistoryHeuristic)
		{
			for(i = 0; i < m_pMoveGenerator->m_uMoveCount; i++)
			{
				pMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];
				m_pnProvisionalScore[i] = m_pHistory->gPosition[pMove->From.y][pMove->From.x].gPosition[pMove->To.y][pMove->To.x];
			}

			(*m_pfnSort)(m_pMoveGenerator->m_ppMoveList[uDepth], m_pMoveGenerator->m_ppMoveList[uDepth], m_pnProvisionalScore, m_pMoveGenerator->m_uMoveCount);
		}

		pMove = NULL;

		TYPE     Type;

		TRANSPOSITIONTABLETYPE HashType = UPPER_BOUND;
		UINT     uCount   = m_pMoveGenerator->m_uMoveCount;
		for(i = 0; i < uCount; i++)
		{
			Type   = m_pMover->MakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i]);
			nScore = -__QuiesceneSearch(uDepth + 1, -nBeta,  -nAlpha);
			m_pMover->UnMakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i], Type);

			if(nScore > nAlpha)
			{
				nAlpha   = nScore;
				HashType = EXACT;
				if(uDepth == 0)
					m_pBestMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];

				pMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];

				if(nAlpha >= nBeta)
				{
					HashType = LOWER_BOUND;
					break;
				}
			}
		}

		if(m_pMover->m_bTranspositionTable)
			m_pMover->m_pTranspositionTable->EnterHash(HashType, nScore, uDepth, bIsCurrentSide);

		if(m_bHistoryHeuristic && pMove)
			m_pHistory->gPosition[pMove->From.y][pMove->From.x].gPosition[pMove->To.y][pMove->To.x] += 2 << uDepth;

		return nScore;
	}
};
