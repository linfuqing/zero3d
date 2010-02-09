#pragma once
//#include "failsoftalphabetaengine.h"
#include "HistoryHeuristicSearchEngine.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CAspirationSearchEngine :
	public CHistoryHeuristicSearchEngine<TYPE, WIDTH, HEIGHT>
{
public:

	CAspirationSearchEngine(INT nWindow = 50);
	~CAspirationSearchEngine(void);

	virtual VOID SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side = NEGATIVE_SIDE);
private:
	INT __AlphaBeta(UINT uDepth, INT nAlpha, INT nBeta);
private:
	INT m_nWindow;
};

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CAspirationSearchEngine<TYPE, WIDTH, HEIGHT>::CAspirationSearchEngine(INT nWindow) : m_nWindow(nWindow)
{
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CAspirationSearchEngine<TYPE, WIDTH, HEIGHT>::~CAspirationSearchEngine(void)
{
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
VOID CAspirationSearchEngine<TYPE, WIDTH, HEIGHT>::SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side)
{
	m_pMover->m_Board.SetBoard(&Board);

	m_Side = Side;

	if(m_pMover->m_pTranspositionTable)
		m_pMover->m_pTranspositionTable->Initialize(m_pMover->m_Board);

	if(m_bHistoryHeuristic)
		memset( m_pHistory, 0, sizeof(m_pHistory) );

	m_nMaxDepth = m_nSearchDepth - 1;

	INT x = __AlphaBeta(m_nMaxDepth, -m_pEveluation->m_nMAX_VALUE, m_pEveluation->m_nMAX_VALUE);

	m_nMaxDepth = m_nSearchDepth;

	INT y = __AlphaBeta(m_nMaxDepth, x - m_nWindow, x + m_nWindow);

	if(y > x + m_nWindow)
		__AlphaBeta(m_nMaxDepth, y, m_pEveluation->m_nMAX_VALUE);
	else if(y <= x - m_nWindow)
		__AlphaBeta(m_nMaxDepth, -m_pEveluation->m_nMAX_VALUE, y);

	m_BestType = m_pMover->MakeMove(m_pBestMove);

	if(m_pMover->m_bHash)
		m_pMover->m_pTranspositionTable->EnterHash();

	Board.SetBoard(&m_pMover->m_Board);
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
INT CAspirationSearchEngine<TYPE, WIDTH, HEIGHT>::__AlphaBeta(UINT uDepth, INT nAlpha, INT nBeta)
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

	if(m_pMover->m_bRepetitionDetection)
		m_pMover->m_pTranspositionTable->EnterHash(uDepth);

	pMove = NULL;

	TYPE     Type;

	TRANSPOSITIONTABLETYPE HashType = UPPER_BOUND;
	INT      nCurrent = -m_pEveluation->m_nMAX_VALUE;
	UINT     uCount   = m_pMoveGenerator->m_uMoveCount;
	for(i = 0; i < uCount; i++)
	{
		Type   = m_pMover->MakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i]);
		if( (m_pMover->m_bHash && uDepth == m_nMaxDepth && m_pMover->m_pTranspositionTable->LookUpHash() )
		|| ( m_pMover->m_bRepetitionDetection && m_pMover->m_pTranspositionTable->LookUpHash(uDepth - 1) ) )
		{
			m_pMover->UnMakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i], Type);
			continue;
		}
		nScore = -__AlphaBeta(uDepth - 1, -nBeta,  -nAlpha);
		m_pMover->UnMakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i], Type);

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