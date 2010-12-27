#ifndef DEBUG_H
#define DEBUG_H

///
// ������
///
namespace zerO
{
#ifndef DEBUG_ERROR
#define DEBUG_ERROR(sComment)
#endif

#ifndef DEBUG_ASSERT
#define DEBUG_ASSERT(x, sComment) \
		if(!(x))\
		{\
			DEBUG_ERROR(sComment);\
		}
#endif

#ifndef DEBUG_WARNING
#define DEBUG_WARNING(sComment)
#endif

#ifndef DEBUG_WARNING_ASSERT
#define DEBUG_WARNING_ASSERT(x, sComment) \
		if(!(x))\
		{\
			DEBUG_WARNING(sComment);\
		}
#endif

	#ifndef DEBUG_NEW
#define DEBUG_NEW(Param, TypeName) \
	Param = NULL;\
	Param = new TypeName;\
	DEBUG_ASSERT(Param, "Memory full!");
#endif

#ifndef DEBUG_RELEASE
#define DEBUG_RELEASE(Param) \
	if(Param)\
		(Param)->Release();
#endif

#ifndef DEBUG_DELETE
#define DEBUG_DELETE(Param) \
	if(Param)\
		delete (Param);
#endif

#ifndef DEBUG_DELETE_ARRAY
#define DEBUG_DELETE_ARRAY(Param) \
	if(Param)\
		delete [] (Param);
#endif
}

#endif