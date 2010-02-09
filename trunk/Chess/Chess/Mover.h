#pragma once

#include <vector>

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CMover
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
public:

	CMover(void) :
	m_pTranspositionTable(NULL),
	m_bTranspositionTable(FALSE),
	m_bHash(FALSE),
	m_bRepetitionDetection(FALSE),
	m_uCurrentMove(0)
	{
	}

	~CMover(void)
	{
	}

	inline virtual TYPE MakeMove(LPSEARCHMOVE const pMove, BOOL bIsRecorded = FALSE)
	{
		TYPE From = m_Board.gPosition[pMove->From.y][pMove->From.x],
			 To   = m_Board.gPosition[pMove->  To.y][pMove->  To.x],
			 None = TYPE(0);

		if(m_pTranspositionTable != NULL)
		{
			m_pTranspositionTable->m_dwHashKey32 = m_pTranspositionTable->m_dwHashKey32 ^ m_pTranspositionTable->m_pHashKey32[m_pTranspositionTable->m_puTypeSubscript[From]].gPosition[pMove->From.y][pMove->From.x];
			m_pTranspositionTable->m_uHashKey64  = m_pTranspositionTable->m_uHashKey64  ^ m_pTranspositionTable->m_pHashKey64[m_pTranspositionTable->m_puTypeSubscript[From]].gPosition[pMove->From.y][pMove->From.x];

			if(To != None)
			{
				m_pTranspositionTable->m_dwHashKey32 = m_pTranspositionTable->m_dwHashKey32 ^ m_pTranspositionTable->m_pHashKey32[m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->To.y][pMove->To.x];
				m_pTranspositionTable->m_uHashKey64  = m_pTranspositionTable->m_uHashKey64  ^ m_pTranspositionTable->m_pHashKey64[m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->To.y][pMove->To.x];
			}

			m_pTranspositionTable->m_dwHashKey32 = m_pTranspositionTable->m_dwHashKey32 ^ m_pTranspositionTable->m_pHashKey32[m_pTranspositionTable->m_puTypeSubscript[From]].gPosition[pMove->To.y][pMove->To.x];
			m_pTranspositionTable->m_uHashKey64  = m_pTranspositionTable->m_uHashKey64  ^ m_pTranspositionTable->m_pHashKey64[m_pTranspositionTable->m_puTypeSubscript[From]].gPosition[pMove->To.y][pMove->To.x];
		}

		m_Board.gPosition[pMove->To.y][pMove->To.x]     = From;
		m_Board.gPosition[pMove->From.y][pMove->From.x] = None;

		if(bIsRecorded)
		{
			m_Moves.push_back( MOVEITEM(To, pMove) );
			m_uCurrentMove++;
		}

		return To;
	}

	inline virtual VOID UnMakeMove(LPSEARCHMOVE const pMove, const TYPE Type)
	{
		TYPE To = m_Board.gPosition[pMove->To.y][pMove->To.x];

		if(m_pTranspositionTable != NULL)
		{
			m_pTranspositionTable->m_dwHashKey32 = m_pTranspositionTable->m_dwHashKey32 ^ m_pTranspositionTable->m_pHashKey32[m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->From.y][pMove->From.x];
			m_pTranspositionTable->m_uHashKey64  = m_pTranspositionTable->m_uHashKey64  ^ m_pTranspositionTable->m_pHashKey64[m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->From.y][pMove->From.x];

			m_pTranspositionTable->m_dwHashKey32 = m_pTranspositionTable->m_dwHashKey32 ^ m_pTranspositionTable->m_pHashKey32[m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->To.y][pMove->To.x];
			m_pTranspositionTable->m_uHashKey64  = m_pTranspositionTable->m_uHashKey64  ^ m_pTranspositionTable->m_pHashKey64[m_pTranspositionTable->m_puTypeSubscript[To]].gPosition[pMove->To.y][pMove->To.x];

			if( Type != TYPE(0) )
			{
				m_pTranspositionTable->m_dwHashKey32 = m_pTranspositionTable->m_dwHashKey32 ^ m_pTranspositionTable->m_pHashKey32[m_pTranspositionTable->m_puTypeSubscript[Type]].gPosition[pMove->To.y][pMove->To.x];
				m_pTranspositionTable->m_uHashKey64  = m_pTranspositionTable-> m_uHashKey64 ^ m_pTranspositionTable->m_pHashKey64[m_pTranspositionTable->m_puTypeSubscript[Type]].gPosition[pMove->To.y][pMove->To.x];
			}
		}

		m_Board.gPosition[pMove->From.y][pMove->From.x] = To;
		m_Board.gPosition[pMove->To.y  ][pMove->To.x  ] = Type;
	}
	inline BOOL GotoMakeMove(const UINT uIndex, const BOOL bIsClear)
	{
		UINT uSize = m_Moves.size();

		if(uSize <= uIndex)
			return FALSE;

		UINT i;

		if(uIndex < m_uCurrentMove)
			for(i = m_uCurrentMove; i > uIndex; i--)
				UnMakeMove(&m_Moves[i].Move, m_Moves[i].To);
		else
			for(i = m_uCurrentMove; i < uIndex; i++)
				MakeMove(&m_Moves[i].Move);
		
		if(bIsClear)
			for(; i < uSize; i++)
				m_Moves.pop_back();

		m_uCurrentMove = uIndex;

		return TRUE;
	}

	inline VOID SetTranspositionTable(CZobristHash<TYPE, WIDTH, HEIGHT>* const pTranspositionTable)
	{
		delete m_pTranspositionTable;

		m_pTranspositionTable  = pTranspositionTable;

		m_bTranspositionTable  = pTranspositionTable->m_ppTranspositionTable != NULL;
		m_bHash                = pTranspositionTable->m_pHash                != NULL;
		m_bRepetitionDetection = pTranspositionTable->m_pRepetitionDetection != NULL;
	}
	inline UINT GetCurrentMoveIndex()const
	{
		return m_uCurrentMove;
	}
	inline UINT GetMoveLength()const
	{
		return m_Moves.size();
	}
private:
	typedef struct MOVEITEM
	{
		TYPE       To;
		SEARCHMOVE Move;
		MOVEITEM(TYPE To, LPSEARCHMOVE pMove) :
		To(To)
		{
			Move = *pMove;
		}
	}MOVEITEM;
	BOARD<TYPE, WIDTH, HEIGHT> m_Board;

	std::vector<MOVEITEM> m_Moves;
	UINT m_uCurrentMove;
	
	CZobristHash<TYPE, WIDTH, HEIGHT>* m_pTranspositionTable;
	BOOL m_bTranspositionTable;
	BOOL m_bHash;
	BOOL m_bRepetitionDetection;
};
