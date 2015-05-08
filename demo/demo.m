clear
close all
clc



tic
M = Mesh.MeshReader.ReadMesh('CubeTetMesh2.inp')
toc
Points = M.Mesh{1};
Connectivity = M.Mesh{2};


%%
size(Connectivity)
size(Points)

xfigure
h = tetramesh2(Connectivity, Points);
h.FaceColor = 'c';
axis equal
view(3)
