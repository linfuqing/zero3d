#pragma once
#include "IterativeDeepeningSearchEngine.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CAlphaBetaEngine :
	public CIterativeDeepeningSearchEngine<TYPE, WIDTH, HEIGHT>
{
public:
	CAlphaBetaEngine(void);
	~CAlphaBetaEngine(void);

	virtual VOID SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side = NEGATIVE_SIDE);
protected:
	INT _AlphaBeta(UINT uDepth, INT nAlpha, INT nBeta);
};

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CAlphaBetaEngine<TYPE, WIDTH, HEIGHT>::CAlphaBetaEngine(void)
{
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CAlphaBetaEngine<TYPE, WIDTH, HEIGHT>::~CAlphaBetaEngine(void)
{
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
VOID CAlphaBetaEngine<TYPE, WIDTH, HEIGHT>::SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side)
{
	m_pMover->m_Board.SetBoard(&Board);

	m_Side = Side;

	if(m_pMover->m_pTranspositionTable)
		m_pMover->m_pTranspositionTable->Initialize(m_pMover->m_Board);

	if(m_bHistoryHeuristic)
		memset( m_pHistory, 0, sizeof(m_pHistory) );

	if(m_bIterativeDeepening)
	{
		m_uDepth = m_uCount = 0;
		for(m_nMaxDepth = 1; m_nMaxDepth <= m_nSearchDepth; m_nMaxDepth++)
		{
			_AlphaBeta(m_nMaxDepth, -m_pEveluation->m_nMAX_VALUE, m_pEveluation->m_nMAX_VALUE);
			//(*m_pfnSort)(m_pMoveGenerator->m_ppMoveList[m_uDepth], m_pScore, m_uCount);
		}
	}
	else
	{
		m_nMaxDepth = m_nSearchDepth;

		_AlphaBeta(m_nMaxDepth, -m_pEveluation->m_nMAX_VALUE, m_pEveluation->m_nMAX_VALUE);
	}

	m_BestType = m_pMover->MakeMove(m_pBestMove);

	if(m_pMover->m_bHash)
		m_pMover->m_pTranspositionTable->EnterHash();

	Board.SetBoard(&m_pMover->m_Board);
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
INT CAlphaBetaEngine<TYPE, WIDTH, HEIGHT>::_AlphaBeta(UINT uDepth, INT nAlpha, INT nBeta)
{
	BOOL    bIsCurrentSide = (m_nMaxDepth - uDepth) % 2;
	INT             nScore = m_pEveluation->IsGameOver(m_pMover->m_Board, uDepth, m_Side, bIsCurrentSide);
	if(nScore)
		return nScore;

	if( m_pMover->m_bTranspositionTable && m_pMover->m_pTranspositionTable->LookUpHash(nScore, nAlpha, nBeta, uDepth, bIsCurrentSide) )
		return nScore;

	SEARCHSIDE CurrentSide = bIsCurrentSide ? SEARCHSIDE(!m_Side) : m_Side;
	if(uDepth <= 0)
	{
		nScore = m_pEveluation->Eveluate(m_pMover->m_Board, CurrentSide);

		if(m_pMover->m_bTranspositionTable)
			m_pMover->m_pTranspositionTable->EnterHash(EXACT, nScore, uDepth, bIsCurrentSide);

		return nScore;
	}

	UINT i;
	LPSEARCHMOVE pMove;

	if(m_bIterativeDeepening && uDepth == m_nMaxDepth && m_nMaxDepth > 1 && m_uDepth)
	{
		m_pMoveGenerator->m_uMoveCount = m_uCount;

		(*m_pfnSort)(m_pMoveGenerator->m_ppMoveList[m_nMaxDepth], m_pMoveGenerator->m_ppMoveList[m_uDepth], m_pnTopScore, m_uCount);

		//for(i = 0; i < m_uCount; i++)
		//	m_pMoveGenerator->m_ppMoveList[m_nMaxDepth][i] = m_pMoveGenerator->m_ppMoveList[m_uDepth][i];

		m_uDepth = m_nMaxDepth;
	}
	else
	{
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
		if(m_bIterativeDeepening && uDepth == m_nMaxDepth)
		{
			m_uDepth = m_nMaxDepth;

			m_uCount = m_pMoveGenerator->m_uMoveCount;
		}
	}

	if(m_pMover->m_bRepetitionDetection)
		m_pMover->m_pTranspositionTable->EnterHash(uDepth);

	pMove = NULL;

	TYPE     Type;

	TRANSPOSITIONTABLETYPE HashType = UPPER_BOUND;
	INT      nCurrent = -m_pEveluation->m_nMAX_VALUE;
	UINT     //nKiller  = 0, 
		     uCount   = m_pMoveGenerator->m_uMoveCount;
	for(i = 0; i < uCount; i++)
	{
		Type   = m_pMover->MakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i]);

		if( (m_pMover->m_bHash && uDepth == m_nMaxDepth && m_pMover->m_pTranspositionTable->LookUpHash() )
		|| ( m_pMover->m_bRepetitionDetection && m_pMover->m_pTranspositionTable->LookUpHash(uDepth - 1) ) )
		{
			m_pMover->UnMakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i], Type);
			continue;
		}

		nScore = -_AlphaBeta(uDepth - 1, -nBeta,  -nAlpha);

		m_pMover->UnMakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i], Type);

		if(m_bIterativeDeepening && uDepth == m_nMaxDepth)
			m_pnTopScore[i] = nScore;

		if(nScore > nCurrent)
		{
			nCurrent = nScore;
			if(nScore > nAlpha)
			{
				nAlpha   = nScore;
				HashType = EXACT;
				if(uDepth == m_nMaxDepth)
					m_pBestMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];

				pMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];

				if(nAlpha >= nBeta)
				{
					//nKiller  = uCount - i;
					HashType = LOWER_BOUND;
					break;
				}
			}
		}
	}

	if(m_pMover->m_bTranspositionTable)
		m_pMover->m_pTranspositionTable->EnterHash(HashType, nCurrent, uDepth, bIsCurrentSide);

	if(m_bHistoryHeuristic && pMove)
		m_pHistory->gPosition[pMove->From.y][pMove->From.x].gPosition[pMove->To.y][pMove->To.x] += 2 << uDepth;

	return nCurrent;
}