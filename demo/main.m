clear
clc
close all

mainCodeDir = UpDir(pwd,1);
meshDir = UpDir(pwd,2);
addpath(fullfile(mainCodeDir))
addpath(fullfile(meshDir,'AnsaMeshGenerator'))
addpath(fullfile(meshDir,'Tet2MeshDev','Tet2Mesh'))
addpath(fullfile(meshDir,'Tet2CutDev','TetP2CutSurface'))

x0 = 0; x1 = 4;
y0 = -1.1; y1 = 1.1;
z0 = -1.1; z1 = 1.1;
eleLength = 0.175
[file, status] = AnsaMesh(x0,x1,y0,y1,z0,z1,eleLength)


%% User input
file = 'mesh.inp';
% U.startLineText = {'*NODE', '*ELEMENT, TYPE=C3D4'};
% U.formatspec = {'%f %f %f %f','%d %d %d %d %d'};
% U.formatLength = {4,5};
% U.delimiter = {',',','};

%% Read Mesh
disp('Reading mesh...')
tic
m1 = MRProperties('*NODE','**', 4,'%f %f %f %f',',');
m2 = MRProperties('*ELEMENT, TYPE=C3D4','*ELEMENT, TYPE=C3D4',5,'%f %f %f %f %f',',');
MR = ReadMesh(file,m1,m2);
toc

M = MR.Mesh;

%% Renumbering Abaqus numbering
DOFs = 3; %3D
Knod = 4; %Tetrahedral elements, 4 nodes per element

coordSets = [1]
nodeSets = 2:length(MR.Mesh)
disp('Abaqus renumbering...')
tic
AR = AbaqusRenumbering(MR, coordSets, nodeSets, DOFs, Knod);
P = AR.P;
T = AR.nodes;
toc

%% Tetramesh
TR = Tet1(P,T);
[h,xf] = TR.vizMesh();
h.patch.FaceColor = 'w'
% h.patch.FaceAlpha = 0.4


% xind = find(T.XC <= 0+eps);
% nodes = T.Connectivity;
% ele = find(sum(ismember(nodes,xind),2)==4);
% T.vizMesh(ele);

% disp('Convert to P2')
% mesh = Tet2Mesh(T, P);
% disp('done')
% %%
% R = 1;
% phi = @(x,y,z) x.*0+ ((y-0).^2 + (z-0).^2).^0.5-R; %Cylinder
% gradphi = @(x,y,z)[x.*0, y./(y.^2 + z.^2).^(1/2), z./(y.^2 + z.^2).^(1/2)];
% surface.phi = phi;
% surface.gradphi = gradphi;
% disp('Extract cut surface...'); tic;
% surface.gorder = 2;
% [CutElements] = TetP2CutSurface3(mesh,surface);
% disp('done')
% %%
% clear mesh
% mesh.nodes = T;
% mesh.P = P;

%%
function dir = UpDir(dir,n)
    for i = 1:n
        dir = fileparts(dir);
    end
end