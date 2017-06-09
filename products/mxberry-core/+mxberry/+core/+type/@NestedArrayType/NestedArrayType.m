classdef NestedArrayType<mxberry.core.type.ANestedArrayType
    properties (Access=protected)
        typeInfo
    end
    %
    methods
        function isPositive=isIncludedInto(self,obj)
            if isa(obj,'mxberry.core.type.NestedArrayType')
                if isempty(obj.typeInfo.type)
                    isPositive=isempty(obj.typeInfo.type)&&...
                        obj.typeInfo.depth<=self.typeInfo.depth;
                else
                    isPositive=isequal(obj.typeInfo,self.typeInfo);
                end
            elseif obj.isCompleteTypeSet()
                isPositive=true;
            elseif obj.isEmptyTypeSet()
                isPositive=false;
            else
                isSelfCell=self.typeInfo.depth>0;
                if isSelfCell
                    if obj.isCellTypeContained()
                        isPositive=true;
                    elseif ~obj.isContainedInCellType()
                        isPositive=false;
                    else
                        self.throwCannotDetermineIfIncludedIntoException();
                    end
                else
                    if obj.isContainedInCellType()
                        isPositive=false;
                    else
                        self.throwCannotDetermineIfIncludedIntoException();
                    end
                end
            end
        end
    end
    methods (Access=private)
        function SRes=toStruct(self)
            SRes=reshape([self.typeInfo],size(self));
        end
    end
    methods (Static,Access=protected)
        function isPositive=isMe(obj)
            isPositive=isa(obj,mfilename('class'));
        end
    end
    methods (Access=protected)
        function STypeInfo=getValueTypeStruct(self)
            STypeInfo=self.typeInfo;
            if isempty(STypeInfo.type)
                STypeInfo.type='char';
            end
        end
        function self=NestedArrayType(varargin)
            if nargin==0
                return;
            elseif nargin==1&&isnumeric(varargin{1})&&isempty(varargin{1})
                self=self([]);
            elseif nargin==1&&mxberry.core.type.NestedArrayType.isMe(varargin{1})
                self.typeInfo=varargin{1}.toStruct();
            elseif nargin==1&&isstruct(varargin{1})
                self.typeInfo=varargin{1};
            else
                mxberry.core.throwerror('wrongInput',...
                    'unsupported way to construct NestedArrayType object');
            end
            if self.typeInfo.depth==0&&isempty(self.typeInfo.type)
                mxberry.core.throwerror('wrongInput',...
                    ['type field in typeInfo struct can ',...
                    'be empty only when depth>0'])
            end
        end
    end
    methods
        function classNameList=toClassName(self)
            classNameList=...
                mxberry.core.type.NestedArrayType.typeinfo2classname(...
                self.typeInfo);
        end
        function typeSeqString=toTypeSequenceString(self)
            typeNameList=self.toClassName;
            typeSeqString=strcat(typeNameList,'->');
            typeSeqString=[typeSeqString{:}];
            typeSeqString=typeSeqString(1:end-2);
        end
        function isPositive=isContainedInCellType(self)
            isPositive=self.typeInfo.depth>0;
        end
        function isPositive=isCellTypeContained(self) %#ok<MANU>
            isPositive=false;
        end
        function SRes=struct(self)
            SRes=self.toStruct();
        end
    end
    methods (Static)
        resObj=loadobj(inpObj)
        isOk=checkvaluematchisnull(value,valueIsNull)
        STypeInfo=classname2typeinfo(classNameList)
        [isUniform,STypeInfo]=generatetypeinfostruct(value)
        classNameList=typeinfo2classname(STypeInfo)
        function STypeInfo=fromClassName(classNameList)
            % fromClassName translates built-in class names into STypeInfo
            % definitions
            %
            % Input:
            %   classNameList: char/cell[1,nNestedLevels]
            %
            % Output:
            %   STypeInfo: struct[1,1] - type information
            %
            %            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            %
            STypeInfo=mxberry.core.type.NestedArrayType(...
                mxberry.core.type.NestedArrayType.classname2typeinfo(classNameList));
        end
        function STypeInfo=fromStruct(SInp)
            STypeInfo=mxberry.core.type.NestedArrayType(SInp);
        end
        function STypeInfo=fromClassNameArray(classNameListCArray)
            nElem=numel(classNameListCArray);
            STypeInfo(nElem)=mxberry.core.type.NestedArrayType();
            for iElem=1:nElem
                STypeInfo(iElem)=...
                    mxberry.core.type.NestedArrayType.fromClassName(...
                    classNameListCArray{iElem});
            end
            STypeInfo=reshape(STypeInfo,size(classNameListCArray));
        end
        function STypeInfo=fromValue(value)
            [isUniform,STypeInfo]=...
                mxberry.core.type.NestedArrayType.generatetypeinfostruct(value);
            if ~isUniform
                mxberry.core.throwerror('wrongInput',...
                    'value is not uniform and cannot be assigned a type');
            end
            STypeInfo=mxberry.core.type.NestedArrayType(STypeInfo);
            
        end
        function [isUniform,STypeInfo]=fromValueArray(valueArray)
            nElem=numel(valueArray);
            isUniform=false(size(valueArray));
            STypeInfo(nElem)=mxberry.core.type.NestedArrayType();
            for iElem=1:nElem
                STypeInfo(iElem)=...
                    mxberry.core.type.NestedArrayType.fromValue(...
                    valueArray{iElem});
            end
            STypeInfo=reshape(STypeInfo,size(valueArray));
            %
        end
    end
    methods
        function self=setFromValue(self,value)
            [~,STypeInfo]=...
                mxberry.core.type.NestedArrayType.generatetypeinfostruct(value);
            self.typeInfo=STypeInfo;
        end
    end
end