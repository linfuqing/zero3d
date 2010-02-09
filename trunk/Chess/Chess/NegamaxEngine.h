#pragma once
#include "searchengine.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CNegamaxEngine :
	public CSearchEngine<TYPE, WIDTH, HEIGHT>
{
public:
	CNegamaxEngine(void);
	~CNegamaxEngine(void);

	virtual void SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side = NEGATIVE_SIDE);
private:
	INT __Negamax(const UINT uDepth);
};

///-----------------------------------------------------------------------------------------------------------
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CNegamaxEngine<TYPE, WIDTH, HEIGHT>::CNegamaxEngine(void)
{
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CNegamaxEngine<TYPE, WIDTH, HEIGHT>::~CNegamaxEngine(void)
{
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
void CNegamaxEngine<TYPE, WIDTH, HEIGHT>::SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side)
{
	m_nMaxDepth = m_nSearchDepth;

	m_pMover->m_Board.SetBoard(&Board);

	m_Side = Side;

	__Negamax(m_nMaxDepth);

	m_BestType = m_pMover->MakeMove(m_pBestMove);

	Board.SetBoard(&m_pMover->m_Board);
}

///超级无敌博大负极大值算法
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
INT CNegamaxEngine<TYPE, WIDTH, HEIGHT>::__Negamax(const UINT uDepth)
{
	BOOL    bIsCurrentSide = (m_nMaxDepth - uDepth) % 2;
	INT             nScore = m_pEveluation->IsGameOver(m_pMover->m_Board, uDepth, m_Side, bIsCurrentSide);
	if(nScore)
		return nScore;

	SEARCHSIDE CurrentSide = bIsCurrentSide ? SEARCHSIDE(!m_Side) : m_Side;
	if(uDepth <= 0)
		return m_pEveluation->Eveluate(m_pMover->m_Board, CurrentSide);

	TYPE Type;

	m_pMoveGenerator->m_uMoveCount = 0;
	m_pMoveGenerator->m_nPly       = uDepth;
	m_pMoveGenerator->CreatePossibleMove(m_pMover->m_Board, CurrentSide);

	INT  nCurrent = -m_pEveluation->m_nMAX_VALUE;
	UINT uCount = m_pMoveGenerator->m_uMoveCount;
	for(UINT i = 0; i < uCount; i++)
	{
		Type   = m_pMover->MakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i]);
		nScore = -__Negamax(uDepth - 1);
		m_pMover->UnMakeMove(&m_pMoveGenerator->m_ppMoveList[uDepth][i], Type);

		if(nScore > nCurrent)
		{
			nCurrent = nScore;
			if(uDepth == m_nMaxDepth)
				m_pBestMove = &m_pMoveGenerator->m_ppMoveList[uDepth][i];
		}
	}

	return nCurrent;
}