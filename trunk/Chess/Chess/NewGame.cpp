// NewGame.cpp : implementation file
//

#include "stdafx.h"
#include "Chess.h"
#include "NewGame.h"


// CNewGame dialog

IMPLEMENT_DYNAMIC(CNewGame, CDialog)

CNewGame::CNewGame(CWnd* pParent /*=NULL*/)
	: CDialog(CNewGame::IDD, pParent)
{

}

CNewGame::~CNewGame()
{
}

void CNewGame::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_LISTENGINE, m_SearchEngineList);
	DDX_Control(pDX, IDC_PLY, m_SetPly);
	DDX_Control(pDX, IDC_ENGINETEXT, m_EngineText);
}


BEGIN_MESSAGE_MAP(CNewGame, CDialog)
	ON_LBN_SELCHANGE(IDC_LISTENGINE, &CNewGame::OnLbnSelchangeListengine)
	ON_BN_CLICKED(IDC_LOADGAME, &CNewGame::OnBnClickedLoadgame)
END_MESSAGE_MAP()

void CNewGame::OnOK()
{
	m_nSelectedEngine = m_SearchEngineList.GetCurSel();
	m_nSelectedPly    = m_SetPly.GetPos();
	m_bIsLoadGame     = FALSE;
	CDialog::OnOK();
}

BOOL CNewGame::OnInitDialog()
{
	BOOL bOnInitDialog = CDialog::OnInitDialog();

	m_SearchEngineList.AddString(L"Negamax Search Engine");
	m_SearchEngineList.AddString(L"Alpha-beta Search Engine");
	m_SearchEngineList.AddString(L"Aspiration Search Engine");
	m_SearchEngineList.AddString(L"Principal Variation Search Engine");
	m_SearchEngineList.AddString(L"MTD(f) Search Engine");
	m_SearchEngineList.AddString(L"Quiescene Search Engine");

	m_EngineText.SetWindowText(L"负极大值引擎,最基本的深度优先引擎,速度最慢.(默认)");
	m_SearchEngineList.SetCurSel(0);

	m_SetPly.SetRange(1, 8);
	m_SetPly.SetPos(3);

	return bOnInitDialog;
}

// CNewGame message handlers
void CNewGame::OnLbnSelchangeListengine()
{
	CString String;
	switch( m_SearchEngineList.GetCurSel() )
	{
	case 0:
		String = "负极大值引擎,最基本的深度优先引擎,速度最慢.";
		break;
	case 1:
		String = "双裁减引擎,负极大值引擎的升级版,目前最流行的人工智能核心.支持置换表,迭代深化,历史/杀手启发,循环检测.";
		break;
	case 2:
		String = "渴望搜索,双裁减引擎的增强版,低深度时最快的引擎,支持置换表,历史/杀手启发,循环检测.";
		break;
	case 3:
		String = "PVS引擎,双裁减引擎的变种,世界最强大的博弈型人工智能次代程序即PVS引擎,支持置换表,迭代深化,历史/杀手启发,循环检测.";
		break;
	case 4:
		String = "MTD(f)引擎,双裁减引擎的增强版, 速度很快,人工智能跨时代的产物,支持置换表,迭代深化,历史/杀手启发,循环检测.";
		break;
	case 5:
		String = "静态搜索,唯一一款采用最优优先的人工智能引擎,速度不定向,但是智能度最高,目前估值不完善.";
		break;
	}

	m_EngineText.SetWindowText(String);
}

void CNewGame::OnBnClickedLoadgame()
{
	CFileDialog FileDlg(TRUE, NULL, NULL, 4|2, L"AI Chess Save Files (*.aics)|*.aics|All Files (*.*)|*.*||");
	if(FileDlg.DoModal() == IDOK)
	{
		CString String = FileDlg.GetPathName();
		CFile File(String, CFile::modeRead);
		File.Read( m_pChessBoard, sizeof(BASECHESSBOARD) );
		File.Close();
		OnOK();
		m_bIsLoadGame = TRUE;
	}
}
