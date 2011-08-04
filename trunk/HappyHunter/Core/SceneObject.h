#pragma once

namespace zerO
{
	class CSceneObject
	{
	public:
		CSceneObject(void);
		~CSceneObject(void);

		virtual bool Destroy();
		virtual void UpdateBeforeRender();
	};
}
