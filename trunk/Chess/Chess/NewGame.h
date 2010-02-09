#pragma once
#include "afxwin.h"
#include "afxcmn.h"


// CNewGame dialog

class CNewGame : public CDialog
{
	DECLARE_DYNAMIC(CNewGame)

public:
	CNewGame(CWnd* pParent = NULL);   // standard constructor
	virtual ~CNewGame();

// Dialog Data
	enum { IDD = IDD_NEWGAME };
protected:
	INT m_nSelectedEngine;
	INT m_nSelectedPly;

	virtual void OnOK();
	virtual BOOL OnInitDialog();
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

	DECLARE_MESSAGE_MAP()
public:
	CListBox m_SearchEngineList;
	CSpinButtonCtrl m_SetPly;

public:
	inline INT GetSelectedEngine()const;
	inline INT GetSelectedPly()const;
	inline BOOL GetIsLoadGame()const;
	inline VOID SetChessBoard(LPBASECHESSBOARD pChessBoard);
private:
	BOOL m_bIsLoadGame;
	CStatic m_EngineText;
	LPBASECHESSBOARD m_pChessBoard;
public:
	afx_msg void OnLbnSelchangeListengine();
	afx_msg void OnBnClickedLoadgame();
};

inline INT CNewGame::GetSelectedEngine()const
{
	return m_nSelectedEngine;
}

inline INT CNewGame::GetSelectedPly()const
{
	return m_nSelectedPly;
}

inline BOOL CNewGame::GetIsLoadGame()const
{
	return m_bIsLoadGame;
}

inline VOID CNewGame::SetChessBoard(LPBASECHESSBOARD pChessBoard)
{
	m_pChessBoard = pChessBoard;
}