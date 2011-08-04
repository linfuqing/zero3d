// Test.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"

#include "windows.h"
#include "XML.h"
#include "SyntaxParser.h"

using namespace zerO;

CXML* XMLGetChild(CXML& Child)
{
	CXML XML( TEXT("<perspective>\
            <xfov>45</xfov>\
            <aspect_ratio>1</aspect_ratio>\
            <znear>1</znear><zfar>1000</zfar>\
          </perspective>") );

	return XML.GetChild( Child, TEXT("znear"), TEXT("perspective") );
}

PBASICCHAR XMLGetAttribute(CBasicString& Attribute)
{
	CXML XML( TEXT("<perspective>\
            <xfov>45</xfov>\
            <aspect_ratio>1</aspect_ratio>\
            <znear>1 2 3 4</znear><zfar>1000</zfar>\
          </perspective>"/*"<perspective znear=\"1\"/>"*/) );

	return XML.GetAttribute( Attribute, TEXT("znear") );
}

int _tmain(int argc, _TCHAR* argv[])
{
	CXML Child;
	
	CBasicString Attribute;

	if( XMLGetChild(Child) )
		wprintf((PBASICCHAR)Child);

	wprintf(TEXT("\n"));

	PBASICCHAR pAttribute = XMLGetAttribute(Attribute);

	if(pAttribute)
		wprintf(pAttribute);

	wprintf(TEXT("\n"));

	CBasicString d, t( TEXT("<perspective>\
            <xfov>45</xfov>\
            <aspect_ratio>1</aspect_ratio>\
            <znear>1</znear><zfar>1000</zfar>\
          </perspective>") );
	zerO::UINT uBegin, uEnd;
	CXML::__GetNameSpace(d, t.c_str(), &uBegin, &uEnd );
	wprintf( TEXT("%s, %d, %d, %d"), ( d/* + TEXT('\n')*/ ).c_str(), uBegin, uEnd, t.size() );

	CSyntaxParser Parser;

	CSyntaxParser::MATCHINGSYMBOL Symbol;

	Symbol.Left  = TEXT('\"');
	Symbol.Right = TEXT('\"');
	Parser.Add(Symbol);

	Symbol.Left  = TEXT('{');
	Symbol.Right = TEXT('}');
	Parser.Add(Symbol);

	Symbol.Left  = TEXT('[');
	Symbol.Right = TEXT(']');
	Parser.Add(Symbol);

	BASICCHAR pcText[10];

	while(true)
	{
		wscanf(TEXT("%s"), pcText);

		if(pcText[0] == '0')
			break;

		CSyntaxParser::LPMATCHINGINFO pInfo = NULL;

		bool bValue = Parser.CheckMatchingSymbols((BASICCHAR*)pcText, &pInfo);

		wprintf( bValue ? TEXT("TRUE\n") : TEXT("FALSE\n") );
	}

	return 0;
}

