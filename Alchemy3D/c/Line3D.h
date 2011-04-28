#ifndef LINE3D_H
#define LINE3D_H

#include "Vector3D.h"

typedef struct
{
	Vector3D* pointA;
	Vector3D* pointB;
}Line3D;

Line3D* newLine3D(Vector3D* pointA, Vector3D* pointB)
{
	Line3D* line = (Line3D*)malloc( sizeof(Line3D) );

	if(!line)
		exit(TRUE);

	line->pointA = pointA ? newVector3D(0, 0, 0, 1);
	line->pointB = pointB ? newVector3D(0, 0, 0, 1);
}



#endif