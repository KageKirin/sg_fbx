//! sg_structs.h
//!	structs for sg .model file reading

#ifndef SG_STRUCTS_H
#define SG_STRUCTS_H	1

typedef unsigned short word;

//data is big endian, hence we need to swap bytes
//using BE* to keep track of which variables we need to swap before using
typedef int		BEint;
typedef long	BElong;
typedef float	BEfloat;
typedef word	BEhalf;	//half-precision float, has specific encoding
typedef word	BEword;	//short

//NOTE: 
// MAXscript readlong reads 4 bytes, hence an int
// cf. http://docs.autodesk.com/3DSMAX/15/ENU/MAXScript-Help/index.html?url=files/GUID-9014954D-C25C-45B5-BD9C-19260B852185.htm,topicNumber=d30e16813


typedef void* unknown;	//temp filler so code compiles

struct weight_data
{
	unknown boneids;
	unknown weights;
};

struct VertexDeclarationEntry
{
	unknown DataOffset;
	unknown DataType;
	unknown EntryType;
	unknown SubId;
};

struct BoneDData
{
	unknown BoneID;
	unknown BoneNameOffset;
	unknown BoneName;
	unknown BoneParentID;	
};

#endif	//SG_STRUCTS_H
