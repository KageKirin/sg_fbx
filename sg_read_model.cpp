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

		long MeshType = 0;
		long CinematicMesh = 0;
		long MorphTargetTable = 0;
		long BoneCount = 0;
		long BoneTableOffset = 0;
		long BoneTableOffset2 = 0;
		long BoneTableOffset3 = 0;
		long ModelType = 0;
		long Extra_Mesh_Area = 0;

		BElong BE_MeshType = 0;
		BElong BE_CinematicMesh = 0;
		BElong BE_MorphTargetTable = 0;
		BElong BE_BoneCount = 0;
		BElong BE_BoneTableOffset = 0;
		BElong BE_BoneTableOffset2 = 0;
		BElong BE_BoneTableOffset3 = 0;
		BElong BE_ModelType = 0;
		BElong BE_Extra_Mesh_Area = 0;

		long VertexDataBegin = 0x68;


		file.seekg(0x4);
		MeshType = ReadBE<long, BElong>(file, BE_MeshType);
		printf("MeshType %d", MeshType);

		if(MeshType == 2)
		{
			file.seekg(0x30);
			BoneCount = ReadBE<long, BElong>(file, BE_BoneCount);
			BoneTableOffset = ReadBE<long, BElong>(file, BE_BoneTableOffset);
			BoneTableOffset2 = ReadBE<long, BElong>(file, BE_BoneTableOffset2);
			BoneTableOffset3 = ReadBE<long, BElong>(file, BE_BoneTableOffset3);

			BoneTableOffset += 0x18;
			BoneTableOffset2 += 0x18;
			BoneTableOffset3 += 0x18;
			
			VertexDataBegin = 0x40;
		}
		else if(MeshType == 4)
		{
			file.seekg(0x38);
			BoneCount = ReadBE<long, BElong>(file, BE_BoneCount);
			BoneTableOffset = ReadBE<long, BElong>(file, BE_BoneTableOffset);
			BoneTableOffset2 = ReadBE<long, BElong>(file, BE_BoneTableOffset2);
			BoneTableOffset3 = ReadBE<long, BElong>(file, BE_BoneTableOffset3);

			BoneTableOffset += 0x18;
			BoneTableOffset2 += 0x18;
			BoneTableOffset3 += 0x18;
						
			VertexDataBegin = 0x48;

			file.seekg(0x18);
		}
		else if(MeshType == 5)
		{
			file.seekg(0x20);
			CinematicMesh = ReadBE<long, BElong>(file, BE_CinematicMesh);
			MorphTargetTable = ReadBE<long, BElong>(file, BE_MorphTargetTable);
			BoneCount = ReadBE<long, BElong>(file, BE_BoneCount);
			BoneTableOffset = ReadBE<long, BElong>(file, BE_BoneTableOffset);
			BoneTableOffset2 = ReadBE<long, BElong>(file, BE_BoneTableOffset2);
			BoneTableOffset3 = ReadBE<long, BElong>(file, BE_BoneTableOffset3);

			MorphTargetTable += 0x18;
			BoneTableOffset += 0x18;
			BoneTableOffset2 += 0x18;
			BoneTableOffset3 += 0x18;

			VertexDataBegin = 0x68;
		}
		else if(MeshType == 2005)
		{
			file.seekg(0x28);
			BoneCount = ReadBE<long, BElong>(file, BE_BoneCount);
			BoneTableOffset = ReadBE<long, BElong>(file, BE_BoneTableOffset);
			BoneTableOffset2 = ReadBE<long, BElong>(file, BE_BoneTableOffset2);
			BoneTableOffset3 = ReadBE<long, BElong>(file, BE_BoneTableOffset3);

			BoneTableOffset += 0x18;
			BoneTableOffset2 += 0x18;
			BoneTableOffset3 += 0x18;

			ModelType = ReadBE<long, BElong>(file, ModelType);
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