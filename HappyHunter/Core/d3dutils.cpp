#include "StdAfx.h"
#include "d3dutils.h"

using namespace zerO;

void zerO::UpdateSkinnedMesh(
                  const D3DXMATRIX *pBoneTransforms,
				  zerO::UINT uNumBones,
                  const void* pVerticesSrc,
                  void* pVerticesDst,
				  zerO::UINT uNumTotalVertices,
                  zerO::UINT uStride,
				  zerO::PUINT puNumBoneInfluences,
				  LPDWORD* ppdwVerticesIndices,
				  zerO::PFLOAT* ppfWeights,
				  const D3DXVECTOR3* pTangentSrc,
				  D3DXVECTOR3* pTangentDst
                  )

{
	UINT i, uNumVertices, uOffsetByte, uNormalByte, uIndex, VectorSize = sizeof(D3DXVECTOR3);
	
	FLOAT fWeight;

	UINT8 *pDest = (zerO::PUINT8)pVerticesDst;

	D3DXVECTOR3 *Src, Temp;

	const UINT8 *pSrc = (zerO::PUINT8)pVerticesSrc;

	memcpy(pDest, pSrc, uNumTotalVertices * uStride);

	for(i = 0; i < uNumBones; i++)
	{
	   uNumVertices = puNumBoneInfluences[i];

	   if(uNumVertices <= 0)
		   continue;

	   while(uNumVertices --)
	   {
		   uIndex = ppdwVerticesIndices[i][uNumVertices];

		   fWeight = ppfWeights[i][uNumVertices];

		   uOffsetByte = uIndex * uStride;

		   uNormalByte = uOffsetByte + VectorSize;

		   Src = (D3DXVECTOR3 *)(pSrc + uOffsetByte);

		   D3DXVec3TransformCoord(&Temp, Src, &pBoneTransforms[i]);

		   *( (D3DXVECTOR3 *)(pDest + uOffsetByte) ) += (Temp - *Src) * fWeight;

		   Src = (D3DXVECTOR3 *)(pSrc + uNormalByte);  //·¨Ïß

		   D3DXVec3TransformNormal(&Temp, Src, &pBoneTransforms[i]);

		   *( (D3DXVECTOR3 *)(pDest + uNormalByte) ) += (Temp - *Src) * fWeight;
	   }
	}

	if(pTangentSrc && pTangentDst)
	{
		memcpy(pTangentDst, pTangentSrc, uNumTotalVertices * VectorSize);

		for(i = 0; i < uNumBones; i++)
		{
		   uNumVertices = puNumBoneInfluences[i];

		   if(uNumVertices <= 0)
			   continue;

		   while(uNumVertices --)
		   {

			   uIndex = ppdwVerticesIndices[i][uNumVertices];

			   fWeight = ppfWeights[i][uNumVertices];

			   D3DXVec3TransformNormal(&Temp, &pTangentSrc[uIndex], &pBoneTransforms[i]);

			   pTangentDst[uIndex] += (Temp - pTangentSrc[uIndex]) * fWeight;
		   }
		}
	}
}

void zerO::DirectionToRotation(FLOAT& x, FLOAT& y, const D3DXVECTOR3& Direction)
{
	if( Direction.x == 0 && Direction.z == 0 && Direction.y == 0 )
	{
		x = 0;
		y = 0;
	}
	else if( Direction.x == 0 && Direction.z == 0  )
	{
		x = - asin( Direction.y / D3DXVec3Length(&Direction) );
		y =   0;
	}
	else if( Direction.z < 0 )
	{
		x = - asin( Direction.y / D3DXVec3Length(&Direction) );
		y =   D3DX_PI - asin( Direction.x / sqrt(Direction.x * Direction.x + Direction.z * Direction.z) );
	}
	else
	{
		x = - asin( Direction.y / D3DXVec3Length(&Direction) );
		y =   asin( Direction.x / sqrt(Direction.x * Direction.x + Direction.z * Direction.z) );
	}
}

void zerO::SceneDirectionToRotation(FLOAT& x, FLOAT& y, const D3DXVECTOR3& Direction)
{
	DirectionToRotation(x, y, -Direction);
}

void zerO::QuaternionToEular(D3DXVECTOR3& Eular, const D3DXQUATERNION& Quaternion)
{
	FLOAT sqx = Quaternion.x * Quaternion.x;
	FLOAT sqy = Quaternion.y * Quaternion.y;
	FLOAT sqz = Quaternion.z * Quaternion.z;
	FLOAT sqw = Quaternion.w * Quaternion.w;
	    
	Eular.x = atan2(  2 * (Quaternion.y * Quaternion.z + Quaternion.x * Quaternion.w), - sqx - sqy + sqz + sqw);
	Eular.y = asin( - 2 * (Quaternion.x * Quaternion.z - Quaternion.y * Quaternion.w)                         );
	Eular.z = atan2(  2 * (Quaternion.x * Quaternion.y + Quaternion.z * Quaternion.w),   sqx - sqy - sqz + sqw);
}

void zerO::MatrixDecompose(D3DXVECTOR3 *pOutScale, D3DXVECTOR3 *pOutRotation, D3DXVECTOR3 *pOutTranslation, const D3DXMATRIX& Matrix)
{
	if(pOutRotation)
	{
		D3DXQUATERNION Quaternion;

		D3DXMatrixDecompose(pOutScale, &Quaternion, pOutTranslation, &Matrix);

		D3DXQuaternionNormalize(&Quaternion, &Quaternion);

		QuaternionToEular(*pOutRotation, Quaternion);
	}
	else
		D3DXMatrixDecompose(pOutScale, NULL, pOutTranslation, &Matrix);
}
