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

	m_EngineText.SetWindowText(L"������ֵ����,������������������,�ٶ�����.(Ĭ��)");
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
		String = "������ֵ����,������������������,�ٶ�����.";
		break;
	case 1:
		String = "˫�ü�����,������ֵ�����������,Ŀǰ�����е��˹����ܺ���.֧���û���,�����,��ʷ/ɱ������,ѭ�����.";
		break;
	case 2:
		String = "��������,˫�ü��������ǿ��,�����ʱ��������,֧���û���,��ʷ/ɱ������,ѭ�����.";
		break;
	case 3:
		String = "PVS����,˫�ü�����ı���,������ǿ��Ĳ������˹����ܴδ�����PVS����,֧���û���,�����,��ʷ/ɱ������,ѭ�����.";
		break;
	case 4:
		String = "MTD(f)����,˫�ü��������ǿ��, �ٶȺܿ�,�˹����ܿ�ʱ���Ĳ���,֧���û���,�����,��ʷ/ɱ������,ѭ�����.";
		break;
	case 5:
		String = "��̬����,Ψһһ������������ȵ��˹���������,�ٶȲ�����,�������ܶ����,Ŀǰ��ֵ������.";
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
