#pragma once

#include "MoveGenerator.h"
#include "Eveluation.h"
#include "ZobristHash.h"
#include "Mover.h"

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CSearchEngine
{
public:
	CSearchEngine(void) :
	m_pEveluation(NULL),
	m_pMoveGenerator(NULL),
	m_pMover(NULL)
	/*m_pMover->m_pTranspositionTable(NULL),
	m_pMover->m_bTranspositionTable(FALSE),
	m_pMover->m_bHash(FALSE),
	m_pMover->m_bRepetitionDetection(FALSE)*/
	{
	}
	virtual ~CSearchEngine(void)
	{
		delete m_pEveluation;
		delete m_pMoveGenerator;

		//delete m_pMover->m_pTranspositionTable;

		//delete m_pMover;
	}
	virtual void SearchNextMove(BOARD<TYPE, WIDTH, HEIGHT>& Board, const SEARCHSIDE Side = NEGATIVE_SIDE) = 0;
public:
	inline VOID SetSearchDepth(const UINT uDepth)
	{
		m_nSearchDepth = uDepth;
	}
	inline VOID SetEveluator(CEveluation<TYPE, WIDTH, HEIGHT>* const pEveluation)
	{
		m_pEveluation = pEveluation;
	}
	inline VOID SetMover(CMover<TYPE, WIDTH, HEIGHT>* const pMover)
	{
		m_pMover = pMover;
	}
	inline virtual VOID SetMoveGenerator(CMoveGenerator<TYPE, WIDTH, HEIGHT>* const pMoveGenerator)
	{
		m_pMoveGenerator = pMoveGenerator;
	}
	/*inline VOID SetTranspositionTable(CZobristHash<TYPE, WIDTH, HEIGHT>* const pTranspositionTable)
	{
		delete m_pMover->m_pTranspositionTable;

		m_pMover->m_pTranspositionTable  = pTranspositionTable;

		m_pMover->m_bTranspositionTable  = pTranspositionTable->m_ppTranspositionTable != NULL;
		m_pMover->m_bHash                = pTranspositionTable->m_pHash                != NULL;
		m_pMover->m_bRepetitionDetection = pTranspositionTable->m_pRepetitionDetection != NULL;
	}*/
	inline TYPE GetBestMove(SEARCHMOVE& Move)
	{
		Move = *m_pBestMove;
		return m_BestType;
	}
	inline VOID Stop()
	{
		m_bStop = TRUE;
	}
/*protected:
	inline TYPE m_pMover->MakeMove(LPSEARCHMOVE const pMove)
	{
		TYPE From = m_Board.gPosition[pMove->From.y][pMove->From.x],
			 To   = m_Board.gPosition[pMove->  To.y][pMove->  To.x],
			 None = TYPE(0);

		if(m_pMover->m_pTranspositionTable != NULL)
		{
			m_pMover->m_pTranspositionTable->m_dwHashKey32 = m_pMover->m_pTranspositionTable->m_dwHashKey32 ^ m_pMover->m_pTranspositionTable->m_pHashKey32[m_pMover->m_pTranspositionTable->m_puTypeSubscript[From]].gPosition[pMove->From.y][pMove->From.x];
			m_pMover->m_pTranspositionTable->m_uHashKey64  = m_pMover->m_pTranspositionTable->m_uHashKey64  ^ m_pMover->m_pTranspositionTable->m_pHashKey64[m_pMover->m_pTranspositionTable->m_puTypeSubscript[From]].gPosition[pMove->From.y][pMove->From.x];

			if(To != None)
			{
				m_pMover->m_pTranspositionTable->m_dwHashKey32 = m_pMover->m_pTranspositionTable->m_dwHashKey32 ^ m_pMover->m_pTranspositionTable->m_pHashKey32[m_pMover->m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->To.y][pMove->To.x];
				m_pMover->m_pTranspositionTable->m_uHashKey64  = m_pMover->m_pTranspositionTable->m_uHashKey64  ^ m_pMover->m_pTranspositionTable->m_pHashKey64[m_pMover->m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->To.y][pMove->To.x];
			}

			m_pMover->m_pTranspositionTable->m_dwHashKey32 = m_pMover->m_pTranspositionTable->m_dwHashKey32 ^ m_pMover->m_pTranspositionTable->m_pHashKey32[m_pMover->m_pTranspositionTable->m_puTypeSubscript[From]].gPosition[pMove->To.y][pMove->To.x];
			m_pMover->m_pTranspositionTable->m_uHashKey64  = m_pMover->m_pTranspositionTable->m_uHashKey64  ^ m_pMover->m_pTranspositionTable->m_pHashKey64[m_pMover->m_pTranspositionTable->m_puTypeSubscript[From]].gPosition[pMove->To.y][pMove->To.x];
		}

		m_Board.gPosition[pMove->To.y][pMove->To.x]     = From;
		m_Board.gPosition[pMove->From.y][pMove->From.x] = None;

		return To;
	}
	inline VOID m_pMover->UnMakeMove(LPSEARCHMOVE const pMove, const TYPE Type)
	{
		TYPE To = m_Board.gPosition[pMove->To.y][pMove->To.x];

		if(m_pMover->m_pTranspositionTable != NULL)
		{
			m_pMover->m_pTranspositionTable->m_dwHashKey32 = m_pMover->m_pTranspositionTable->m_dwHashKey32 ^ m_pMover->m_pTranspositionTable->m_pHashKey32[m_pMover->m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->From.y][pMove->From.x];
			m_pMover->m_pTranspositionTable->m_uHashKey64  = m_pMover->m_pTranspositionTable->m_uHashKey64  ^ m_pMover->m_pTranspositionTable->m_pHashKey64[m_pMover->m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->From.y][pMove->From.x];

			m_pMover->m_pTranspositionTable->m_dwHashKey32 = m_pMover->m_pTranspositionTable->m_dwHashKey32 ^ m_pMover->m_pTranspositionTable->m_pHashKey32[m_pMover->m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->To.y][pMove->To.x];
			m_pMover->m_pTranspositionTable->m_uHashKey64  = m_pMover->m_pTranspositionTable->m_uHashKey64  ^ m_pMover->m_pTranspositionTable->m_pHashKey64[m_pMover->m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->To.y][pMove->To.x];

			if( Type != TYPE(0) )
			{
				m_pMover->m_pTranspositionTable->m_dwHashKey32 = m_pMover->m_pTranspositionTable->m_dwHashKey32 ^ m_pMover->m_pTranspositionTable->m_pHashKey32[m_pMover->m_pTranspositionTable->m_puTypeSubscript[Type]].gPosition[pMove->To.y][pMove->To.x];
				m_pMover->m_pTranspositionTable->m_uHashKey64  = m_pMover->m_pTranspositionTable-> m_uHashKey64 ^ m_pMover->m_pTranspositionTable->m_pHashKey64[m_pMover->m_pTranspositionTable->m_puTypeSubscript[Type]].gPosition[pMove->To.y][pMove->To.x];
			}
		}

		m_Board.gPosition[pMove->From.y][pMove->From.x] = To;
		m_Board.gPosition[pMove->To.y  ][pMove->To.x  ] = Type;
	}*/

protected:
	//BOARD<TYPE, WIDTH, HEIGHT> m_Board;

	LPSEARCHMOVE m_pBestMove;

	TYPE         m_BestType;

	CEveluation<TYPE, WIDTH, HEIGHT>* m_pEveluation;
	CMoveGenerator<TYPE, WIDTH, HEIGHT>* m_pMoveGenerator;

	UINT m_nSearchDepth;
	UINT m_nMaxDepth;

	UINT m_uTimes;

	BOOL m_bStop;

	SEARCHSIDE m_Side;

	CMover<TYPE, WIDTH, HEIGHT>* m_pMover;

	/*CZobristHash<TYPE, WIDTH, HEIGHT>* m_pMover->m_pTranspositionTable;
	BOOL m_pMover->m_bTranspositionTable;
	BOOL m_pMover->m_bHash;
	BOOL m_pMover->m_bRepetitionDetection;*/
/*private:
	typedef struct
	{
		LPSEARCHMOVE* ppMoveList;
		PUINT puMoveCount;
		PUINT puPly;

		PUINT puMaxPly;
		PUINT puMaxMove;
	}MOVEGENERATOR;*/
};