#pragma once

typedef DWORD HASHTYPE;

#define HASHTYPE_NONE                (HASHTYPE)0x00
#define HASHTYPE_NORAML              (HASHTYPE)0x01
#define HASHTYPE_TRANSPOSITIONTABLE  (HASHTYPE)0x02
#define HASHTYPE_REPETITIONDETECTION (HASHTYPE)0x04

typedef enum
{
	EXACT,
	LOWER_BOUND,
	UPPER_BOUND
}TRANSPOSITIONTABLETYPE;

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CMover;

template<typename TYPE, UINT WIDTH, UINT HEIGHT>
class CZobristHash
{
	friend class CMover<TYPE, WIDTH, HEIGHT>;
public:

	CZobristHash(UINT uNumType, UINT ugTypeSubscript[], DWORD dwSize, HASHTYPE Type = HASHTYPE_NORAML | HASHTYPE_TRANSPOSITIONTABLE | HASHTYPE_REPETITIONDETECTION)
	{
		m_puTypeSubscript = ugTypeSubscript;

		m_dwSize     = dwSize;
		m_uType      = uNumType;

		m_pHashKey32 = new BOARD<DWORD    , WIDTH, HEIGHT>[uNumType];
		m_pHashKey64 = new BOARD<ULONGLONG, WIDTH, HEIGHT>[uNumType];

		m_pHash = (Type & HASHTYPE_NORAML) ? new HASHITEM[dwSize] : NULL;

		if(Type & HASHTYPE_TRANSPOSITIONTABLE)
		{
			m_ppTranspositionTable     = new LPTRANSPOSITIONTABLEITEM[2];
			m_ppTranspositionTable[0]  = new TRANSPOSITIONTABLEITEM[dwSize];
			m_ppTranspositionTable[1]  = new TRANSPOSITIONTABLEITEM[dwSize];
		}
		else
			m_ppTranspositionTable = NULL;

		m_pRepetitionDetection = (Type & HASHTYPE_REPETITIONDETECTION) ? new REPETITIONDETECTIONITEM[dwSize] : NULL;

		for(UINT i = 0; i < WIDTH; i++)
		{
			for(UINT j = 0; j < HEIGHT; j++)
			{
				for(UINT k = 0; k < uNumType; k++)
				{
					m_pHashKey32[k].gPosition[j][i] = rand() ^ ( (LONG    )rand() << 15 ) ^ ( (LONG    )rand() << 30 );
					m_pHashKey64[k].gPosition[j][i] = rand() ^ ( (LONGLONG)rand() << 15 ) ^ ( (LONGLONG)rand() << 30 ) ^ ( (LONGLONG)rand() << 45 );
				}
			}
		}
	}

	~CZobristHash(void)
	{
		delete[] m_pHashKey32;
		delete[] m_pHashKey64;

		delete[] m_pHash;

		delete[] m_ppTranspositionTable[TRUE];
		delete[] m_ppTranspositionTable[FALSE];

		delete[] m_ppTranspositionTable;

		delete[] m_pRepetitionDetection;
	}

	VOID Initialize(BOARD<TYPE, WIDTH, HEIGHT>& Board)
	{
		UINT uType;

		m_dwHashKey32 = 0;
		m_uHashKey64  = 0;

		for(INT i = 0; i < WIDTH; i++)
		{
			for(INT j = 0; j < HEIGHT; j++)
			{
				if( (uType = m_puTypeSubscript[Board.gPosition[j][i]]) != -1 )
				{
					m_dwHashKey32 = m_dwHashKey32 ^ m_pHashKey32[uType].gPosition[j][i];
					m_uHashKey64  = m_uHashKey64  ^ m_pHashKey64[uType].gPosition[j][i];
				}
			}
		}
	}

	inline BOOL LookUpHash(INT& nOutput, INT nApha, INT nBeta, UINT uDepth, BOOL bIsCurrentSide)const
	{
		LPTRANSPOSITIONTABLEITEM pItem = &m_ppTranspositionTable[bIsCurrentSide][m_dwHashKey32 % m_dwSize];

		if( pItem->uDepth == uDepth && pItem->uCheckSum == m_uHashKey64
		&& (pItem->Type == EXACT 
		|| (pItem->Type == LOWER_BOUND && pItem->nEval >= nBeta)
		|| (pItem->Type == UPPER_BOUND && pItem->nEval <= nApha) ) )
		{
			nOutput = pItem->nEval;
			return TRUE;
		}

		return FALSE;
	}

	inline BOOL LookUpHash(UINT uDepth)const
	{
		LPREPETITIONDETECTIONITEM pItem = &m_pRepetitionDetection[m_dwHashKey32 % m_dwSize];

		return pItem->uDepth > uDepth && pItem->uCheckSum == m_uHashKey64;
	}

	inline BOOL LookUpHash()const
	{
		return m_pHash[m_dwHashKey32 % m_dwSize].uCheckSum == m_uHashKey64;
	}

	inline VOID EnterHash(TRANSPOSITIONTABLETYPE Type, SHORT nEval, WORD uDepth, BOOL bIsCurrentSide)
	{
		LPTRANSPOSITIONTABLEITEM pItem = &m_ppTranspositionTable[bIsCurrentSide][m_dwHashKey32 % m_dwSize];

		pItem->uCheckSum = m_uHashKey64;
		pItem->Type      = Type;
		pItem->nEval     = nEval;
		pItem->uDepth    = uDepth;
	}

	inline VOID EnterHash(WORD uDepth)
	{
		LPREPETITIONDETECTIONITEM pItem = &m_pRepetitionDetection[m_dwHashKey32 % m_dwSize];

		pItem->uCheckSum = m_uHashKey64;
		pItem->uDepth    = uDepth;
	}

	inline VOID EnterHash()
	{
		m_pHash[m_dwHashKey32 % m_dwSize].uCheckSum = m_uHashKey64;
	}
private:
	typedef struct
	{
		ULONGLONG uCheckSum;
	}HASHITEM, * LPHASHITEM;

	typedef struct :
	public HASHITEM
	{
		WORD uDepth;
	}REPETITIONDETECTIONITEM, * LPREPETITIONDETECTIONITEM;

	typedef struct :
	public REPETITIONDETECTIONITEM
	{
		//ULONGLONG uCheckSum;
		TRANSPOSITIONTABLETYPE  Type;
		//WORD      uDepth;
		SHORT     nEval;
	}TRANSPOSITIONTABLEITEM, * LPTRANSPOSITIONTABLEITEM;

	BOARD<DWORD    , WIDTH, HEIGHT>* m_pHashKey32;
	BOARD<ULONGLONG, WIDTH, HEIGHT>* m_pHashKey64;
	LPHASHITEM                       m_pHash;
	LPREPETITIONDETECTIONITEM        m_pRepetitionDetection;
	LPTRANSPOSITIONTABLEITEM*        m_ppTranspositionTable;
	DWORD                            m_dwHashKey32;
	ULONGLONG                        m_uHashKey64;
	UINT                             m_uType;
	DWORD                            m_dwSize;

	PUINT							 m_puTypeSubscript;
};
