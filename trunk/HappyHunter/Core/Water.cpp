#include "StdAfx.h"
#include "Water.h"
#include "Camera.h"
#include "TexturePrinter.h"

using namespace zerO;

zerO::UINT CWater::sm_uTexture = 0;

CWater::CWater(void) :
m_Plane(0, 1.0f, 0.0f, 0.0f)
{
	GAMEHOST.SetWater(this);

	D3DXMatrixIdentity(&m_Matrix);
}

CWater::~CWater(void)
{
}

bool CWater::Create(zerO::FLOAT fWidth, zerO::FLOAT fHeight, zerO::UINT uSegmentsX, zerO::UINT uSegmentsY)
{
	/*VERTEX Vertices[4];

	Vertices[0].x = - fSize;
	Vertices[0].y =   0;
	Vertices[0].z = - fSize;

	Vertices[1].x = - fSize;
	Vertices[1].y =   0;
	Vertices[1].z =   fSize;

	Vertices[2].x =   fSize;
	Vertices[2].y =   0;
	Vertices[2].z = - fSize;

	Vertices[3].x =   fSize;
	Vertices[3].y =   0;
	Vertices[3].z =   fSize;*/

	LPVERTEX pVertices;

	zerO::UINT i, j, k = 0, uNumVertices;

	zerO::FLOAT fWidthPerSegment = fWidth / uSegmentsX, fHeightPerSegment = fHeight / uSegmentsY;

	D3DXVECTOR2 Position(- fWidth * 0.5f, - fHeight * 0.5f);

	m_uVerticesX = uSegmentsX + 1;
	m_uVerticesY = uSegmentsY + 1;

	uNumVertices = m_uVerticesX * m_uVerticesY;

	DEBUG_NEW(pVertices, VERTEX[uNumVertices]);

	for(i = 0; i < m_uVerticesY; i ++)
	{
		for(j = 0; j < m_uVerticesX; j ++)
		{
			pVertices[k].x = Position.x;
			pVertices[k].y = 0.0f;
			pVertices[k].z = Position.y;
			pVertices[k].w = 1.0f;

			k ++;

			Position.x += fWidthPerSegment;
		}

		Position.x  = - fWidth * 0.5f;
		Position.y += fHeightPerSegment;
	}

	if( m_VertexBuffer.Create(uNumVertices, sizeof(VERTEX), D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED, (void*)pVertices, D3DFVF_XYZW) && m_IndexBuffer.CreateSingleStripGrid(m_uVerticesX, m_uVerticesY, 1, 1, m_uVerticesX, D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED) )
	{
		DEBUG_DELETE_ARRAY(pVertices);

		return true;
	}

	DEBUG_DELETE_ARRAY(pVertices);

	return false;
}

void CWater::Update()
{
	D3DXVECTOR3 Position = CAMERA.GetWorldPosition();
	
	//m_Matrix._41 = Position.x;
	//m_Matrix._43 = Position.z;
}

void CWater::Render()
{
	/*if(!sm_uTexture)
		sm_uTexture = GAMEHOST.GetTexturePrinter()->AddTexture();

	DEVICE.SetTexture( 0, GAMEHOST.GetTexturePrinter()->GetTexture(0)->GetTexture() );

	GAMEHOST.GetTexturePrinter()->Draw(sm_uTexture);

	DEVICE.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
	DEVICE.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
	DEVICE.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_DISABLE);

	DEVICE.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_CAMERASPACEPOSITION | 1);
	DEVICE.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT3|D3DTTFF_PROJECTED);

	//设置纹理坐标变换矩阵
	static D3DXMATRIX s_Matrix;
	s_Matrix._11 = 1.0f; s_Matrix._12 = 0.0f; s_Matrix._13 = 0.0f; s_Matrix._41 = 0.0f;
	s_Matrix._21 = 0.0f; s_Matrix._22 = 1.0f; s_Matrix._23 = 0.0f; s_Matrix._42 = 0.0f;
	s_Matrix._31 = 0.5f; s_Matrix._32 = 0.5f; s_Matrix._33 = 1.0f; s_Matrix._43 = 0.0f;
	s_Matrix._41 = 0.0f; s_Matrix._42 = 0.0f; s_Matrix._43 = 0.0f; s_Matrix._44 = 0.0f;

	DEVICE.SetVertexShader(NULL);
	DEVICE.SetPixelShader(NULL);

	DEVICE.SetTransform( D3DTS_TEXTURE0,   &s_Matrix );
	DEVICE.SetTransform( D3DTS_WORLD,      &m_Matrix); 
	DEVICE.SetTransform( D3DTS_VIEW,       &CAMERA.GetViewMatrix() );
	DEVICE.SetTransform( D3DTS_PROJECTION, &CAMERA.GetProjectionMatrix() );

	//DEVICE.SetRenderState( D3DRS_FILLMODE, D3DFILL_WIREFRAME );

	m_VertexBuffer.Activate(0, 0, true);
	m_IndexBuffer.Activate();

	DEVICE.DrawIndexedPrimitive( D3DPT_TRIANGLESTRIP, 0, 0, m_uVerticesX * m_uVerticesY, 0, m_IndexBuffer.GetPrimitiveCount() );

	//DEVICE.SetRenderState( D3DRS_FILLMODE, D3DFILL_SOLID );

	D3DXMatrixIdentity(&s_Matrix);
	DEVICE.SetTransform(D3DTS_TEXTURE0,   &s_Matrix);

	DEVICE.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_PASSTHRU);
	DEVICE.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_DISABLE);

	GAMEHOST.GetTexturePrinter()->End(CTexturePrinter::RENDER_SURFACE);

	DEVICE.SetTexture( 0, GAMEHOST.GetTexturePrinter()->GetTexture(sm_uTexture)->GetTexture() );

	GAMEHOST.GetTexturePrinter()->Draw(0);

	GAMEHOST.GetTexturePrinter()->End();

	//DEVICE.SetTexture( 0, GAMEHOST.GetTexturePrinter()->GetTexture(sm_uTexture)->GetTexture() );

	FLOAT sx = (FLOAT)GAMEHOST.GetBackBufferSurfaceDesc().Width;
	FLOAT sy = (FLOAT)GAMEHOST.GetBackBufferSurfaceDesc().Height;

	m_Vertices[0].Position = D3DXVECTOR4(0 , sy, 0.0f, 1.0f);
	m_Vertices[1].Position = D3DXVECTOR4(0 ,  0, 0.0f, 1.0f);
	m_Vertices[2].Position = D3DXVECTOR4(sx, sy, 0.0f, 1.0f);
	m_Vertices[3].Position = D3DXVECTOR4(sx,  0, 0.0f, 1.0f);
	m_Vertices[0].UV       = D3DXVECTOR2(0.0f, 1.0f);
	m_Vertices[1].UV       = D3DXVECTOR2(0.0f, 0.0f);
	m_Vertices[2].UV       = D3DXVECTOR2(1.0f, 1.0f);
	m_Vertices[3].UV       = D3DXVECTOR2(1.0f, 0.0f);

	DEVICE.SetTextureStageState( 0, D3DTSS_COLOROP, D3DTOP_MODULATE );
	DEVICE.SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
	DEVICE.SetTextureStageState( 0, D3DTSS_COLORARG2, D3DTA_CURRENT );
	DEVICE.SetTextureStageState( 0, D3DTSS_ALPHAOP, D3DTOP_SELECTARG1 );
	DEVICE.SetTextureStageState( 0, D3DTSS_ALPHAARG1, D3DTA_TEXTURE );
	DEVICE.SetRenderState( D3DRS_ALPHABLENDENABLE, FALSE );
	DEVICE.SetFVF(D3DFVF_XYZRHW | D3DFVF_TEX1);
	DEVICE.SetTexture( 0, GAMEHOST.GetTexturePrinter()->GetTexture(0)->GetTexture() );
	DEVICE.DrawPrimitiveUP( D3DPT_TRIANGLESTRIP, 2, m_Vertices, sizeof(RENDERVERTEX) );*/

	/*DEVICE.Clear(0, NULL, D3DCLEAR_STENCIL, 0, 1.0f, 0);

	DEVICE.SetRenderState(D3DRS_STENCILENABLE,    true);
    DEVICE.SetRenderState(D3DRS_STENCILFUNC,      D3DCMP_ALWAYS);
    DEVICE.SetRenderState(D3DRS_STENCILREF,       0x1);
    DEVICE.SetRenderState(D3DRS_STENCILMASK,      0xffffffff);
    DEVICE.SetRenderState(D3DRS_STENCILWRITEMASK, 0xffffffff);
    DEVICE.SetRenderState(D3DRS_STENCILZFAIL,     D3DSTENCILOP_KEEP);
    DEVICE.SetRenderState(D3DRS_STENCILFAIL,      D3DSTENCILOP_KEEP);
    DEVICE.SetRenderState(D3DRS_STENCILPASS,      D3DSTENCILOP_REPLACE);

	// disable writes to the depth and back buffers
    DEVICE.SetRenderState(D3DRS_ZWRITEENABLE, false);
    DEVICE.SetRenderState(D3DRS_ALPHABLENDENABLE, true);
    DEVICE.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_ZERO);
    DEVICE.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);

	DEVICE.SetVertexShader(NULL);
	DEVICE.SetPixelShader(NULL);

	DEVICE.SetTransform( D3DTS_WORLD,      &m_Matrix); 
	DEVICE.SetTransform( D3DTS_VIEW,       &CAMERA.GetViewMatrix() );
	DEVICE.SetTransform( D3DTS_PROJECTION, &CAMERA.GetProjectionMatrix() );

	m_VertexBuffer.Activate(0, 0, true);
	m_IndexBuffer.Activate();

	DEVICE.DrawIndexedPrimitive( D3DPT_TRIANGLESTRIP, 0, 0, m_uVerticesX * m_uVerticesY, 0, m_IndexBuffer.GetPrimitiveCount() );

	// re-enable depth writes
	DEVICE.SetRenderState( D3DRS_ZWRITEENABLE, true );

	// only draw reflected teapot to the pixels where the mirror
	// was drawn to.
	DEVICE.SetRenderState(D3DRS_STENCILFUNC,  D3DCMP_EQUAL);
    DEVICE.SetRenderState(D3DRS_STENCILPASS,  D3DSTENCILOP_KEEP);

	//D3DXPLANE Plane;

	//D3DXPlaneTransform( &Plane, &m_Plane, &CAMERA.GetViewMatrix() );
	//D3DXPlaneNormalize(&Plane, &Plane);

	D3DXMATRIX Matrix, s;
	D3DXMatrixReflect(&Matrix, &m_Plane);

	CAMERA.Update();
	CAMERA.SetTransform(CAMERA.GetWorldMatrix() * Matrix);

	CAMERA.Update();

	GAMEHOST.GetScene().Update();
	//CASE(GAMEHOST.GetScene(), CSprite).SetTransform(GAMEHOST.GetScene().GetWorldMatrix() * Matrix);
	//GAMEHOST.GetScene().Update();

	DEVICE.Clear(0, 0, D3DCLEAR_ZBUFFER, 0, 1.0f, 0);
	DEVICE.SetRenderState(D3DRS_ALPHABLENDENABLE, false);
	//DEVICE.SetRenderState(D3DRS_SRCBLEND,  D3DBLEND_DESTCOLOR);
    //DEVICE.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ZERO);

	DEVICE.SetRenderState(D3DRS_CULLMODE, D3DCULL_CW);

	//DEVICE.SetClipPlane(0, (float*)&Plane);
	//DEVICE.SetRenderState(D3DRS_CLIPPLANEENABLE, TRUE);

	GAMEHOST.GetScene().AddedToRenderQueue();

	GAMEHOST.GetRenderQueue().Render();

	//DEVICE.SetRenderState(D3DRS_CLIPPLANEENABLE, FALSE);

	// Restore render states.
	//DEVICE.SetRenderState(D3DRS_ALPHABLENDENABLE, false);
	DEVICE.SetRenderState( D3DRS_STENCILENABLE, false);
	DEVICE.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

	CAMERA.SetTransform(CAMERA.GetWorldMatrix() * Matrix);
	//CASE(GAMEHOST.GetScene(), CSprite).SetTransform(GAMEHOST.GetScene().GetWorldMatrix() * Matrix);*/

	if(!sm_uTexture)
		sm_uTexture = GAMEHOST.GetTexturePrinter()->AddTexture();

	GAMEHOST.GetTexturePrinter()->Begin();

	//DEVICE.SetRenderState( D3DRS_ZWRITEENABLE, FALSE );

	GAMEHOST.GetTexturePrinter()->Activate(sm_uTexture, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER);

	CAMERA.Update();

	//D3DXPLANE Plane(0, -1, 0, 0);

	D3DXMATRIX Matrix;

	D3DXMatrixReflect(&Matrix, &m_Plane);

	CAMERA.SetTransform(CAMERA.GetWorldMatrix() * Matrix);

	CAMERA.Update();

	CAMERA.ModifyProjectionMatrix(m_Plane);

	CAMERA.Update();

	//D3DXMatrixInverse(&Matrix, NULL, &Matrix);
	//D3DXPlaneTransform( &Plane, &m_Plane, &CAMERA.GetViewMatrix() );

	//DEVICE.SetClipPlane(0, (float*)&Plane);
	//DEVICE.SetRenderState(D3DRS_CLIPPLANEENABLE, TRUE);

	GAMEHOST.GetScene().Update();

	DEVICE.SetRenderState(D3DRS_CULLMODE, D3DCULL_CW);

	GAMEHOST.GetScene().AddedToRenderQueue();

	GAMEHOST.GetRenderQueue().Render();

	//CAMERA.ModifyProjectionMatrix( D3DXPLANE(0.0f, 0.0f, 1.0f, - CAMERA.GetNearPlane() ) );
	CAMERA.SetProjection();

	DEVICE.SetRenderState(D3DRS_CLIPPLANEENABLE, FALSE);

	DEVICE.SetRenderState(D3DRS_CULLMODE, D3DCULL_CCW);

	D3DXMatrixReflect(&Matrix, &m_Plane);
	CAMERA.SetTransform(CAMERA.GetWorldMatrix() * Matrix);

	CAMERA.Update();

	GAMEHOST.GetTexturePrinter()->End();

	//DEVICE.SetTexture( 0, GAMEHOST.GetTexturePrinter()->GetTexture(sm_uTexture)->GetTexture() );

	DEVICE.SetVertexShader(NULL);
	DEVICE.SetPixelShader(NULL);

	//DEVICE.SetTransform( D3DTS_WORLD,      &m_Matrix); 
	//DEVICE.SetTransform( D3DTS_VIEW,       &CAMERA.GetViewMatrix() );
	//DEVICE.SetTransform( D3DTS_PROJECTION, &CAMERA.GetProjectionMatrix() );

	DEVICE.SetTextureStageState(0, D3DTSS_COLORARG1, D3DTA_TEXTURE);
	DEVICE.SetTextureStageState(0, D3DTSS_COLOROP,   D3DTOP_SELECTARG1);
	DEVICE.SetTextureStageState(1, D3DTSS_COLOROP,   D3DTOP_DISABLE);

	//DEVICE.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_CAMERASPACEPOSITION);
	//DEVICE.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_COUNT3|D3DTTFF_PROJECTED);

	//设置纹理坐标变换矩阵
	/*static D3DXMATRIX s_Matrix;
	s_Matrix._11 = 1.0f; s_Matrix._12 = 0.0f; s_Matrix._13 = 0.0f; s_Matrix._41 = 0.0f;
	s_Matrix._21 = 0.0f; s_Matrix._22 = -1.0f; s_Matrix._23 = 0.0f; s_Matrix._42 = 0.0f;
	s_Matrix._31 = 0.5f; s_Matrix._32 = 0.5f; s_Matrix._33 = 1.0f; s_Matrix._43 = 0.0f;
	s_Matrix._41 = 0.0f; s_Matrix._42 = 0.0f; s_Matrix._43 = 0.0f; s_Matrix._44 = 0.0f;*/

	DEVICE.SetVertexShader(NULL);
	DEVICE.SetPixelShader(NULL);

	//DEVICE.SetTransform( D3DTS_TEXTURE0,   &s_Matrix );
	//DEVICE.SetTransform( D3DTS_WORLD,      &m_Matrix); 
	//DEVICE.SetTransform( D3DTS_VIEW,       &CAMERA.GetViewMatrix() );
	//DEVICE.SetTransform( D3DTS_PROJECTION, &CAMERA.GetProjectionMatrix() );

	m_VertexBuffer.Activate(0, 0, true);
	m_IndexBuffer.Activate();

	CEffect* pEffect = m_RenderMethod.GetEffect();

	if(pEffect)
	{
		pEffect->SetTexture( 0, *GAMEHOST.GetTexturePrinter()->GetTexture(sm_uTexture) );

		pEffect->Begin();

		pEffect->SetMatrix( CEffect::WORLD_VIEW_PROJECTION, m_Matrix * CAMERA.GetViewProjectionMatrix() );

		m_VertexBuffer.Activate(0, 0, true);

		UINT uTotalPass = pEffect->GetTechniqueDesc().Passes, i;

		for (i = 0; i < uTotalPass; i ++)
		{
			pEffect->GetEffect()->BeginPass(i);

			DEVICE.DrawIndexedPrimitive( D3DPT_TRIANGLESTRIP, 0, 0, m_uVerticesX * m_uVerticesY, 0, m_IndexBuffer.GetPrimitiveCount() );

			pEffect->GetEffect()->EndPass();
		}

		pEffect->End();
	}

	DEVICE.SetVertexShader(NULL);
	DEVICE.SetPixelShader(NULL);
	//D3DXMatrixIdentity(&s_Matrix);
	//DEVICE.SetTransform(D3DTS_TEXTURE0,   &s_Matrix);

	//DEVICE.SetTextureStageState(0, D3DTSS_TEXCOORDINDEX, D3DTSS_TCI_PASSTHRU);
	//DEVICE.SetTextureStageState(0, D3DTSS_TEXTURETRANSFORMFLAGS, D3DTTFF_DISABLE);
}