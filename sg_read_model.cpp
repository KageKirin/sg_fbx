//! sg_read_model.cpp
//!	function(s) for sg .model file reading

#include "stdafx.h"
#include "sg_read_model.h"
#include "sg_structs.h"

#include <iostream>
#include <fstream>
#include <exception>

#include <cassert>
#include <cstdio>

//#define printf;

template<typename type, typename BEtype>
static type EndianSwap(BEtype b)
{
	assert(sizeof(BEtype) == sizeof(type));	//static_assert

	unsigned char* data = (unsigned char*)&b;
	type out = (type)0;
	unsigned char* outdata = (unsigned char*)&out;

	int fullsize = sizeof(BEtype);
	int lastidx = fullsize -1;
	for(int i = 0; i < fullsize; ++i)
	{
		outdata[lastidx - i] = data[i];
	}
	return out;
}

template<typename type, typename BEtype>
static type ReadBE(std::ifstream& fs, BEtype& b)
{
	fs.read((char*)&b, sizeof(BEtype));
	return EndianSwap<type, BEtype>(b);
}

void sg_read_model(const char* filename)
{
	std::ifstream file;

	try
	{
		file.open(filename);

		int FileType = 0;
		int MeshType = 0;
		int CinematicMesh = 0;
		int MorphTargetTable = 0;
		int BoneCount = 0;
		int BoneTableOffset = 0;
		int BoneTableOffset2 = 0;
		int BoneTableOffset3 = 0;
		int ModelType = 0;
		int Extra_Mesh_Area = 0;

		BEint BE_FileType = 0;
		BEint BE_MeshType = 0;
		BEint BE_CinematicMesh = 0;
		BEint BE_MorphTargetTable = 0;
		BEint BE_BoneCount = 0;
		BEint BE_BoneTableOffset = 0;
		BEint BE_BoneTableOffset2 = 0;
		BEint BE_BoneTableOffset3 = 0;
		BEint BE_ModelType = 0;
		BEint BE_Extra_Mesh_Area = 0;

		int VertexDataBegin = 0x68;


		FileType = ReadBE<int, BEint>(file, BE_FileType);
		MeshType = ReadBE<int, BEint>(file, BE_MeshType);
		printf("MeshType %d", MeshType);

		if(MeshType == 2)
		{
			file.seekg(0x30);
			BoneCount = ReadBE<int, BEint>(file, BE_BoneCount);
			BoneTableOffset = ReadBE<int, BEint>(file, BE_BoneTableOffset);
			BoneTableOffset2 = ReadBE<int, BEint>(file, BE_BoneTableOffset2);
			BoneTableOffset3 = ReadBE<int, BEint>(file, BE_BoneTableOffset3);

			BoneTableOffset += 0x18;
			BoneTableOffset2 += 0x18;
			BoneTableOffset3 += 0x18;
			
			VertexDataBegin = 0x40;
		}
		else if(MeshType == 4)
		{
			file.seekg(0x38);
			BoneCount = ReadBE<int, BEint>(file, BE_BoneCount);
			BoneTableOffset = ReadBE<int, BEint>(file, BE_BoneTableOffset);
			BoneTableOffset2 = ReadBE<int, BEint>(file, BE_BoneTableOffset2);
			BoneTableOffset3 = ReadBE<int, BEint>(file, BE_BoneTableOffset3);

			BoneTableOffset += 0x18;
			BoneTableOffset2 += 0x18;
			BoneTableOffset3 += 0x18;
						
			VertexDataBegin = 0x48;

			file.seekg(0x18);
		}
		else if(MeshType == 5)
		{
			file.seekg(0x20);
			CinematicMesh = ReadBE<int, BEint>(file, BE_CinematicMesh);
			MorphTargetTable = ReadBE<int, BEint>(file, BE_MorphTargetTable);
			BoneCount = ReadBE<int, BEint>(file, BE_BoneCount);
			BoneTableOffset = ReadBE<int, BEint>(file, BE_BoneTableOffset);
			BoneTableOffset2 = ReadBE<int, BEint>(file, BE_BoneTableOffset2);
			BoneTableOffset3 = ReadBE<int, BEint>(file, BE_BoneTableOffset3);

			MorphTargetTable += 0x18;
			BoneTableOffset += 0x18;
			BoneTableOffset2 += 0x18;
			BoneTableOffset3 += 0x18;

			VertexDataBegin = 0x68;
		}
		else if(MeshType == 2005)
		{
			file.seekg(0x28);
			BoneCount = ReadBE<int, BEint>(file, BE_BoneCount);
			BoneTableOffset = ReadBE<int, BEint>(file, BE_BoneTableOffset);
			BoneTableOffset2 = ReadBE<int, BEint>(file, BE_BoneTableOffset2);
			BoneTableOffset3 = ReadBE<int, BEint>(file, BE_BoneTableOffset3);

			BoneTableOffset += 0x18;
			BoneTableOffset2 += 0x18;
			BoneTableOffset3 += 0x18;

			ModelType = ReadBE<int, BEint>(file, ModelType);
			VertexDataBegin = 0x68;

			file.seekg(0x44);
		}
		else
		{
			throw std::exception("Unknown format!");
		}
	}
	catch(std::exception ex)
	{
		file.close();
	}
	file.close();
}


///<eof>