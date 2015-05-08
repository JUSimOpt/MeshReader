# +MeshReader
MeshReader package

## ReadMesh 
Read Mesh from a file.

    M = Mesh.MeshReader.ReadMesh(filename)
Called with no *Mesh.MeshReader.MRProperties* objects, will assume abaqus
styled .imp mesh, with \*NODE and \*ELEMENT

	M = Mesh.MeshReader.ReadMesh(filename, MRProperties1, MRProperties1, ...)
Where each *MRProperties* is an object containing details of
what mesh property to read.

### Example:
	m1 = Mesh.MeshReader.MRProperties('*NODE','**','%*d %f %f %f',',');
	m2 = Mesh.MeshReader.MRProperties('*ELEMENT, TYPE=C3D4, ELSET=P2;PSOLID','**','%*d %d %d %d %d',',');
	M = Mesh.MeshReader.ReadMesh('CubeTetMesh2.inp',m1,m2)
	Points = M.Mesh{1};
	Connectivity = M.Mesh{2};

### Properties
- *filename*
- *Properties* - The passed arguments to ReadMesh
- *Mesh* - Cell array holding the extracted mesh data, order same as indata to *Mesh.MeshReader.ReadMesh*

## MRProperties
Set mesh properties to extract using MeshReader

	mp = Mesh.MeshReader.MRProperties()
Initializes and empty MRProperties, all properties must be set before passing to MeshReader

	mp = Mesh.MeshReader.MRProperties(startLineText,endLineText,formatspec,delimiter)
- startLineText - The starting text line identifying the first property
- endLineText   - The ending text line of the first property
- [formatspec](http://se.mathworks.com/help/matlab/ref/textscan.html#input_argument_formatspec "http://se.mathworks.com/help/matlab/ref/textscan.html#input_argument_formatspec")
- [delimiter](http://se.mathworks.com/help/matlab/ref/textscan.html#btg0ke8 "http://se.mathworks.com/help/matlab/ref/textscan.html#btg0ke8")
