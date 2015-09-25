clear
clc
close all

% clear M nele
% [file,status]=Mesh.AnsaMeshGenerator.generateAnsaMesh(-1.1,1.1,-1.1,1.1,-0.6,0.6,0.4)


%% User input
file = 'D:\Dropbox\Work\Matlab\generalfiles\+Mesh\+MeshReader\dev\mesh.inp';
U.startLineText = {'*NODE', '*ELEMENT, TYPE=C3D4'};
U.formatspec = {'%f %f %f %f','%d %d %d %d %d'};
U.formatLength = {4,5};
U.delimiter = {',',','};

%% Read Mesh
disp('Reading mesh...')
tic
m1 = Mesh.MeshReader.MRProperties('*NODE',4,'%f %f %f %f',',');
m2 = Mesh.MeshReader.MRProperties('*ELEMENT, TYPE=C3D4',5,'%f %f %f %f %f',',');
MR = Mesh.MeshReader.ReadMesh(file,m1,m2);
toc

M = MR.Mesh;

%% Renumbering Abaqus numbering
DOFs = 3; %3D
Knod = 4; %Tetrahedral elements, 4 nodes per element

coordSets = [1]; 
nodeSets = 2:length(MR.Mesh);
AR = Mesh.MeshReader.AbaqusRenumbering(MR, coordSets, nodeSets, DOFs, Knod);
P = AR.Points;
T = AR.Connectivity;

%% Tetramesh
TR = Mesh.Tet1(P,T);
[h,xf] = TR.vizMesh();


% xind = find(T.XC <= 0+eps);
% nodes = T.Connectivity;
% ele = find(sum(ismember(nodes,xind),2)==4);
% T.vizMesh(ele);


