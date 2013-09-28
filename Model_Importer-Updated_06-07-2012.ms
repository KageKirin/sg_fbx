clearlistener()

mdlScale = 1.0

if (heapSize < 20000000) then
	heapSize = 200000000 -- allow ~ 40 MB instead of just 7.5 MB. Prevents "Runtime Error: Out of scripter memory"

struct weight_data
(
	boneids,weights
)

struct VertexDeclarationEntry
(
	DataOffset, DataType, EntryType, SubId
)

struct BoneDData (
BoneID, BoneNameOffset, BoneName, BoneParentID
)

fn existFile fname = (getfiles fname).count != 0

fn PrintOffset Var =
(
	local Var = Var
print ("This is the offset 0x" + (bit.intAsHex Var) as string)
	Var
)
y = 180
PrintOffset y
x = 200
print ("This is the number 0x" + (bit.intAsHex x) as string)

fn floatSwap2 f = 
(
	i = bit.floatAsInt f
	h = bit.intashex i
	while h.count < 8 do h = "0" + h
	
	s = (substring h 7 2) + (substring h 5 2) + (substring h 3 2) + (substring h 1 2)
	bit.intAsFloat (bit.hexasint s)
)	

fn ReadBEword fstream = (
return (bit.swapBytes (readshort fstream #unsigned) 1 2)
)

 fn ReadBEHalfFloat Fstream = (
  local BH  = readByte Fstream #unsigned
  local BL  = readByte Fstream #unsigned
  local N = BH*256 + BL
  local S = floor((mod N 65536) / 32768)
  local Ef = floor((mod N 32768) / 1024)
  local M = mod N 1024
  if (Ef==0)AND(M==0) then return ( (-1.0)^S * 0.0 )
  if (Ef==0)AND(M!=0) then return ( (-1.0)^S * 2.0^-14 * (M / 2.0^10) )
  if (Ef>0)AND(Ef<31) then return ( (-1.0)^S * 2.0^(Ef-15) * (1 + M/2.0^10) )
  if (Ef==31)AND(M==0) then return ( (-1.0)^S * 1/0.0 )
  if (Ef==31)AND(M!=0) then return 0	--hack-- should be #inf   
 )--end fn ReadBEHalfFloat

fn ReadBElong fstream = (
long = readlong fstream
long = bit.swapBytes long 1 4
long = bit.swapBytes long 2 3
return long
)

fn ImportTextureGenerations mm index texfilename filepath = (
	matdata = fopen (filepath + texfilename + ".material") "rb"
	
	fseek matdata 0x04 #seek_set
	texcount = ReadBElong matdata	
	
	fseek matdata 0x24 #seek_set
	--PrintOffset (ftell matdata)
	DataBegin = ReadBElong matdata	
	fseek matdata (DataBegin + 0x18) #seek_set
	--PrintOffset (ftell matdata)
	DataBegin2 = ReadBElong matdata	
	fseek matdata (DataBegin2 + 0x18) #seek_set
	--PrintOffset (ftell matdata)
	TexBegin = ReadBElong matdata	
	fseek matdata (TexBegin + 0x18) #seek_set
	--PrintOffset (ftell matdata)
	
	--mat = standardMaterial()
	mat = mm.materialList[index]
	mat.name = texfilename
	mat.showinviewport = true
	mat.twosided = false
	
	--print("Material has " + (texcount as string) + " maps!")
	
	for i = 1 to texcount do (
		
		ddsfile = readstring matdata		
		ddsdata = readstring matdata

		--print("Map " + (i as string) + " is " + ddsdata + " map: " + (ddsfile) + ".dds")
		
		pos = ftell matdata
		pos = pos + 0x0C
		ex = mod pos 4
		
		if(ex != 0) then (
			pos = pos + (4 - ex)
		)
		
		fseek matdata pos #seek_set
		
		--print ddsdata
		tm = Bitmaptexture filename:(filepath + ddsfile + ".dds")
		tm.alphasource = 2
		case ddsdata of
		(
			"diffuse": mat.diffuseMap = tm
			"displacement": (
				mat.bumpMap = tm
				mat.bumpMapAmount = 40
			)
			"normal": (
				mat.bumpMap = tm
				mat.bumpMapAmount = 40
			)
			"specular": mat.specularMap = tm
			"gloss": mat.specularMap = tm
			"reflection": mat.reflectionMap = tm
			default: ( )
		)
	)
	
	fclose matdata
	
	--msh.material = mat	
)


fn ImportTexture mm index texfilename filepath = (
	if(not existFile(filepath + texfilename + ".texset")) then (
		ImportTextureGenerations mm index texfilename filepath		
		return true
	)
	texdesc = fopen (filepath + texfilename + ".texset") "rb"
	
	fseek texdesc 0x18 #seek_set
	texcount = ReadBElong texdesc
	
	textfiles = #()
	fseek texdesc (0x20 + texcount * 4) #seek_set
	for i = 1 to texcount do (
		textfiles[i] = readstring texdesc
		--print (textfiles[i])
	)
	
	fclose texdesc
	
	mat = mm.materialList[index]
	mat.name = texfilename
	mat.showinviewport = true
	mat.twosided = false
	
	for i = 1 to texcount do (
		mapdata = fopen (filepath + textfiles[i] + ".texture") "rb"
		fseek mapdata 0x24 #seek_set
		ddsfile = readstring mapdata
		ddsdata = readstring mapdata
		
		fclose mapdata
		
		--print ddsdata
		tm = Bitmaptexture filename:(filepath + ddsfile + ".dds")
		tm.alphasource = 2
		case ddsdata of
		(
			"diffuse": mat.diffuseMap = tm
			"displacement": (
				mat.bumpMap = tm
				mat.bumpMapAmount = 40
			)
			"normal": (
				mat.bumpMap = tm
				mat.bumpMapAmount = 40
			)
			"specular": mat.specularMap = tm
			"gloss": mat.specularMap = tm
			"reflection": mat.reflectionMap = tm
			default: ( )
		)
	)
	--msh.material = mat
)

fn ImportTextureGenerationsMesh msh texfilename filepath = (
	matdata = fopen (filepath + texfilename + ".material") "rb"
	
	fseek matdata 0x04 #seek_set
	texcount = ReadBElong matdata	
	
	fseek matdata 0x24 #seek_set
	--PrintOffset (ftell matdata)
	DataBegin = ReadBElong matdata	
	fseek matdata (DataBegin + 0x18) #seek_set
	--PrintOffset (ftell matdata)
	DataBegin2 = ReadBElong matdata	
	fseek matdata (DataBegin2 + 0x18) #seek_set
	--PrintOffset (ftell matdata)
	TexBegin = ReadBElong matdata	
	fseek matdata (TexBegin + 0x18) #seek_set
	--PrintOffset (ftell matdata)
	
	mat = standardMaterial()
	mat.showinviewport = true
	mat.twosided = false
	
	--print("Material has " + (texcount as string) + " maps!")
	
	for i = 1 to texcount do (
		
		ddsfile = readstring matdata		
		ddsdata = readstring matdata

		--print("Map " + (i as string) + " is " + ddsdata + " map: " + (ddsfile) + ".dds")
		
		pos = ftell matdata
		pos = pos + 0x0C
		ex = mod pos 4
		
		if(ex != 0) then (
			pos = pos + (4 - ex)
		)
		
		fseek matdata pos #seek_set
		
		--print ddsdata
		tm = Bitmaptexture filename:(filepath + ddsfile + ".dds")
		tm.alphasource = 2
		case ddsdata of
		(
			"diffuse": mat.diffuseMap = tm
			"displacement": (
				mat.bumpMap = tm
				mat.bumpMapAmount = 40
			)
			"normal": (
				mat.bumpMap = tm
				mat.bumpMapAmount = 40
			)
			"specular": mat.specularMap = tm
			"gloss": mat.specularMap = tm
			"reflection": mat.reflectionMap = tm
			default: ( )
		)
	)
	
	fclose matdata
	
	msh.material = mat	
)


fn ImportTextureMesh msh texfilename filepath = (
	if(not existFile(filepath + texfilename + ".texset")) then (
		ImportTextureGenerationsMesh msh texfilename filepath		
		return true
	)
	texdesc = fopen (filepath + texfilename + ".texset") "rb"
	
	fseek texdesc 0x18 #seek_set
	texcount = ReadBElong texdesc
	
	textfiles = #()
	fseek texdesc (0x20 + texcount * 4) #seek_set
	for i = 1 to texcount do (
		textfiles[i] = readstring texdesc
		--print (textfiles[i])
	)
	
	fclose texdesc
	
	mat = StandardMaterial()
	mat.showinviewport = true
	mat.twosided = false
	
	for i = 1 to texcount do (
		mapdata = fopen (filepath + textfiles[i] + ".texture") "rb"
		fseek mapdata 0x24 #seek_set
		ddsfile = readstring mapdata
		ddsdata = readstring mapdata
		
		fclose mapdata
		
		--print ddsdata
		tm = Bitmaptexture filename:(filepath + ddsfile + ".dds")
		tm.alphasource = 2
		case ddsdata of
		(
			"diffuse": mat.diffuseMap = tm
			"displacement": (
				mat.bumpMap = tm
				mat.bumpMapAmount = 40
			)
			"normal": (
				mat.bumpMap = tm
				mat.bumpMapAmount = 40
			)
			"specular": mat.specularMap = tm
			"gloss": mat.specularMap = tm
			"reflection": mat.reflectionMap = tm
			default: ( )
		)
	)
	msh.material = mat
)

fn ReadBEfloat fstream = (
return floatSwap2(readfloat fstream)
)

fname = GetOpenFileName caption:"Open Sonic Model File" types:"Sonic Model File(*.model)|*.model"
if (fname!=undefined) and ((doesFileExist fname)==true) then (

f = fopen fname "rb"   --open file in read only format
filepath = GetFilenamePath fname

fseek f 0x04 #seek_set
MeshType = ReadBElong f

CinematicMesh = 0
MorphTargetTable = 0
BoneCount = 0
BoneTableOffset = 0
BoneTableOffset2 = 0
BoneTableOffset3 = 0
ModelType = 0
Extra_Mesh_Area = #()
VertexDataBegin = 0x68

if(MeshType == 2) Then (
 print "MeshType 2"
 fseek f 0x30 #seek_set
 BoneCount = ReadBElong f
 BoneTableOffset = ReadBElong f + 0x18
 BoneTableOffset2 = ReadBElong f + 0x18
 BoneTableOffset3 = ReadBElong f + 0x18
 VertexDataBegin = 0x40
	
 fseek f 0x18 #seek_set
)
else if(MeshType == 4) Then (
 print "MeshType 4"
 fseek f 0x38 #seek_set
 BoneCount = ReadBElong f
 BoneTableOffset = ReadBElong f + 0x18
 BoneTableOffset2 = ReadBElong f + 0x18
 BoneTableOffset3 = ReadBElong f + 0x18
 VertexDataBegin = 0x48
 
 fseek f 0x18 #seek_set
) else if(MeshType == 5) Then (
 print "MeshType 5"
 fseek f 0x20 #seek_set
 CinematicMesh = ReadBElong f
 MorphTargetTable = ReadBElong f + 0x18
 BoneCount = ReadBElong f
 BoneTableOffset = ReadBElong f + 0x18
 BoneTableOffset2 = ReadBElong f + 0x18
 BoneTableOffset3 = ReadBElong f + 0x18
 ModelType = ReadBElong f
 VertexDataBegin = 0x68
) else if(MeshType == 2005) Then (
 print "MeshType 2005"
 fseek f 0x28 #seek_set
 BoneCount = ReadBElong f
 BoneTableOffset = ReadBElong f + 0x18
 BoneTableOffset2 = ReadBElong f + 0x18
 BoneTableOffset3 = ReadBElong f + 0x18
 ModelType = ReadBElong f
 VertexDataBegin = 0x68
 
 fseek f 0x44 #seek_set
)
else (
 throw "Unknown format!"
 fclose f
)

MeshDataOffset = 0
if(ModelType > 0x34) then (
	MeshDataOffset = (ModelType - 0x34)
	MeshDataOffset = MeshDataOffset - (mod MeshDataOffset 4)
)

ExtraMeshAreaCount =  MeshDataOffset / 4
 for i = 1 to ExtraMeshAreaCount Do (
	append Extra_Mesh_Area (ReadBELong f + 0x18)
)


BeforeExtra = ftell f
ExtraMeshCount = 0
Extra_Meshes = #()
for i = 1 to ExtraMeshAreaCount Do (
	fseek f Extra_Mesh_Area[i] #seek_set
	ThisAreaExtra = (ReadBELong f)
	ExtraMeshCount = ExtraMeshCount + ThisAreaExtra
	ThisAreaHead = ReadBELong f + 0x18
	for j = 1 To ThisAreaExtra Do (
		append Extra_Meshes (ThisAreaHead + (j-1) * 4)		
	)
)
fseek f BeforeExtra #seek_set

MeshCount = ReadBElong f
UnkCount2 = ReadBElong f
AddMeshCount = ReadBElong f
AddMeshBegin =ReadBElong f + 0x18
ExtraMeshCount = ExtraMeshCount + AddMeshCount
for i = 1 to AddMeshCount Do (
	append Extra_Meshes (AddMeshBegin + (i-1) * 4)	
)
AlphaMeshCount = ReadBElong f
AlphaMeshBegin = ReadBElong f + 0x18
ExtraMeshCount = ExtraMeshCount + AlphaMeshCount
for i = 1 to AlphaMeshCount Do (
	append Extra_Meshes (AlphaMeshBegin + (i-1) * 4)	
)

fseek f BoneTableOffset#seek_set
struct BoneOffset (
BoneTOffset
)
Bone_Offset_array = #()
for i = 1 to BoneCount Do (
BoneTOffset = ReadBElong f + 0x18
append Bone_Offset_array (BoneOffset BoneTOffset:BoneTOffset)
)
print Bone_Offset_array

Bone_Data_array = #()
BoneID = -1
for k in Bone_Offset_array Do (
fseek f k.BoneTOffset#seek_set
BoneID += 1
BoneParentID = ReadBElong f
BoneNameOffset = ReadBElong f
BoneName = readstring f
append Bone_Data_array ( BoneDData BoneID:BoneID BoneNameOffset:BoneNameOffset BoneName:BoneName BoneParentID:BoneParentID )
)
print Bone_Data_array
fseek f BoneTableOffset2 #seek_set
--if CinematicMesh == 1 Do (
--fseek f 0x1#seek_cur
--)
BNArr = #()

enableSceneRedraw()
--disableSceneRedraw()

Bone_root_array = #()
for i = 1 to BoneCount Do (
m11 = ReadBEfloat f; m12 = ReadBEfloat f; m13 = ReadBEfloat f; m14 = ReadBEfloat f
m21 = ReadBEfloat f; m22 = ReadBEfloat f; m23 = ReadBEfloat f; m24 = ReadBEfloat f
m31 = ReadBEfloat f; m32 = ReadBEfloat f; m33 = ReadBEfloat f; m34 = ReadBEfloat f
m41 = ReadBEfloat f; m42 = ReadBEfloat f; m43 = ReadBEfloat f; m44 = ReadBEfloat f
tfm = matrix3 [m11,m12,m13] [m21,m22,m23] [m31,m32,m33] [m41,m42,m43]
	
newBone = bonesys.createbone	\
				  tfm.row4	\
				  (tfm.row4 + 0.01 * (normalize tfm.row1)) \
				  (normalize tfm.row3)
			newBone.name   = Bone_Data_array[i].BoneName

  		    newBone.width  = 0.01
			newBone.height = 0.01
			newBone.transform = tfm

			pos = (-1) * [m14,m24,m34]
			pos = pos * tfm
 
			--if(newbone.name == "Brow1_L") then
						  --newBone.pos = [0.045,0.84,0.148]			
			--else if(newbone.name == "Brow2_L") then
							--newBone.pos = [0.096,0.911,0.108]
			--else if(newbone.name == "Brow3_L") then
							--newBone.pos = [0.138,0.854,0.05]
			--else if(newbone.name == "Brow_C") then
							--newBone.pos = [0.0, 0.8, 0.05]
					  --else
					  --(
						newBone.pos.x = pos.x * mdlScale
						newBone.pos.y = pos.z * (-1) * mdlScale
						newBone.pos.z = pos.y * mdlScale
					  --)

			newBone.setBoneEnable false 0
			newBone.pos.controller      = TCB_position ()
			newBone.rotation.controller = TCB_rotation ()

			
			if (Bone_Data_array[i].BoneParentID != -1) then
					  newBone.parent = BNArr[Bone_Data_array[i].BoneParentID+1]

			BNArr[i] = newBone
			if i == 1 do (
				append Bone_root_array newBone
			)
			
				  )
MorphArr = #()
MorphArr2 = #()
Morph_Face_array = #()
Morph_Name_array = #()

print "Bones done"
				  
if CinematicMesh == 1 Then (
fseek f MorphTargetTable #seek_set

print "Cinematic mesh"
PrintOffset (ftell f)

MorphVertCountOffset = ReadBElong f	+ 0x18
MorphVertCount = ReadBElong f	
MorphTableEnd = ReadBElong f + 0x18
MorphUnkCount1 = ReadBElong f
MorphCount = ReadBElong f
MorphTableStart = ReadBElong f + 0x18
MorphTableNameStart = ReadBElong f + 0x18
MorphFaceSetsCount = ReadBElong f
MorphFaceTableStart = ReadBElong f + 0x18
Null = readlong f
MorphFaceTableEnd = ReadBElong f + 0x18
Texture = ""
	
Bone_ids1 = #()

fseek f MorphFaceTableStart#seek_set
PrintOffset (ftell f)
MorphFaceSets = #()
MorphVertSize = 0x68
DataTable = #()

for i = 1 to MorphFaceSetsCount Do
(
	FaceSetStart = ReadBElong f	+ 0x18
	append MorphFaceSets FaceSetStart
)

for i = 1 to MorphFaceSetsCount Do
(
fseek f MorphFaceSets[i] #seek_set
PrintOffset (ftell f)
TextureOffset = ReadBElong f	+ 0x18
MorphFaceCount = ReadBElong f
MorphFaceOffset = ReadBElong f + 0x18
--ReadBElong f
--MorphVertSize = ReadBElong f
--MorphDataTable = ReadBElong f + 0x18
if ( i == 1) then
(
	BackJump = ftell f
	fseek f TextureOffset #seek_set
	Texture = readstring f	
	fseek f BackJump #seek_set
	
	fseek f 0x10 #seek_cur
	boneidcount = ReadBElong f
	boneidstart = (ReadBElong f) + 0x18
			
	fseek f boneidstart #seek_set
	for j=1 to boneidcount do
	(
		addboneid = (ReadByte f #unsigned)
		append Bone_ids1 (addboneid + 1)
	)
)

--Read data table
/*
CoordinatesFound = false
UVDataFound = false
BoneIndicesFound = false
BoneWeightsFound = false
DataTableEnd = false
fseek f MorphDataTable #seek_set
PrintOffset(MorphDataTable)
while(not DataTableEnd) do (
	DataOffset = ReadBElong f
	DataType = ReadBElong f
	EntryType = ReadBEword f
	SubId = ReadByte f
	Padding = ReadByte f
	
	if(DataType != -1) then (
		append DataTable (VertexDeclarationEntry DataOffset: DataOffset DataType: DataType EntryType: EntryType SubId: SubId)
		if(EntryType == 0) then CoordinatesFound = true
		if(EntryType == 1) then BoneWeightsFound = true
		if(EntryType == 2) then BoneIndicesFound = true
		if(EntryType == 5) then UVDataFound = true
	) else (
		DataTableEnd = true
	)
)
if((not CoordinatesFound) or (not BoneWeightsFound) or (not BoneIndicesFound) or (not UVDataFound)) then (
	throw "NOOOOO!"
)*/

fseek f MorphFaceOffset#seek_set
StartDirection = 1
f1 = (ReadBEword f) + 1
f2 = (ReadBEword f) + 1  
FaceDirection = StartDirection
Do (
f3 = (ReadBEword f)
if (f3==0xFFFF) then (
f1 = (ReadBEword f) + 1
f2 = (ReadBEword f) + 1
FaceDirection = StartDirection 
) else (
f3 += 1
FaceDirection *= -1
if (f1!=f2)AND(f2!=f3)AND(f3!=f1) then (
if FaceDirection > 0 then append Morph_Face_array [f1,f2,f3]
else append Morph_Face_array [f1,f3,f2]
)
f1 = f2
f2 = f3
) 
) while ((ftell f) != (MorphFaceOffset + (MorphFaceCount * 2)))
)

fseek f MorphTableEnd #seek_set

Vert_array1 = #() --define arrays for verts, normals, UV and Faces
--Normal_array1 = #()
UV_array1 = #()
Weight_array1 = #()



for k = 1 to MorphVertCount Do (
--Ignoring data table for speed reasons!
vx = ReadBEfloat f  --read xyz coordinates
vy = ReadBEfloat f
vz = ReadBEfloat f
fseek f 0x24#seek_cur
tu = ReadBEFloat f   --read UV float value
tv = ReadBEFloat f * -1
fseek f 0x28#seek_cur

bone1 = readbyte f#unsigned
bone2 = readbyte f#unsigned
bone3 = readbyte f#unsigned
bone4 = readbyte f#unsigned
weight1 = readbyte f#unsigned
weight2 = readbyte f#unsigned
weight3 = readbyte f#unsigned
weight4 = readbyte f#unsigned

w = (weight_data boneids:#() weights:#())

maxweight = 0
	
if(bone1 != 0xFF) then
	maxweight = maxweight + weight1
if(bone2 != 0xFF) then
	maxweight = maxweight + weight2
if(bone3 != 0xFF) then
	maxweight = maxweight + weight3
if(bone4 != 0xFF) then
	maxweight = maxweight + weight4

if(maxweight != 0) then
	(
		mxw = 255.0
		if(bone1 != 0xFF) then
		(
			w1 = weight1 as float
			append w.boneids (Bone_ids1[bone1+1])
			append w.weights (w1 / mxw)
		)
		if(bone2 != 0xFF) then
		(
			w2 = weight2 as float
			append w.boneids (Bone_ids1[bone2+1])
			append w.weights (w2 / mxw)
		)
		if(bone3 != 0xFF) then
		(
			w3 = weight3 as float
			append w.boneids (Bone_ids1[bone3+1])
			append w.weights (w3 / mxw)
		)
		if(bone4 != 0xFF) then
		(
			w4 = weight4 as float
			append w.boneids (Bone_ids1[bone4+1])
			append w.weights (w4 / mxw)
		)		
	)

append Vert_array1 [vx*mdlScale,(-1)*vz*mdlScale,vy*mdlScale]
append UV_array1 [tu,tv,0]  --save UVs to UV_array
append Weight_array1 w
)
msh = mesh vertices:Vert_array1 faces:Morph_Face_array --build mesh
msh.numTVerts = UV_array1.count
buildTVFaces msh
ImportTextureMesh msh Texture filepath
msh.name =  "Mouth"
for j = 1 to UV_array1.count do setTVert msh j UV_array1[j]
for j = 1 to Morph_Face_array.count do setTVFace msh j Morph_Face_array[j]
--for j = 1 to Normal_array1.count do setNormal msh j Normal_array1[j]
select $Mouth
MorphMod = morpher ()
addModifier $Mouth MorphMod
$Mouth.morpher.Autoload_of_targets = 1
--$Mouth.parent = $Neck

fseek f MorphTableStart#seek_set
for i = 1 to MorphCount Do (
append MorphArr (ReadBElong f + 0x18)
)
for i = 1 to MorphCount Do (
append MorphArr2 (ReadBElong f + 0x18)
)	
for i = 1 to MorphCount Do (
fseek f MorphArr[i]#seek_set
MorphName = readstring f
fseek f MorphArr2[i]#seek_set
Morph_Vert_array = #()
Morph_UV_array = #()
--Morph_Normal_array = #()
for k = 1 to MorphVertCount Do (
vx = ((ReadBEfloat f) ) + Vert_array1[k].x / mdlScale
vy = ((ReadBEfloat f) ) + Vert_array1[k].z / mdlScale
vz = ((ReadBEfloat f) ) + (-1) * Vert_array1[k].y / mdlScale
append Morph_Vert_array [vx * mdlScale,-vz * mdlScale,vy * mdlScale]
)

msh = mesh vertices:Morph_Vert_array faces:Morph_Face_array   --build mesh
msh.numTVerts = UV_array1.count
buildTVFaces msh
msh.name =  MorphName
for j = 1 to UV_array1.count  do setTVert msh j UV_array1[j]
for j = 1 to Morph_Face_array.count  do setTVFace msh j Morph_Face_array[j]
--for j = 1 to Morph_Normal_array.count do setNormal msh j Morph_Normal_array[j]
append Morph_Name_array msh
)

max modify mode
select $mouth
skinMod = skin ()
addModifier $mouth skinMod
for i = 1 to BNArr.count do
(
	maxbone = getnodebyname BNArr[i].name
	if i != BNArr.count then
		skinOps.addBone skinMod maxbone 0
	else
		skinOps.addBone skinMod maxbone 1
	
)
modPanel.setCurrentObject skinMod

for i = 1 to Weight_array1.count do
(
	w = Weight_array1[i]
	bi = #() --bone index array
	wv = #() --weight value array
	
	for j = 1 to w.boneids.count do
	(
		boneid = w.boneids[j]
		weight = w.weights[j]
		append bi boneid
		append wv weight
	)	
	
	skinOps.ReplaceVertexWeights skinMod i bi wv
)

vwld = Vertex_Weld()
vwld.enabledInRenders = true
vwld.enabledInViews = false
vwld.threshold = 0.002
addModifier $mouth vwld

max create mode

)
for b = 1 to Morph_Name_array.count Do (
	WM3_MC_BuildFromNode $Mouth.morpher b Morph_Name_array[b]
	hide Morph_Name_array[b]
)


All_Vert_array = #()
All_UV_array = #()
All_Mat_Face_array = #()
All_Face_array = #()
All_Weight_array = #()
AllVertexCount = 0
MultiMat = MultiMaterial()
MultiMat.numsubs = MeshCount+ExtraMeshCount

if(MeshType == 5) Then 
 fseek f (VertexDataBegin + MeshDataOffset) #seek_set
else
 fseek f VertexDataBegin #seek_set

for c = 1 to MeshCount+ExtraMeshCount Do (
	
	CExtra = false
	if(c > MeshCount) then (
		--Extra mesh!
		CExtra = true
		extraIndex = c - MeshCount
		fseek f (Extra_Meshes[extraIndex]) #seek_set		
		print("Extra Mesh " + (extraIndex as string))
	)
	
--print ("Mesh: " + c as string)
--PrintOffset (ftell f)

	Vert_array = #()
	Normal_array = #()
	UV_array = #()
	Face_array = #()
	Weight_array = #()
	BoneID_array = #()
	
offsetstart = (ReadBElong f) + 0x18
tablestart = ftell f
	fseek f offsetstart#seek_set

PrintOffset (ftell f)

TextureOffset = ReadBElong f + 0x18

BackJump = ftell f

fseek f TextureOffset #seek_set
Texture = readstring f
--print (Texture)
fseek f BackJump #seek_set

FaceCount = ReadBElong f	
FaceStart = ReadBElong f 	+ 0x18
VertCount = ReadBElong f	
VertSize = ReadBElong f	
VertStart = ReadBElong f + 0x18
DataTableStart = ReadBElong f + 0x18
SecBoneCount = ReadBElong f	
SecBoneIDs = (ReadBElong f) + 0x18

BackJump = ftell f
	
fseek f SecBoneIDs #seek_set
for i = 1 to SecBoneCount do
(
	addboneid = (ReadByte f #unsigned)
	append BoneID_array (addboneid + 1)
)
	
fseek f BackJump #seek_set
	
Count10 = ReadBElong f	
Count11 = ReadBElong f	
FaceStart = ftell f	
VerStart = (FaceCount * 2) + FaceStart

--Read data table
BackJump = ftell f
CoordinatesFound = false
UVDataFound = false
BoneIndicesFound = false
BoneWeightsFound = false
DataTableEnd = false
DataTable = #()
fseek f DataTableStart #seek_set
while(not DataTableEnd) do (
	DataOffset = ReadBElong f
	DataType = ReadBElong f
	EntryType = ReadBEword f
	SubId = ReadByte f
	Padding = ReadByte f
	
	if(DataType != -1) then (
		append DataTable (VertexDeclarationEntry DataOffset: DataOffset DataType: DataType EntryType: EntryType SubId: SubId)
		if(EntryType == 0) then CoordinatesFound = true
		if(EntryType == 1) then BoneWeightsFound = true
		if(EntryType == 2) then BoneIndicesFound = true
		if(EntryType == 5) then UVDataFound = true
	) else (
		DataTableEnd = true
	)
)
if((not CoordinatesFound) or (not BoneWeightsFound) or (not BoneIndicesFound) or (not UVDataFound)) then (
	throw "NOOOOO!"
)

fseek f BackJump #seek_set
--end read data table

StartDirection = 1
f1 = (ReadBEword f) + 1
f2 = (ReadBEword f) + 1  
FaceDirection = StartDirection
Do (
f3 = (ReadBEword f)
if (f3==0xFFFF) then (
f1 = (ReadBEword f) + 1
f2 = (ReadBEword f) + 1
FaceDirection = StartDirection 
) else (
f3 += 1
FaceDirection *= -1
if (f1!=f2)AND(f2!=f3)AND(f3!=f1) then (
if FaceDirection > 0 then append Face_array [f1,f2,f3]
else append Face_array [f1,f3,f2]
)
f1 = f2
f2 = f3
) 
) while ((ftell f) != (VerStart))
fseek f VerStart#seek_set
 test = readshort f
 if test != 0x0000 Do (
         fseek f -2 #seek_cur
)
fseek f VertStart#seek_set
	
for v = 1 to VertCount Do (
	vx = 0
	vy = 0
	vz = 0
	tu = 0
	tv = 0
	bone1 = 0xFF
	bone2 = 0xFF
	bone3 = 0xFF
	bone4 = 0xFF
	weight1 = 0
	weight2 = 0
	weight3 = 0
	weight4 = 0
	
	UVSubZeroFound = false
	UVFound = false
	VertexDataStart = ftell f
	for x = 1 to DataTable.count Do (
		Entry = DataTable[x]
		fseek f Entry.DataOffset #seek_cur
		if(Entry.EntryType == 0) Then (
			vx = ReadBEfloat f
			vy = ReadBEfloat f
			vz = ReadBEfloat f
		)
		if(Entry.EntryType == 1) Then (
			weight1 = readbyte f#unsigned
			weight2 = readbyte f#unsigned
			weight3 = readbyte f#unsigned
			weight4 = readbyte f#unsigned
		)
		if(Entry.EntryType == 2) Then (
			bone1 = readbyte f#unsigned
			bone2 = readbyte f#unsigned
			bone3 = readbyte f#unsigned
			bone4 = readbyte f#unsigned			
		)
		if(Entry.EntryType == 5) Then (
			SubId = Entry.SubId
			ReadThisUV = (not UVFound) or (not UVSubZeroFound and SubId == 0)
			if(ReadThisUV) then (
				UVFound = true
				if(SubId == 0) then
					UVSubZeroFound = true
				
				if(Entry.DataType == 2892709) then (
					tu = ReadBEfloat f
					tv = ReadBEfloat f
				) else (
					tu = ReadBEHalfFloat f
					tv = ReadBEHalfFloat f
				)
				tv = tv * (-1)
			)
		)
		fseek f VertexDataStart #seek_set
	)
fseek f VertSize #seek_cur

w = (weight_data boneids:#() weights:#())

maxweight = 0
if(bone1 != 0xFF) then
	maxweight = maxweight + weight1
if(bone2 != 0xFF) then
	maxweight = maxweight + weight2
if(bone3 != 0xFF) then
	maxweight = maxweight + weight3
if(bone4 != 0xFF) then
	maxweight = maxweight + weight4

if(maxweight != 0) then
	(
		mxw = 255.0
		if(bone1 != 0xFF) then
		(
			w1 = weight1 as float
			append w.boneids (BoneID_array[bone1+1])
			append w.weights (w1 / mxw)
		)
		if(bone2 != 0xFF) then
		(
			w2 = weight2 as float
			append w.boneids (BoneID_array[bone2+1])
			append w.weights (w2 / mxw)
		)
		if(bone3 != 0xFF) then
		(
			w3 = weight3 as float
			append w.boneids (BoneID_array[bone3+1])
			append w.weights (w3 / mxw)
		)
		if(bone4 != 0xFF) then
		(
			w4 = weight4 as float
			append w.boneids (BoneID_array[bone4+1])
			append w.weights (w4 / mxw)
		)		
	)

append Vert_array [vx * mdlScale,(-1)*vz * mdlScale,vy * mdlScale] --save verts to Vert_array
--append Normal_array [nx,ny,nz] --save normals to Normal_array
append UV_array [tu,tv,0]  --save UVs to UV_array
append Weight_array w

)
fseek f tablestart#seek_set

for i = 1 to Face_array.count do (
	vertices = Face_array[i]
	append All_Face_array [vertices[1] + AllVertexCount, vertices[2] + AllVertexCount, vertices[3] + AllVertexCount]
	append All_Mat_Face_array c
)

AllVertexCount = AllVertexCount + Vert_array.count

for i = 1 to Vert_array.count do (
	append All_Vert_array vert_array[i]
	append All_UV_array UV_array[i]
	append All_Weight_array Weight_array[i]
)

importTexture MultiMat c Texture filepath

/*msh = mesh vertices:Vert_array faces:Face_array --build mesh
msh.numTVerts = UV_array.count

importTexture msh Texture filepath

buildTVFaces msh    
for j = 1 to UV_array.count do setTVert msh j UV_array[j]
for j = 1 to Face_array.count do setTVFace msh j Face_array[j]
--for j = 1 to Normal_array.count do setNormal msh j Normal_array[j]

max modify mode
select msh
skinMod = skin ()
addModifier msh skinMod
for i = 1 to BNArr.count do
(
	maxbone = getnodebyname BNArr[i].name
	if i != BNArr.count then
		skinOps.addBone skinMod maxbone 0
	else
		skinOps.addBone skinMod maxbone 1
	
)

modPanel.setCurrentObject skinMod

for i = 1 to Weight_array.count do
(
	w = Weight_array[i]
	bi = #() --bone index array
	wv = #() --weight value array
	
	for j = 1 to w.boneids.count do
	(
		boneid = w.boneids[j]
		weight = w.weights[j]
		append bi boneid
		append wv weight
	)	
	
	skinOps.ReplaceVertexWeights skinMod i bi wv
)


max create mode*/

)

max create mode

msh = mesh vertices:All_Vert_array faces:All_Face_array --build mesh
msh.numTVerts = All_UV_array.count
if (BNArr.count >= 1) then msh.name = BNArr[1].name

buildTVFaces msh    
for j = 1 to All_UV_array.count do setTVert msh j All_UV_array[j]
for j = 1 to All_Face_array.count do (	
	setTVFace msh j All_Face_array[j]
	setFaceMatID msh j All_Mat_Face_array[j]
)

max modify mode

select msh
skinMod = skin ()
addModifier msh skinMod
for i = 1 to BNArr.count do
(
	maxbone = getnodebyname BNArr[i].name
	if i != BNArr.count then
		skinOps.addBone skinMod maxbone 0
	else
		skinOps.addBone skinMod maxbone 1
	
)

modPanel.setCurrentObject skinMod

for i = 1 to All_Weight_array.count do
(
	w = All_Weight_array[i]
	bi = #() --bone index array
	wv = #() --weight value array
	
	for j = 1 to w.boneids.count do
	(
		boneid = w.boneids[j]
		weight = w.weights[j]
		append bi boneid
		append wv weight
	)	
	
	skinOps.ReplaceVertexWeights skinMod i bi wv
)

msh.material = MultiMat

max modify mode

--enableSceneRedraw()

fclose f

)

/*select Bone_root_array[1]
scale $ [36.0,36.0,36.0]
rotate $ (angleaxis 90 [1,0,0])*/
--actionMan.executeAction 0 "311"  -- Tools: Zoom Extents All Selected