// ChessDlg.h : 头文件
//

#pragma once
//#include "NegamaxEngine.h"
//#include "ChessMoveGenerator.h"
//#include "ChessEveluation.h"
//#include "AlphaBetaEngine.h"
#include "afxwin.h"

typedef struct
{
	CHESSMANTYPE Type;
	POINT        From;
	POINT        To;
}MOVECHESS;

// CChessDlg 对话框
class CChessDlg : public CDialog
{
// 构造
public:
	CChessDlg(CWnd* pParent = NULL);	// 标准构造函数

// 对话框数据
	enum { IDD = IDD_CHESS_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV 支持

protected:

// 实现
protected:
	HICON m_hIcon;

	// 生成的消息映射函数
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
private:
	BASECHESSBOARD m_ChessBoard;
	BASECHESSBOARD m_BackupChessBoard;

	CMover<CHESSMANTYPE, CHESS_WIDTH, CHESS_HEIGHT> m_Mover;

	std::vector<BASECHESSBOARD> m_HistoryChessBoard;

	CStatic m_OutputInfo;
	CListBox m_History;

	CHESSSIDE m_Side;
	UINT m_uCurrentChessBoard;

	MOVECHESS  m_MoveChess;
	CBitmap    m_BoardBitmap;
	CImageList m_Chessman;

	INT        m_nBoardWidth;
	INT        m_nBoardHeight;

	CSearchEngine CHESS* m_pSearchEngine;
public:
	VOID ShowHistoryInfo(CHESSMANTYPE From, CHESSMANTYPE To, UINT uFromX, UINT uFromY, UINT uToX, UINT uToY);
	afx_msg void OnMouseMove(UINT nFlags, CPoint point);
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnLButtonUp(UINT nFlags, CPoint point);
	
	afx_msg void OnNewGame();
	afx_msg void OnLbnDblclkHistory();
	afx_msg void OnSaveGame();
	afx_msg void OnAbout();
};
