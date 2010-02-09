#pragma once

//#include "ChessRules.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CNegamaxEngine;
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CAlphaBetaEngine;
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CFailSoftAlphaBetaEngine;
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CAspirationSearchEngine;
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CPrincipalVariationSearchEngine;
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CHistoryHeuristicSearchEngine;
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CIterativeDeepeningSearchEngine;
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CMTD_fSearchEngine;
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CQuiesceneSearchEngine;

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CMoveGenerator// :
//	public CChessRules
{
	friend class CNegamaxEngine<TYPE, WIDTH, HEIGHT>;
	friend class CAlphaBetaEngine<TYPE, WIDTH, HEIGHT>;
	friend class CFailSoftAlphaBetaEngine<TYPE, WIDTH, HEIGHT>;
	friend class CAspirationSearchEngine<TYPE, WIDTH, HEIGHT>;
	friend class CPrincipalVariationSearchEngine<TYPE, WIDTH, HEIGHT>;
	friend class CHistoryHeuristicSearchEngine<TYPE, WIDTH, HEIGHT>;
	friend class CIterativeDeepeningSearchEngine<TYPE, WIDTH, HEIGHT>;
	friend class CMTD_fSearchEngine<TYPE, WIDTH, HEIGHT>;
	friend class CQuiesceneSearchEngine<TYPE, WIDTH, HEIGHT>;
	//friend class CAlphaBetaEngine;
public:
	CMoveGenerator(UINT uMaxMove, UINT uMaxPly);
	~CMoveGenerator(void);

	//static BOOL IsValueMove(BASECHESSBOARD& Board, INT nFromX, INT nFromY, INT nToX, INT nToY);

	virtual VOID CreatePossibleMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, SEARCHSIDE Side) = 0;
protected:
	LPSEARCHMOVE* m_ppMoveList;
	//INT AddMove(INT nFromX, INT nFromY, INT nToX, INT nToY, INT nPly);
	inline virtual VOID AddMove(const INT nFromX, const INT nFromY, const INT nToX, const INT nToY);


	//void GenerateMove(BASECHESSBOARD& Board, INT x, INT y, INT nPly);
protected:
	UINT m_uMoveCount;
	UINT m_nPly;

	UINT m_uMaxPly;
	UINT m_uMaxMove;
};

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
inline VOID CMoveGenerator<TYPE, WIDTH, HEIGHT>::AddMove(const INT nFromX, const INT nFromY, const INT nToX, const INT nToY)
{
	//LPSEARCHMOVE pMove = &m_ppMoveList[nPly][m_uMoveCount];
	LPSEARCHMOVE pMove = &m_ppMoveList[m_nPly][m_uMoveCount];

	pMove->From.x = nFromX;
	pMove->From.y = nFromY;
	pMove->  To.x =   nToX;
	pMove->  To.y =   nToY;

	m_uMoveCount++;
}

///-------------------------------------------------------------------------------------------------------------------------
template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CMoveGenerator<TYPE, WIDTH, HEIGHT>::CMoveGenerator(UINT uMaxMove, UINT uMaxPly) : 
m_uMaxMove(uMaxMove),
m_uMaxPly(uMaxPly)
{
	m_ppMoveList = new LPSEARCHMOVE[uMaxPly];

	for(UINT i = 0; i < uMaxPly; i++)
		m_ppMoveList[i] = new SEARCHMOVE[uMaxMove];
}

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
CMoveGenerator<TYPE, WIDTH, HEIGHT>::~CMoveGenerator(void)
{
	for(UINT i = 0; i < m_uMaxPly; i++)
		delete[] m_ppMoveList[i];
}

/*template<typename TYPE, UINT WIDTH, UINT HEIGHT>
INT CMoveGenerator<TYPE, WIDTH, HEIGHT>::CreatePossibleMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, INT nPly, SEARCHSIDE Side)
{
	m_uMoveCount = 0;
	m_nPly       = nPly;

	for(INT i = 0; i < CHESS_WIDTH; i ++)
		for(INT j = 0; j < CHESS_HEIGHT; j++)
			if( IsSide(Side, Board.gPosition[j][i]) )
				//GenerateMove(Board, i, j, nPly);
				CChessRules::GetMoves(Board, i, j, TRUE);

	return m_uMoveCount;
}*/