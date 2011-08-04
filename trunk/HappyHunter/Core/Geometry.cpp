#include "StdAfx.h"
#include "Geometry.h"

using namespace zerO;

CGeometrySubset::CGeometrySubset(CGeometry& Parent, zerO::UINT uStartVertex, zerO::UINT uEndVertex) :
m_pParent(&Parent),
m_uStartVertex(uStartVertex),
m_uEndVertex(uEndVertex),
m_uNumVertices(uEndVertex - uStartVertex + 1)
{
	m_pParent->m_RenderMethod.SetSurface(&m_Surface);
	m_pParent->m_SubsetList.push_back(this);

	if(m_pParent->m_pParent)
		m_pParent->m_pParent->AddChild(this);
}

CGeometrySubset::~CGeometrySubset(void)
{
	Destroy();
}

bool CGeometrySubset::ApplyForRender()
{
	return true;
}

void CGeometrySubset::Render(CRenderQueue::LPRENDERENTRY pEntry, zerO::UINT32 uFlag)
{
}

bool CGeometrySubset::Destroy()
{
	return true;
}

const D3DVERTEXELEMENT9 g_GEOMETRY_VERTEX_DESCRIPTION[]=
{
	{0, 0, D3DDECLTYPE_FLOAT3, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_POSITION, 0},
	{1, 0, D3DDECLTYPE_FLOAT2, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_TEXCOORD, 0},
	{1, 8, D3DDECLTYPE_FLOAT3, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_NORMAL, 0},
	{2, 0, D3DDECLTYPE_FLOAT3, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_TANGENT, 0},
	{2, 12, D3DDECLTYPE_FLOAT3, D3DDECLMETHOD_DEFAULT, D3DDECLUSAGE_BINORMAL, 0},
	D3DDECL_END()
};

CGeometry::CGeometry(CSceneNode* pParent, zerO::UINT8 uFlag) :
	m_uFlag(uFlag),
		m_pParent(pParent)
{
}

CGeometry::~CGeometry(void)
{
	Destroy();
}

bool CGeometry::Destroy()
{
	for(std::vector<CGeometrySubset*>::iterator i = m_SubsetList.begin(); i != m_SubsetList.end(); i ++)
	{
		(*i)->Destroy();

		DEBUG_DELETE(*i);
	}

	m_SubsetList.clear();

	return true;
}

bool CGeometry::Create(const zerO::PUINT8 pData)
{
	return true;
}

bool CGeometry::CreatePlane(
							 zerO::FLOAT fWidth, 
							 zerO::FLOAT fHeight, 
							 zerO::UINT uVerticesX, 
							 zerO::UINT uVerticesY,
							 zerO::UINT uStepX,
							 zerO::UINT uStepY)
{
	LPVERTEX pVertices;
	LPVERTEXINFO pInfo;
	LPVERTEXADDITIONALINFO pAdditionalInfo;

	zerO::UINT uNumVertices, i, j, k = 0, uSegmentX = uVerticesX - 1, uSegmentY = uVerticesY - 1;

	zerO::FLOAT 
		fWidthPerSegment  = fWidth  / uSegmentX, 
		fHeightPerSegment = fHeight / uSegmentY,
		fPerSegmentU = 1.0f / uSegmentX,
		fPerSegmentV = 1.0f / uSegmentY,
		fHalfWidth = fWidth * 0.5f;

	D3DXVECTOR2 Position(- fHalfWidth, - fHeight * 0.5f);
	D3DXVECTOR2 UV(0.0f, 0.0f);

	CGeometrySubset* pSubset;

	uNumVertices = uVerticesX * uVerticesY;

	DEBUG_NEW( pSubset, CGeometrySubset(*this, 0, uNumVertices - 1) );
	DEBUG_NEW(pVertices, VERTEX[uNumVertices]);
	DEBUG_NEW(pInfo, VERTEXINFO[uNumVertices]);
	DEBUG_NEW(pAdditionalInfo, VERTEXADDITIONALINFO[uNumVertices]);

	//m_SubsetList.push_back(pSubset);

	for(i = 0; i < uVerticesY; i ++)
	{
		for(j = 0; j < uVerticesX; j ++)
		{
			pVertices[k].Position.x = Position.x;
			pVertices[k].Position.y = 0.0f;
			pVertices[k].Position.z = Position.y;

			/*pVertices[k].UV.x       = UV.x;
			pVertices[k].UV.y       = UV.y;*/
			pInfo[k].UV.x = UV.x;
			pInfo[k].UV.y = UV.y;

			k ++;

			Position.x += fWidthPerSegment;

			UV.x += fPerSegmentU;
		}

		Position.x  = - fHalfWidth;
		Position.y += fHeightPerSegment;

		UV.x  = 0.0f;
		UV.y += fPerSegmentV;
	}

	if( m_VertexBuffer.Create(uNumVertices, sizeof(VERTEX), D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED, (void*)pVertices) && 
		pSubset->m_IndexBuffer.CreateSingleStripGrid(uVerticesX, uVerticesY, uStepX, uStepY, uVerticesX, D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED) )
	{

		if( m_VertexBuffer.SetVertexDescription(sizeof(g_GEOMETRY_VERTEX_DESCRIPTION) / sizeof(D3DVERTEXELEMENT9), g_GEOMETRY_VERTEX_DESCRIPTION) )
		{
			void* pIndices;
			if( pSubset->m_IndexBuffer.Lock(0, &pIndices) )
			{
				ComputeMeshNoraml(
					uNumVertices, 
					pSubset->m_IndexBuffer.GetCount(),
					pIndices,
					pSubset->m_IndexBuffer.GetStride(),
					pSubset->m_IndexBuffer.GetType(),
					pVertices,
					sizeof(VERTEX),
					0,
					pInfo,
					sizeof(VERTEXINFO),
					8);

				ComputeMeshTangent(
					uNumVertices,
					pSubset->m_IndexBuffer.GetCount(),
					pIndices,
					pSubset->m_IndexBuffer.GetStride(),
					pSubset->m_IndexBuffer.GetType(),
					pVertices,
					sizeof(VERTEX),
					0,
					pInfo,
					sizeof(VERTEXINFO),
					0,
					pAdditionalInfo,
					sizeof(VERTEXADDITIONALINFO),
					0,
					pInfo,
					sizeof(VERTEXINFO),
					8,
					pAdditionalInfo,
					sizeof(VERTEXADDITIONALINFO),
					12);

				pSubset->m_IndexBuffer.Unlock();
			}

			m_VertexInfoBuffer.Create(uNumVertices, sizeof(VERTEXINFO), D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED, (void*)pInfo);
			m_VertexAdditionalInfoBuffer.Create(uNumVertices, sizeof(VERTEXADDITIONALINFO), D3DUSAGE_WRITEONLY, D3DPOOL_MANAGED, (void*)pAdditionalInfo);
			
			DEBUG_DELETE_ARRAY(pVertices      );
			DEBUG_DELETE_ARRAY(pInfo          );
			DEBUG_DELETE_ARRAY(pAdditionalInfo);
			
			return true;//pSubset->ComputeNoraml() && pSubset->ComputeTangent(true);
		}
	}

	DEBUG_DELETE_ARRAY(pVertices      );
	DEBUG_DELETE_ARRAY(pInfo          );
	DEBUG_DELETE_ARRAY(pAdditionalInfo);

	return false;
}

bool CGeometry::DrawSubset(zerO::UINT uIndex, bool bIsActiveVertices, bool bIsAutoEffect,const LPD3DXMATRIX pWorldMatrix)
{
	if(m_SubsetList.size() > uIndex)
	{
		CGeometrySubset* pSubset = m_SubsetList[uIndex];

		if(bIsActiveVertices)
			m_VertexBuffer.Activate(0, 0, true);

		pSubset->m_IndexBuffer.Activate();

		if(bIsAutoEffect)
		{
			CEffect* pEffect = m_RenderMethod.GetEffect(uIndex);

			pEffect = pEffect ? pEffect : m_RenderMethod.GetEffect();
			if(pEffect)
			{
				zerO::UINT i, uTotalPass = pEffect->GetTechniqueDesc().Passes;

				pEffect->Begin();

				if(pWorldMatrix)
					pEffect->SetMatrix(CEffect::WORLD, *pWorldMatrix);

				pEffect->SetSurface( m_RenderMethod.GetSurface(uIndex) );

				for(i = 0; i < uTotalPass; i ++)
				{
					pEffect->BeginPass(i);
					
					DEVICE.DrawIndexedPrimitive( pSubset->m_IndexBuffer.GetType(), 0, 0, pSubset->m_uNumVertices, 0, pSubset->m_IndexBuffer.GetPrimitiveCount() );

					pEffect->EndPass();
				}

				pEffect->End();

				return true;
			}
		}
		else
		{
			DEVICE.DrawIndexedPrimitive( pSubset->m_IndexBuffer.GetType(), 0, 0, pSubset->m_uNumVertices, 0, pSubset->m_IndexBuffer.GetPrimitiveCount() );

			return true;
		}
	}

	return false;
}

bool CGeometry::Draw(bool bIsAutoEffect,const LPD3DXMATRIX pWorldMatrix)
{
	std::vector<CGeometrySubset*>::iterator i;

	m_VertexBuffer.Activate(0, 0, true);
	m_VertexInfoBuffer.Activate(1, 0, false);
	m_VertexAdditionalInfoBuffer.Activate(2, 0, false);

	zerO::UINT uIndex, j, uTotalPass;

	if(bIsAutoEffect)
	{
		CEffect* pEffect = m_RenderMethod.GetEffect();

		if(pEffect)
		{
			pEffect->Begin();

			uIndex = 0;
			for(i = m_SubsetList.begin(); i != m_SubsetList.end(); i ++)
			{
				if( m_RenderMethod.GetEffect() == pEffect || !m_RenderMethod.GetEffect() )
				{
					uTotalPass = pEffect->GetTechniqueDesc().Passes;

					(*i)->m_IndexBuffer.Activate();

					if(pWorldMatrix)
						pEffect->SetMatrix(CEffect::WORLD, *pWorldMatrix);

					pEffect->SetSurface( m_RenderMethod.GetSurface(uIndex) );

					for(j = 0; j < uTotalPass; j ++)
					{
						pEffect->BeginPass(j);
						
						DEVICE.DrawIndexedPrimitive( (*i)->m_IndexBuffer.GetType(), 0, 0, (*i)->m_uNumVertices, 0, (*i)->m_IndexBuffer.GetPrimitiveCount() );

						pEffect->EndPass();
					}
				}
			}

			pEffect->End();

			uIndex = 0;
			for(i = m_SubsetList.begin(); i != m_SubsetList.end(); i ++)
			{
				if( m_RenderMethod.GetEffect() != pEffect || m_RenderMethod.GetEffect() )
				{
					uTotalPass = pEffect->GetTechniqueDesc().Passes;

					(*i)->m_IndexBuffer.Activate();

					pEffect->Begin();

					if(pWorldMatrix)
						pEffect->SetMatrix(CEffect::WORLD, *pWorldMatrix);

					pEffect->SetSurface( m_RenderMethod.GetSurface(uIndex) );

					for(j = 0; j < uTotalPass; j ++)
					{
						pEffect->BeginPass(j);
						
						DEVICE.DrawIndexedPrimitive( (*i)->m_IndexBuffer.GetType(), 0, 0, (*i)->m_uNumVertices, 0, (*i)->m_IndexBuffer.GetPrimitiveCount() );

						pEffect->EndPass();
					}

					pEffect->End();
				}
			}

			return true;
		}
		else
			return false;
	}
	else
	{
		for(i = m_SubsetList.begin(); i != m_SubsetList.end(); i ++)
		{
			(*i)->m_IndexBuffer.Activate();

			DEVICE.DrawIndexedPrimitive( (*i)->m_IndexBuffer.GetType(), 0, 0, (*i)->m_uNumVertices, 0, (*i)->m_IndexBuffer.GetPrimitiveCount() );
		}

		return true;
	}

	return false;
}