# MeshReader
MeshReader v.2.0

## ReadMesh 
Read Mesh from a file.

    M = MeshReader.ReadMesh(filename)
Called with no *Mesh.MeshReader.MRProperties* objects, will assume abaqus
styled .imp mesh, with \*NODE and \*ELEMENT

	M = MeshReader.ReadMesh(filename, MRProperties1, MRProperties1, ...)
Where each *MRProperties* is an object containing details of
what mesh property to read.

**NOTE:**
Only one set of nodes (coordinates) will be collected when using the searchstring '\*NODE'
But serveral sets of '*\*ELEMENT' can be found. These will be collected into the *M.Mesh* struct array.

### Example:
	m1 = MeshReader.MRProperties('*NODE',4,'%f %f %f %f',',');
	m2 = MeshReader.MRProperties('*ELEMENT, TYPE=C3D4',5,'%f %f %f %f %f',',');
	MR = MeshReader.ReadMesh(file,m1,m2);

### Properties
- *filename*
- *Properties* - The passed arguments to ReadMesh
- *Mesh* - Struct array holding the extracted mesh data, order same as indata to *Mesh.MeshReader.ReadMesh*

## MRProperties
Set mesh properties to extract using MeshReader

	mp = MeshReader.MRProperties()
Initializes and empty MRProperties, all properties must be set before passing to MeshReader

	mp = MeshReader.MRProperties(startLineText,endLineText,formatspec,delimiter)
- startLineText - The starting text line identifying the first property
- formatLength  - The number of numbers expected to extract on each line.
- [formatspec](http://se.mathworks.com/help/matlab/ref/textscan.html#input_argument_formatspec "http://se.mathworks.com/help/matlab/ref/textscan.html#input_argument_formatspec")
- [delimiter](http://se.mathworks.com/help/matlab/ref/textscan.html#btg0ke8 "http://se.mathworks.com/help/matlab/ref/textscan.html#btg0ke8")

### Example:

	m1 = MRProperties('*NODE',4,'%f %f %f %f',',');
will find data formated as:

        1,      0.17329865692338314,       0.8448032613274371,       0.1465698869594017