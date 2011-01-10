#ifndef D3DUTILS_H
#define D3DUTILS_H

#include "datatype.h"
#include "basicutils.h"

namespace zerO
{
#define TO_DEGREE(x) ( (x) * 180.0f / D3DX_PI )
#define TO_RADIAN(x) ( (x) * D3DX_PI / 180.0f )

	void UpdateSkinnedMesh(    
		const D3DXMATRIX *pBoneTransforms,  
		UINT uNumBones,     
		const void* pVerticesSrc,    
		void* pVerticesDst, 
		UINT uNumTotalVertices,    
		UINT uStride,
		PUINT puNumBoneInfluences, 
		LPDWORD* ppdwVerticesIndices,
		PFLOAT* ppfWeights,
		const D3DXVECTOR3* pTangentSrc = NULL,
		D3DXVECTOR3* pTangentDst = NULL);

	void DirectionToRotation(FLOAT& x, FLOAT& y, const D3DXVECTOR3& Direction);

	void SceneDirectionToRotation(FLOAT& x, FLOAT& y, const D3DXVECTOR3& Direction);

	void QuaternionToEular(D3DXVECTOR3& Eular, const D3DXQUATERNION& Quaternion);

	void MatrixDecompose(D3DXVECTOR3 *pOutScale, D3DXVECTOR3 *pOutRotation, D3DXVECTOR3 *pOutTranslation, const D3DXMATRIX& Matrix);
}

#endif