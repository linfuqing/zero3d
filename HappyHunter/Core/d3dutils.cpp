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

void zerO::TransformPlane(D3DXPLANE& OutPlane, const D3DXPLANE& InPlane, const D3DXMATRIX Matrix)
{
	D3DXMATRIX Temp;
	D3DXMatrixInverse(&Temp, NULL, &Matrix);
	D3DXMatrixTranspose(&Temp, &Temp);

	D3DXPlaneTransform(&OutPlane, &InPlane, &Temp);
}


zerO::UINT zerO::GetPrimitiveCount(D3DPRIMITIVETYPE Type, UINT uNumIndices)
{
	UINT uNumFaces;

	switch(Type)
	{
	case D3DPT_TRIANGLELIST:
		uNumFaces = uNumIndices / 3;
		break;
	case D3DPT_TRIANGLESTRIP:
		uNumFaces = uNumIndices - 2;
		break;
	case D3DPT_TRIANGLEFAN:
		uNumFaces = (uNumIndices - 1) / 2;
		break;
	}

	return uNumFaces;
}

bool zerO::ComputeMeshNoraml(
							   UINT uNumVertices, UINT uNumIndices, 
							   void* pIndicesStream , UINT uIndexStride   , D3DPRIMITIVETYPE Type  ,
							   void* pPositionStream, UINT uPositionStride, UINT uPositionOffset,
							   void* pNormalStream  , UINT uNormalStride  , UINT uNormalOffset  )
{
	D3DXVECTOR3 Normal;
	LPD3DXVECTOR3 pVertex0, pVertex1, pVertex2;
	PUINT8 pBuffer, pIndices = (PUINT8)pIndicesStream, pPosition = (PUINT8)pPositionStream, pNormal =  (PUINT8)pNormalStream;

	UINT i, uIndex0 = 0, uIndex1 = 0, uIndex2 = 0, uIndex = 0, uNumFaces = GetPrimitiveCount(Type, uNumIndices);

	pBuffer = pNormal + uNormalOffset;
	for(i = 0; i < uNumVertices; i ++)
	{
		memset(	pBuffer, 0, sizeof(D3DXVECTOR3) );

		pBuffer += uNormalStride;
	}

	pBuffer  = pIndices;
	switch(Type)
	{
	case D3DPT_TRIANGLESTRIP:

		memcpy(&uIndex1, pBuffer, uIndexStride);
		pBuffer += uIndexStride;
		memcpy(&uIndex0, pBuffer, uIndexStride);
		pBuffer += uIndexStride;

		for(i = 0; i < uNumFaces; i ++)
		{
			if(i & 0x1)
			{
				SWAP(uIndex1, uIndex2, uIndex);

				uIndex0 = 0;
				memcpy(&uIndex0, pBuffer, uIndexStride);
				pBuffer += uIndexStride;
			}
			else
			{
				SWAP(uIndex0, uIndex1, uIndex);

				uIndex2 = 0;
				memcpy(&uIndex2, pBuffer, uIndexStride);
				pBuffer += uIndexStride;
			}

			pVertex0 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex0 + uPositionOffset);
			pVertex1 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex1 + uPositionOffset);
			pVertex2 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex2 + uPositionOffset);

			D3DXVec3Cross( &Normal, &(*pVertex0 - *pVertex2), &(*pVertex1 - *pVertex0) );

			D3DXVec3Normalize(&Normal, &Normal);

			pVertex0 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex0 + uNormalOffset);
			pVertex1 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex1 + uNormalOffset);
			pVertex2 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex2 + uNormalOffset);

			(*pVertex0) += Normal;
			(*pVertex1) += Normal;
			(*pVertex2) += Normal;
		}

		break;

	case D3DPT_TRIANGLEFAN:

		memcpy(&uIndex0, pBuffer, uIndexStride);
		pBuffer += uIndexStride;

		for(i = 0; i < uNumFaces; i ++)
		{
			uIndex1 = 0;
			memcpy(&uIndex1, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			uIndex2 = 0;
			memcpy(&uIndex2, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			pVertex0 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex0 + uPositionOffset);
			pVertex1 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex1 + uPositionOffset);
			pVertex2 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex2 + uPositionOffset);

			D3DXVec3Cross( &Normal, &(*pVertex0 - *pVertex1), &(*pVertex2 - *pVertex0) );

			D3DXVec3Normalize(&Normal, &Normal);

			pVertex0 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex0 + uNormalOffset);
			pVertex1 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex1 + uNormalOffset);
			pVertex2 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex2 + uNormalOffset);

			(*pVertex0) += Normal;
			(*pVertex1) += Normal;
			(*pVertex2) += Normal;
		}

		break;

	default:

		for(i = 0; i < uNumFaces; i ++)
		{
			uIndex0 = 0;
			memcpy(&uIndex0, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			uIndex1 = 0;
			memcpy(&uIndex1, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			uIndex2 = 0;
			memcpy(&uIndex2, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			pVertex0 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex0 + uPositionOffset);
			pVertex1 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex1 + uPositionOffset);
			pVertex2 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex2 + uPositionOffset);

			D3DXVec3Cross( &Normal, &(*pVertex0 - *pVertex2), &(*pVertex1 - *pVertex0) );

			D3DXVec3Normalize(&Normal, &Normal);

			pVertex0 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex0 + uNormalOffset);
			pVertex1 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex1 + uNormalOffset);
			pVertex2 = (LPD3DXVECTOR3)(pNormal + uNormalStride * uIndex2 + uNormalOffset);

			(*pVertex0) += Normal;
			(*pVertex1) += Normal;
			(*pVertex2) += Normal;
		}

		break;
	}

	pBuffer = pNormal + uNormalOffset;
	for(i = 0; i < uNumVertices; i ++)
	{
		D3DXVec3Normalize( (D3DXVECTOR3*)pBuffer, (D3DXVECTOR3*)pBuffer );

		pBuffer += uNormalStride;
	}

	return true;
}

bool zerO::ComputeMeshTangent(
		
							  UINT uNumVertices, UINT uNumIndices, 
							  void* pIndicesStream , UINT uIndexStride   , D3DPRIMITIVETYPE Type,
							  void* pPositionStream, UINT uPositionStride, UINT uPositionOffset ,
							  void* pUVStream      , UINT uUVStride      , UINT uUVOffset       ,
							  void* pTangentStream , UINT uTangentStride , UINT uTangentOffset  ,
							  void* pNormalStream  , UINT uNormalStride  , UINT uNormalOffset   ,
							  void* pBinormalStream, UINT uBinormalStride, UINT uBinormalOffset)
{
	LPD3DXVECTOR3 pVertex0, pVertex1, pVertex2;
	LPD3DXVECTOR2 pUV0, pUV1, pUV2;
	D3DXVECTOR3 Tangent, Edge0, Edge1;
	D3DXVECTOR2 UV0, UV1;
	FLOAT fComponent, fInvertComponent;
	PUINT8 pBuffer, pIndices = (PUINT8)pIndicesStream, pPosition = (PUINT8)pPositionStream, pUV = (PUINT8)pUVStream, pTangent = (PUINT8)pTangentStream;//, pNormal =  (PUINT8)pNormalStream, pBinormal = (PUINT8)pBinormalStream;

	UINT i, uIndex0 = 0, uIndex1 = 0, uIndex2 = 0, uIndex = 0, uNumFaces = GetPrimitiveCount(Type, uNumIndices);

	pBuffer = pTangent + uTangentOffset;
	for(i = 0; i < uNumVertices; i ++)
	{
		memset(	pBuffer, 0, sizeof(D3DXVECTOR3) );

		pBuffer += uTangentStride;
	}

	pBuffer  = pIndices;
	switch(Type)
	{
	case D3DPT_TRIANGLESTRIP:

		memcpy(&uIndex1, pBuffer, uIndexStride);
		pBuffer += uIndexStride;
		memcpy(&uIndex0, pBuffer, uIndexStride);
		pBuffer += uIndexStride;

		for(i = 0; i < uNumFaces; i ++)
		{
			if(i & 0x1)
			{
				SWAP(uIndex1, uIndex2, uIndex);

				uIndex0 = 0;
				memcpy(&uIndex0, pBuffer, uIndexStride);
				pBuffer += uIndexStride;
			}
			else
			{
				SWAP(uIndex0, uIndex1, uIndex);

				uIndex2 = 0;
				memcpy(&uIndex2, pBuffer, uIndexStride);
				pBuffer += uIndexStride;
			}

			pVertex0 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex0 + uPositionOffset);
			pVertex1 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex1 + uPositionOffset);
			pVertex2 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex2 + uPositionOffset);

			pUV0     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex0 + uUVOffset      );
			pUV1     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex1 + uUVOffset      );
			pUV2     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex2 + uUVOffset      );

			Edge0    = *pVertex1 - *pVertex0;
			Edge1    = *pVertex2 - *pVertex0;

			UV0      = *pUV1     - *pUV0;
			UV1      = *pUV2     - *pUV0;

			fComponent = D3DXVec2CCW(&UV1, &UV0);

			if(fComponent)
			{
				fInvertComponent = 1.0f / fComponent;

				Tangent = (Edge0 * - UV1.y + Edge1 * UV0.y) * fInvertComponent;

				D3DXVec3Normalize(&Tangent, &Tangent);

				pVertex0 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex0 + uTangentOffset);
				pVertex1 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex1 + uTangentOffset);
				pVertex2 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex2 + uTangentOffset);

				(*pVertex0) += Tangent;
				(*pVertex1) += Tangent;
				(*pVertex2) += Tangent;
			}
		}

		break;

	case D3DPT_TRIANGLEFAN:

		memcpy(&uIndex0, pBuffer, uIndexStride);
		pBuffer += uIndexStride;

		for(i = 0; i < uNumFaces; i ++)
		{
			uIndex1 = 0;
			memcpy(&uIndex1, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			uIndex2 = 0;
			memcpy(&uIndex2, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			pVertex0 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex0 + uPositionOffset);
			pVertex1 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex1 + uPositionOffset);
			pVertex2 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex2 + uPositionOffset);

			pUV0     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex0 + uUVOffset      );
			pUV1     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex1 + uUVOffset      );
			pUV2     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex2 + uUVOffset      );

			Edge0    = *pVertex1 - *pVertex0;
			Edge1    = *pVertex2 - *pVertex0;

			UV0      = *pUV1     - *pUV0;
			UV1      = *pUV2     - *pUV0;

			fComponent = D3DXVec2CCW(&UV1, &UV0);

			if(fComponent)
			{
				fInvertComponent = 1.0f / fComponent;

				Tangent = (Edge0 * - UV1.y + Edge1 * UV0.y) * fInvertComponent;

				D3DXVec3Normalize(&Tangent, &Tangent);

				pVertex0 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex0 + uTangentOffset);
				pVertex1 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex1 + uTangentOffset);
				pVertex2 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex2 + uTangentOffset);

				(*pVertex0) += Tangent;
				(*pVertex1) += Tangent;
				(*pVertex2) += Tangent;
			}
		}

		break;

	default:

		for(i = 0; i < uNumFaces; i ++)
		{
			uIndex0 = 0;
			memcpy(&uIndex0, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			uIndex1 = 0;
			memcpy(&uIndex1, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			uIndex2 = 0;
			memcpy(&uIndex2, pBuffer, uIndexStride);
			pBuffer += uIndexStride;

			pVertex0 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex0 + uPositionOffset);
			pVertex1 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex1 + uPositionOffset);
			pVertex2 = (LPD3DXVECTOR3)(pPosition + uPositionStride * uIndex2 + uPositionOffset);

			pUV0     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex0 + uUVOffset      );
			pUV1     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex1 + uUVOffset      );
			pUV2     = (LPD3DXVECTOR2)(pUV       + uUVStride       * uIndex2 + uUVOffset      );

			Edge0    = *pVertex1 - *pVertex0;
			Edge1    = *pVertex2 - *pVertex0;

			UV0      = *pUV1     - *pUV0;
			UV1      = *pUV2     - *pUV0;

			fComponent = D3DXVec2CCW(&UV1, &UV0);

			if(fComponent)
			{
				fInvertComponent = 1.0f / fComponent;

				Tangent = (Edge0 * - UV1.y + Edge1 * UV0.y) * fInvertComponent;

				D3DXVec3Normalize(&Tangent, &Tangent);

				pVertex0 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex0 + uTangentOffset);
				pVertex1 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex1 + uTangentOffset);
				pVertex2 = (LPD3DXVECTOR3)(pTangent + uTangentStride * uIndex2 + uTangentOffset);

				(*pVertex0) += Tangent;
				(*pVertex1) += Tangent;
				(*pVertex2) += Tangent;
			}
		}

		break;
	}

	pBuffer = pTangent + uTangentOffset;
	if(pNormalStream)
	{
		PUINT8 pNormalBuffer = (PUINT8)pNormalStream + uNormalOffset;

		if(pBinormalStream)
		{
			PUINT8 pBinormalBuffer = (PUINT8)pBinormalStream + uBinormalOffset;
			for(i = 0; i < uNumVertices; i ++)
			{
				const D3DXVECTOR3& TANGENT = *(LPD3DXVECTOR3)pBuffer;
				const D3DXVECTOR3& NORMAL  = *(LPD3DXVECTOR3)pNormalBuffer;

				D3DXVec3Normalize( &Tangent, &( TANGENT - NORMAL * D3DXVec3Dot(&TANGENT, &NORMAL) ) );

				D3DXVec3Normalize( (D3DXVECTOR3*)pBinormalBuffer, D3DXVec3Cross( (D3DXVECTOR3*)pBinormalBuffer, &Tangent, &NORMAL ) );

				*(LPD3DXVECTOR3)pBuffer = Tangent;

				pBuffer += uTangentStride;
				pNormalBuffer += uNormalStride;
				pBinormalBuffer += uBinormalStride;
			}
		}
		else
		{
			for(i = 0; i < uNumVertices; i ++)
			{
				const D3DXVECTOR3& TANGENT = *(LPD3DXVECTOR3)pBuffer;
				const D3DXVECTOR3& NORMAL  = *(LPD3DXVECTOR3)pNormalBuffer;

				D3DXVec3Normalize( (D3DXVECTOR3*)pBuffer, &( TANGENT - NORMAL * D3DXVec3Dot(&TANGENT, &NORMAL) ) );

				pBuffer += uTangentStride;
				pNormalBuffer += uNormalStride;
			}
		}
	}
	else
	{
		for(i = 0; i < uNumVertices; i ++)
		{
			D3DXVec3Normalize( (D3DXVECTOR3*)pBuffer, (D3DXVECTOR3*)pBuffer );

			pBuffer += uTangentStride;
		}
	}

	return true;
}