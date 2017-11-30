classdef ReadMesh
    %ReadMesh Read Mesh from an ABAQUS formataed .inp file
    %   M = Mesh.MeshReader.ReadMesh(filename)
    %   Called with no MRProperties objects, will assume abaqus
    %   styled mesh, with *NODE and *ELEMENT
    %
    %   M = ReadMesh(filename, MRProperties1, MRProperties1, ...)
    %   Where each MRProperties is an object containing details of
    %   what mesh property to read.
    %
    %   Example:
    %   m1 = Mesh.MeshReader.MRProperties('*NODE',4,'%f %f %f %f',',');
    %   m2 = Mesh.MeshReader.MRProperties('*ELEMENT, TYPE=C3D4',5,'%f %f %f %f %f',',');
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
                
                m1 = Mesh.MeshReader.MRProperties('*NODE',4,'%f %f %f %f',',');
                m2 = Mesh.MeshReader.MRProperties('*ELEMENT',5,'%f %f %f %f %f',',');
                o.Properties = [o.Properties;m1];
                o.Properties = [o.Properties;m2];
                checkReadMeshProperties(o);
            end
            
            o.filename = varargin{1};
            
            
            for i = 2:nargin
                if ~isa(varargin{i},'MRProperties')
                   error(['input: ',num2str(i),' is not "MRProperties" class']) 
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
               
               if isempty(o.Properties(i).formatLength)
                   error(['formatLength is empty in MRProperties ',num2str(i)])
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
            
            %% Read complete file into memory
%             disp('Read complete .inp file into memory...')
%             tic
            fid = fopen(o.filename,'r');
            if fid == -1
                error(['Cannot open the file: ', o.filename])
            end
            try
                s = textscan(fid,'%s','Delimiter','\n');
            catch
                closeFile(fid);
                error('Something went wrong reading the file!');
            end
            closeFile(fid); 
            s = s{1};
%             toc
            
            %% Process file
            N = length(s);
            
            %% Finding line numbers
            U = o.Properties;
            nUserProps = length(o.Properties);
            startLineNumberC = cell(2,1);
            endLineNumberC = cell(2,1);
            startLineNumber = []; startLineFound = 0;
            endLineNumber = []; endLineFound = 0;
            for il = 1:N
                tline = s{il};
                for ip = 1:nUserProps
                    
                    if ~startLineFound
                        % Look for start line
                        if ~isempty(strfind(tline, U(ip).startLineText))
                            startLineNumberC{ip} = [startLineNumberC{ip}; il+1];
                            startLineNumber = [startLineNumber; il+1];
                            startLineFound = 1;
                            continue
                        end
                    end
                    
                    if startLineFound
                       % Find endline
                       if ~isempty(strfind(tline, U(ip).endLineText))
                           endLineNumberC{ip} = [endLineNumberC{ip}; il-1];
                           endLineNumber = [endLineNumber; il-1];
                           startLineFound = 0;
                       end
                       % Look for start line
                       if ~isempty(strfind(tline, U(ip).startLineText))
                           startLineNumberC{ip} = [startLineNumberC{ip}; il+1];
                           startLineNumber = [startLineNumber; il+1];
                           startLineFound = 1;
                           continue
                       end
                    end
                end
            end
            
            %% Pre allocate
            
%             [startLineNumber,endLineNumber]
            
            nDataSets = length(startLineNumber);
            M(nDataSets).Data = [];
            sizes = [startLineNumber(2:end);N]-startLineNumber;
            c = 1;
            for i = 1:length(startLineNumberC)
                for j = 1:length(startLineNumberC{i})
                    M(c).Data = NaN(sizes(c),U(i).formatLength);
                    M(c).startLineText = U(i).startLineText;
                    M(c).startLineNumber = startLineNumber(c);
                    M(c).formatspec = U(i).formatspec;
                    M(c).formatLength = U(i).formatLength;
                    M(c).delimiter = U(i).delimiter;
                    M(c).size = sizes(c);
                    c = c+1;
                end
            end
            
            %% Populate data
            for iset = 1:length(startLineNumber)
                irange = startLineNumber(iset):endLineNumber(iset);
                
                i = 1;
                for il = irange
                    tline = s{il};
                    if ~isempty(tline)
                        for ip = 1:nUserProps
                            nNumbers = textscan(tline, '%d','Delimiter',',' );
                            nNumbers = length([nNumbers{:}]);
                            
                            if ~(U(ip).formatLength == nNumbers)
                                continue
                            end
                            
                            Cline = textscan(tline,U(ip).formatspec,'Delimiter',U(ip).delimiter);
                            C = [Cline{:}];
                            if ~isempty(C)
                                nExpectedNumbers = U(ip).formatLength;
                                if nNumbers == nExpectedNumbers
                                    M(iset).Data(i,:) = C;
                                end
                            end
                        end
                        
                    end
                    i = i+1;
                end
            end

            %% Reduce
            for i = 1:length(M)
                indN = find(any(isnan(M(i).Data(:,:)),2),1);
                M(i).Data = M(i).Data(1:indN-1,:);
            end
            
            Data = M;
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

