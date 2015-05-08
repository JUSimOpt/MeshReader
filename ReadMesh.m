classdef ReadMesh
    %ReadMesh Read Mesh from a file
    %   M = Mesh.MeshReader.ReadMesh(filename)
    %   Called with no MRProperties objects, will assume abaqus
    %   styled mesh, with *NODE and *ELEMENT
    %
    %   M = ReadMesh(filename, MRProperties1, MRProperties1, ...)
    %   Where each MRProperties is an object containing details of
    %   what mesh property to read.
    %
    %   Example:
    %   m1 = MRProperties('*NODE','**','%*d %f %f %f',',');
    %   m2 = MRProperties('*ELEMENT, TYPE=C3D4, ELSET=P2;PSOLID','**','%*d %d %d %d %d',',');
    %   M = ReadMesh('CubeTetMesh2.inp',m1,m2)
    %   Points = M.Mesh{1};
    %   Connectivity = M.Mesh{2};
    
    properties
        filename
        Properties = [] % The passed arguments to ReadMesh
        Mesh % Cell array holding the extracted mesh data, order same as indata to ReadMesh
    end
    
    properties (Dependent = true)
       nProperties 
    end
    
    methods
        
        %%
        function o = ReadMesh(varargin)
            if nargin < 1 
                error('file name needed!')
            end
            
            if ~isa(varargin{1},'char')
                error('file name must be string')
            end
            if ~(exist(varargin{1},'file')==2)
                error('file does not exist!')
            end
            
            
            
            if nargin == 1 % .inp file with nodes and elements
                
                m1 = Mesh.MeshReader.MRProperties('*NODE','**','%*d %f %f %f',',');
                m2 = Mesh.MeshReader.MRProperties('*ELEMENT, TYPE=C3D4, ELSET=P2;PSOLID','**','%*d %d %d %d %d',',');
                o.Properties = [o.Properties;m1];
                o.Properties = [o.Properties;m2];
                checkReadMeshProperties(o);
            end
            
            o.filename = varargin{1};
            
            
            for i = 2:nargin
                if ~isa(varargin{i},'Mesh.MeshReader.MRProperties')
                   error(['input: ',num2str(i),' is not "Mesh.MeshReader.MRProperties" class']) 
                end
                o.Properties = [o.Properties;varargin{i}];
            end
            checkReadMeshProperties(o);
            
            o.Mesh = ReadMesh1(o);
            
            
        end
        
        function out = get.nProperties(o)
            out = length(o.Properties);
        end
        
        
        
    end
    
    methods (Access = private)
        %%
        function checkReadMeshProperties(o)
            np = o.nProperties;
            for i = 1:np
               if isempty(o.Properties(i).startLineText)
                   error(['startLineText is empty in MRProperties ',num2str(i)])
               end
               
               if isempty(o.Properties(i).endLineText)
                   error(['endLineText is empty in MRProperties ',num2str(i)])
               end
               
               if isempty(o.Properties(i).formatspec)
                   error(['formatspec is empty in MRProperties ',num2str(i)])
               end
               
               if isempty(o.Properties(i).delimiter)
                   error(['delimiter is empty in MRProperties ',num2str(i)])
               end
            end
        end
        
        %%
        function Data = ReadMesh1(o)
            
            np = o.nProperties;
            startLineNumber = zeros(np,1);
            endLineNumber = zeros(np,1);
            startLineText = {o.Properties(:).startLineText};
            endLineText = {o.Properties(:).endLineText};
            formatspec = {o.Properties(:).formatspec};
            delimiter = {o.Properties(:).delimiter};
            
            DataSize = zeros(np,2);
            
            
            %% Determine number of lines
            % open file
%             tic
            fid = fopen(o.filename,'r');
            try
                tline = fgetl(fid);
                line = 0;
                while ischar(tline)
                    line = line+1;
                    
                    %start line
                    for i = 1:np
                        if ~isempty(strfind(tline, startLineText{i}))
                            startLineNumber(i) = line;
                        end
                        if ~isempty(strfind(tline, endLineText{i})) && startLineNumber(i) > 0 && endLineNumber(i) == 0
                            endLineNumber(i) = line;
                            if i == np %Last option was read, we can exit the loop now
                                break
                            end
                        end  
                    end
                    tline = fgetl(fid);
                end
            catch ex
                closeFile(fid);
                error(['Error reading file "',o.filename,'" \n',ex ])
            end
            closeFile(fid);
%             toc
            
            startLineNumber = startLineNumber+1;
            endLineNumber = endLineNumber-1;
            DataSize(:,1) = endLineNumber-(startLineNumber-1);
            Data{np} = [];
            
            %% Gather Data
%             tic
            
            ip = ones(np,1);
            fid = fopen(o.filename,'r');
            try
                tline = fgetl(fid);
                line = 0;
                while ischar(tline)
                    line = line+1;
                    
                    
                        
                    for i = 1:np
                        
                        if (line >= startLineNumber(i)) && (line <= endLineNumber(i))
                            
                            if DataSize(i,2) == 0
                                C = textscan(tline,formatspec{i},'Delimiter',delimiter{i});
                                DataSize(i,2) = length(C);
                                Data{i} = zeros(DataSize(i,:));
                            end
                            
                            C = textscan(tline,formatspec{i},'Delimiter',delimiter{i});
                            
                            
                            if ~isempty([C{:}])
                                Data{i}(ip(i),:) = [C{:}];
                                ip(i) = ip(i)+1;
                            end
                            
                            
                        end
                        
%                         if line > endLineNumber(end)
%                             break
%                         end
                    end
                    
%                     if (line>endLineNumber(2))
%                             disp('hello')
%                             Data{2}((ip(2)-1),:)
%                     end
                    
                    tline = fgetl(fid);
                end
            catch ex
                closeFile(fid);
                error(['Error reading file "',o.filename,'" \n',ex.message ])
            end
            closeFile(fid);
%             toc
            
        end
        
    end
    
end

function success = closeFile(fid)
    try
        fclose(fid);
        success = 1;
    catch
        success = 0;
    end
end

