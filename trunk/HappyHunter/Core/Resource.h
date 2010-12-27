#pragma once

#include "GameHost.h"

namespace zerO
{
	class IResource
	{
	public:
		virtual bool Destroy() = 0; 
		// destroy the resource 
		virtual bool Disable() = 0; 
		// purge the resource from volatile memory 
		virtual bool Restore() = 0; 
		// restore the resource to volatile memory 
		virtual bool Load(const PBASICCHAR pcFileName = NULL) = 0; 
		// load the resource from a file (or NULL to use the resource name) 
		virtual bool Save(const PBASICCHAR pcFileName = NULL) = 0; 
		// save the resource to a file (or NULL to use the resource name)
	};

	///
	//��Դ����,����ģʽ,����ΪD3D��Դ,�������̼��뵽��Դ�б���,GameHost�Զ�����.
	///
	class CResource :
		public IResource
	{
	public:
		CResource(RESOURCETYPE Type)
		{
			m_Type   = Type;
			m_Handle = GAMEHOST.AddResource(this, Type);
		}
		~CResource(void)
		{
			GAMEHOST.RemoveResource(this, m_Type);
		}

		inline RESOURCEHANDLE GetHandle()const
		{
			return m_Handle;
		}

		inline bool Destroy() 
		{
			return true;
		}

		inline bool Disable()
		{
			return true;
		}

		inline bool Restore()
		{
			return true;
		}

		inline bool Load(const PBASICCHAR pcFileName = NULL)
		{
			return true;
		}

		inline bool Save(const PBASICCHAR pcFileName = NULL)
		{
			return true;
		}

	private:
		RESOURCEHANDLE m_Handle;
		RESOURCETYPE m_Type;
	};
}
