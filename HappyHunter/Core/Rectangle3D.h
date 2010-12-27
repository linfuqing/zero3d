#pragma once

#include "Rectangle2D.h"

namespace zerO
{
	///
	// ����ģ����,�������͵ľ��νӿ�.
	///
	template<typename T>
	class CBasicRectangle3D :
		public CBasicRectangle2D<T>
	{
	public:
		CBasicRectangle3D() {}
		CBasicRectangle3D(const CBasicRectangle3D<T>& Rect);
		CBasicRectangle3D(const T& MinX, const T& MaxX, const T& MinY, const T& MaxY, const T& MinZ, const T& MaxZ);

		T GetSizeZ()const;

		T GetMaxZ()const;
		T GetMinZ()const;

		T& GetMaxZ();
		T& GetMinZ();

		void Set(const T& MinX, const T& MaxX, const T& MinY, const T& MaxY, const T& MinZ, const T& MaxZ);


		CBasicRectangle3D<T>& operator  =(const CBasicRectangle3D<T>& Rect);
		CBasicRectangle3D<T>& operator +=(const CBasicRectangle3D<T>& Rect);
		CBasicRectangle3D<T>& operator *=(const CBasicRectangle3D<T>& Rect);

		//�ж������Ƿ��м�ֵ��,�����ֵ������Сֵ����true,����false.
		bool IsValuable()const;

	protected:
		T m_MaxZ;
		T m_MinZ;
	};

	template<typename T>
	inline CBasicRectangle3D<T>::CBasicRectangle3D(const CBasicRectangle3D<T>& Rect)
	{
		m_MaxX = Rect.m_MaxX;
		m_MinX = Rect.m_MinX;
		m_MaxY = Rect.m_MaxY;
		m_MinY = Rect.m_MinY;
		m_MaxZ = Rect.m_MaxZ;
		m_MinZ = Rect.m_MinZ;
	}

	template<typename T>
	inline CBasicRectangle3D<T>::CBasicRectangle3D(const T& MinX, const T& MaxX, const T& MinY, const T& MaxY, const T& MinZ, const T& MaxZ)
	{
		m_MinX = MinX;
		m_MaxX = MaxX;

		m_MinY = MinY;
		m_MaxY = MaxY;

		m_MinZ = MinZ;
		m_MaxZ = MaxZ;
	}

	template<typename T>
	inline T CBasicRectangle3D<T>::GetSizeZ()const
	{
		return m_MaxZ - m_MinZ;
	}

	template<typename T>
	inline T CBasicRectangle3D<T>::GetMaxZ()const
	{
		return m_MaxZ;
	}

	template<typename T>
	inline T CBasicRectangle3D<T>::GetMinZ()const
	{
		return m_MinZ;
	}

	template<typename T>
	inline T& CBasicRectangle3D<T>::GetMaxZ()
	{
		return m_MaxZ;
	}

	template<typename T>
	inline T& CBasicRectangle3D<T>::GetMinZ()
	{
		return m_MinZ;
	}

	template<typename T>
	inline void CBasicRectangle3D<T>::Set(const T& MinX, const T& MaxX, const T& MinY, const T& MaxY, const T& MinZ, const T& MaxZ)
	{
		m_MinX = MinX;
		m_MaxX = MaxX;

		m_MinY = MinY;
		m_MaxY = MaxY;

		m_MinZ = MinZ;
		m_MaxZ = MaxZ;
	}

	template<typename T>
	inline CBasicRectangle3D<T>& CBasicRectangle3D<T>::operator =(const CBasicRectangle3D<T>& Rect)
	{
		m_MaxX = Rect.m_MaxX;
		m_MinX = Rect.m_MinX;
		m_MaxY = Rect.m_MaxY;
		m_MinY = Rect.m_MinY;
		m_MaxZ = Rect.m_MaxZ;
		m_MinZ = Rect.m_MinZ;

		return *this;
	}

	template<typename T>
	inline CBasicRectangle3D<T>& CBasicRectangle3D<T>::operator *=(const CBasicRectangle3D<T>& Rect)
	{
		m_MaxX *= Rect.m_MaxX;
		m_MinX *= Rect.m_MinX;
		m_MaxY *= Rect.m_MaxY;
		m_MinY *= Rect.m_MinY;
		m_MaxZ *= Rect.m_MaxZ;
		m_MinZ *= Rect.m_MinZ;

		return *this;
	}

	template<typename T>
	inline bool CBasicRectangle3D<T>::IsValuable()const
	{
		return m_MaxX >= m_MinX && m_MaxY >= m_MinY && m_MaxZ >= m_MinZ;
	}

	///
	// ����,FLOAT��
	///
	class CRectangle3D :
		public CBasicRectangle3D<FLOAT>
	{
	public:
		typedef enum
		{
			PLANE_NONE      = 0,

			PLANE_FRONT     = 0x01,
			PLANE_BACK      = 0x02,
			PLANE_INTERSECT = 0x04
		}TESTPLANESTATE;
		CRectangle3D(void);
		~CRectangle3D(void);

		FLOAT GetSize()const;
		void GetSize(D3DXVECTOR3& Size)const;
		void GetMin(D3DXVECTOR3& Min)const;
		void GetMax(D3DXVECTOR3& Max)const;

		//ȷ�Ͼ��ΰ���һ����,������չ����֪�������������Ϊֹ.
		void Union(const D3DXVECTOR3& Point);
		void Extract(const D3DXVECTOR3& Point, FLOAT fSize);
		void Transform(const D3DXMATRIX& Matrix);

		//���Ծ�����ƽ���ʲôλ��
		//����:
		//PLANE_FRONT     ��ƽ��ǰ��
		//PLANE_BACK      ��ƽ�汳��
		//PLANE_INTERSECT ��ƽ���ཻ
		TESTPLANESTATE Test(const D3DXPLANE& Plane)const;

		//������������Ƿ���ײ
		bool TestHit(const CRectangle3D& Rect)const;

		CRectangle3D& operator +=(const D3DXVECTOR3& v);
		CRectangle3D& operator *=(const D3DXVECTOR3& v);
	};

	inline FLOAT CRectangle3D::GetSize()const
	{
		D3DXVECTOR3 Size;
		GetSize(Size);

		return D3DXVec3Length(&Size);
	}

	inline void CRectangle3D::GetSize(D3DXVECTOR3& Size)const
	{
		Size.x = GetSizeX();
		Size.y = GetSizeY();
		Size.z = GetSizeZ();
	}

	inline void CRectangle3D::GetMin(D3DXVECTOR3& Min)const
	{
		Min.x = m_MinX;
		Min.y = m_MinY;
		Min.z = m_MinZ;
	}

	inline void CRectangle3D::GetMax(D3DXVECTOR3& Max)const
	{
		Max.x = m_MaxX;
		Max.y = m_MaxY;
		Max.z = m_MaxZ;
	}

	inline void CRectangle3D::Union(const D3DXVECTOR3& Point)
	{
		m_MaxX = MAX(Point.x, m_MaxX);
		m_MaxY = MAX(Point.y, m_MaxY);
		m_MaxZ = MAX(Point.z, m_MaxZ);

		m_MinX = MIN(Point.x, m_MinX);
		m_MinY = MIN(Point.y, m_MinY);
		m_MinZ = MIN(Point.z, m_MinZ);
	}

	inline void CRectangle3D::Extract(const D3DXVECTOR3& Point, FLOAT fSize)
	{
		FLOAT fHalfSize = fSize * 0.5f;

		m_MaxX = Point.x + fHalfSize;
		m_MaxY = Point.y + fHalfSize;
		m_MaxZ = Point.z + fHalfSize;

		m_MinX = Point.x - fHalfSize;
		m_MinY = Point.y - fHalfSize;
		m_MinZ = Point.z - fHalfSize;
	}

	inline bool CRectangle3D::TestHit(const CRectangle3D& Rect)const
	{
		CRectangle3D Result;

		Result.m_MaxX = MIN(Rect.m_MaxX, m_MaxX);
		Result.m_MaxY = MIN(Rect.m_MaxY, m_MaxY);
		Result.m_MaxZ = MIN(Rect.m_MaxZ, m_MaxZ);

		Result.m_MinX = MAX(Rect.m_MinX, m_MinX);
		Result.m_MinY = MAX(Rect.m_MinY, m_MinY);
		Result.m_MinZ = MAX(Rect.m_MinZ, m_MinZ);

		return Result.IsValuable();
	}

	inline CRectangle3D& CRectangle3D::operator +=(const D3DXVECTOR3& v)
	{
		m_MaxX += v.x;
		m_MinX += v.x;
		m_MaxY += v.y;
		m_MinY += v.y;
		m_MaxZ += v.z;
		m_MinZ += v.z;

		return *this;
	}

	inline CRectangle3D& CRectangle3D::operator *=(const D3DXVECTOR3& v)
	{
		m_MaxX *= v.x;
		m_MinX *= v.x;
		m_MaxY *= v.y;
		m_MinY *= v.y;
		m_MaxZ *= v.z;
		m_MinZ *= v.z;

		return *this;
	}
}
