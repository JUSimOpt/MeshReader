classdef MRProperties
    %MRProperties Set mesh properties to extract using MeshReader
    %   mp = MRProperties();
    %   Initializes and empty MRProperties, all properties must be
    %   set before passing to MeshReader
    %   mp = MRProperties(startLineText,endLineText,formatspec,delimiter);
    %   startLineText - The starting text line identifying the first property
    %   formatLength  - The number of numbers expected to extract on each
    %   line.
    %   formatspec    - The formatspec of the data to be extracted, see 
    %   <a href="matlab:web('http://se.mathworks.com/help/matlab/ref/textscan.html#input_argument_formatspec')">formatspec</a>
    %   <a href="matlab:web('http://se.mathworks.com/help/matlab/ref/textscan.html#btg0ke8')">delimiter</a>
    %   
    %   Example: 
    %   m1 = MRProperties('*NODE','**','%*d %f %f %f',',');
    %   will find  data formated as:
    %   1,      0.17329865692338314,       0.8448032613274371,       0.1465698869594017
    
    properties
        startLineText = []  %The starting line, enwrapping the data to be extracted
        formatLength = []
        formatspec = []     %<a href="matlab:web('http://se.mathworks.com/help/matlab/ref/textscan.html#input_argument_formatspec')">formatspec</a>
        delimiter = []      %<a href="matlab:web('http://se.mathworks.com/help/matlab/ref/textscan.html#btg0ke8')">delimiter</a>
    end
    
    methods
        function o = set.startLineText(o,val)
            if ~isa(val,'char')
                error('startLineText must be a string')
            end
            o.startLineText = val;           
        end
        
        function o = set.formatLength(o,val)
            if ~isa(val,'double')
                error('formatLength must be a number')
            end
            o.formatLength = val;           
        end
        
        function o = set.formatspec(o,val)
            if ~isa(val,'char')
                error('formatspec must be a string')
            end
            o.formatspec = val;           
        end
        
        function o = set.delimiter(o,val)
            if ~isa(val,'char')
                error('delimiter must be a char')
            end
            o.delimiter = val;           
        end
        
        function o = MRProperties(varargin)
            if nargin > 4
                error('0 or 4 parameters expected!')
            end
            if nargin == 0
                return
            end
            if nargin <= 4
                if ~isa(varargin{1},'char')
                    error('startLineText must be a string')
                end
                if ~isa(varargin{2},'double')
                    error('formatLength must be a number')
                end
                if ~isa(varargin{3},'char')
                    error('formatspec must be a string')
                end
                if ~isa(varargin{4},'char')
                    error('delimiter must be a char')
                end
                
                o.startLineText = varargin{1};
                o.formatLength = varargin{2};
                o.formatspec = varargin{3};
                o.delimiter = varargin{4};
            end
            
            
        end
        
        
    end
    
end

