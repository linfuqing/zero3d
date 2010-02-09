#pragma once
//#include "searchengine.h"
#include "IterativeDeepeningSearchEngine.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CPrincipalVariationSearchEngine :
	public CIterativeDeepeningSearchEngine<TYPE, WIDTH, HEIGHT>
{
public:
	CPrincipalVariationSearchEngine(void);
	~CPrincipalVariationSearchEngine(void);

	virtual VOID SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side = NEGATIVE_SIDE);
private:
	INT __PrincipalVariation(INT uDepth, INT nAlpha, INT nBeta);
};

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CPrincipalVariationSearchEngine<TYPE, WIDTH, HEIGHT>::CPrincipalVariationSearchEngine(void)
{
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CPrincipalVariationSearchEngine<TYPE, WIDTH, HEIGHT>::~CPrincipalVariationSearchEngine(void)
{
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
VOID CPrincipalVariationSearchEngine<TYPE, WIDTH, HEIGHT>::SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side)
{
	/*m_nMaxDepth = m_nSearchDepth;

	m_pMover->m_Board.SetBoard(&Board);

	m_Side = Side;

	__PrincipalVariation(m_nMaxDepth, -m_pEveluation->m_nMAX_VALUE, m_pEveluation->m_nMAX_VALUE);

	m_pMover->MakeMove(m_pBestMove);

	Board.SetBoard(&m_pMover->m_Board);*/

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
			__PrincipalVariation(m_nMaxDepth, -m_pEveluation->m_nMAX_VALUE, m_pEveluation->m_nMAX_VALUE);
			//(*m_pfnSort)(m_pMoveGenerator->m_ppMoveList[m_uDepth], m_pScore, m_uCount);
		}
	}
	else
	{
		m_nMaxDepth = m_nSearchDepth;

		__PrincipalVariation(m_nMaxDepth, -m_pEveluation->m_nMAX_VALUE, m_pEveluation->m_nMAX_VALUE);
	}

	m_BestType = m_pMover->MakeMove(m_pBestMove);

	Board.SetBoard(&m_pMover->m_Board);
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
INT CPrincipalVariationSearchEngine<TYPE, WIDTH, HEIGHT>::__PrincipalVariation(INT uDepth, INT nAlpha, INT nBeta)
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

	pMove = NULL;
	INT nCount = m_pMoveGenerator->m_uMoveCount;
	TRANSPOSITIONTABLETYPE HashType = LOWER_BOUND;

	TYPE Type  = m_pMover->MakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][0]);
	INT  nBest = -__PrincipalVariation(uDepth - 1, -nBeta, -nAlpha);
	m_pMover->UnMakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][0], Type);
	if(uDepth == m_nMaxDepth)
		m_pBestMove = &m_pMoveGenerator->m_ppMoveList[uDepth][0];

	pMove = &m_pMoveGenerator->m_ppMoveList[uDepth][0];

	if(m_bIterativeDeepening && uDepth == m_nMaxDepth)
			m_pnTopScore[0] = nBest;

	for(INT i = 1; i < nCount; i++)
	{
		if(nBest < nBeta)
		{
			if(nBest > nAlpha)
				nAlpha = nBest;

			Type   = m_pMover->MakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i]);
			nScore = -__PrincipalVariation(uDepth - 1, -nAlpha - 1, -nAlpha);

			if(nScore > nAlpha && nScore < nBeta)
			{
				HashType = EXACT;
				pMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];
				nBest = -__PrincipalVariation(uDepth - 1, -nBeta, -nScore);
				if(uDepth == m_nMaxDepth)
					m_pBestMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];

				pMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];
			}
			else if(nScore > nBest)
			{
				HashType = UPPER_BOUND;
				nBest = nScore;
				if(uDepth == m_nMaxDepth)
					m_pBestMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];

				pMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];
			}
			m_pMover->UnMakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i], Type);

			if(m_bIterativeDeepening && uDepth == m_nMaxDepth)
				m_pnTopScore[i] = nScore;
		}
	}

	if(m_pMover->m_bTranspositionTable)
		m_pMover->m_pTranspositionTable->EnterHash(HashType, nBest, uDepth, bIsCurrentSide);

	if(m_bHistoryHeuristic && pMove)
		m_pHistory->gPosition[pMove->From.y][pMove->From.x].gPosition[pMove->To.y][pMove->To.x] += 2 << uDepth;

	return nBest;
}