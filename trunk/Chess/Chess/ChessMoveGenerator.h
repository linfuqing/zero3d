#pragma once
//#include "movegenerator.h"
#include "ChessRules.h"

#define MAX_PLY   8
#define MAX_MOVE  80

class CChessMoveGenerator :
	public CMoveGenerator CHESS, public CChessRules
{
public:
	CChessMoveGenerator(void);
	~CChessMoveGenerator(void);

	virtual VOID CreatePossibleMove(BOARD CHESS& ChessBoard, CHESSSIDE Side);
protected:
	inline virtual VOID AddMove(const INT nFromX, const INT nFromY, const INT nToX, const INT nToY);
};

inline VOID CChessMoveGenerator::AddMove(const INT nFromX, const INT nFromY, const INT nToX, const INT nToY)
{
	//CMoveGenerator<CHESSMANTYPE, CHESS_WIDTH, CHESS_HEIGHT>::AddMove(nFromX, nFromY, nToX, nToY);
	LPCHESSMOVE pMove = &m_ppMoveList[m_nPly][m_uMoveCount];

	pMove->From.x = nFromX;
	pMove->From.y = nFromY;
	pMove->  To.x =   nToX;
	pMove->  To.y =   nToY;

	m_uMoveCount++;
}