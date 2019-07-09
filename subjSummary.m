function tab = subjSummary(subjcode, filename)
% displays metadata about a subject in this experiment
% function accepts 0, 1 or 2 arguments.
% if the subject code is not known, just call the function with no argument
% or with '' as first argument.
% With a single or no argument, the function uses the default filename for 
% the json metadata 
%
% Example: the easiest and best way to use the function is with no argument
%    subjSummary()
%


%--- DEAL WITH ARGUMENTS
% get subject info to get code
if nargin == 0 || isempty(subjcode)
    subjcode = getSubjectCode();
elseif ~isempty(subjcode) && ~strcmp(subjcode(1:3), 'HUP') 
    subjcode = ['HUP_', subjcode];
end

% read metadata file
if nargin < 2
    filename = 'subj_metadata.json';
end
%---


blockList = readDefaultPairSequence();
num_pairs = length(blockList);

blockList{num_pairs + 1} = 'TutReport';
blockList{num_pairs + 2} = 'TutPrediction';
blockList{num_pairs + 3} = 'PairCompletion';
blockList{num_pairs + 4} = 'Type';

num_bools = length(blockList) - 1;

ds = loadjson(filename);

% if subject exists
if isfield(ds, subjcode)
    currDs = ds.(subjcode);  % struct for this subject
    sessionNames = fieldnames(currDs);  % cell array of field names
    numSessions = length(fieldnames(currDs));
    type = cell(numSessions, 1);
    completedBlocks = cell(numSessions, length(blockList)-1);
    datesArray = cell(size(sessionNames));
    
    % display the blocks completed by the subject and their date
    % a whether block was run as report or prediction block, and whether
    % the session was completing a (report, prediction) pair or not
    
    %following cell keeps memory of last valid block name and type
    lastValid = {'',''};  % {'block name', 'block type'}
    % loop through sessions
    for s = 1:numSessions
        session = sessionNames{s};  % e.g. session1, session2, etc.
        sessStruct = currDs.(session);  % struct with session info
        datesArray{s} = sessStruct.sessionTag;  % usually a date stamp
        completed_pair = 0;  % whether this session completed a pair or not
        
        % loop through blocks
        for b = 1:num_bools
            blockName = blockList{b}; 
            if isfield(sessStruct, blockName) && b < num_bools
                if b <= num_pairs
                    blockType = sessStruct.(blockName).type;
                end
                completedBlocks{s,b} = sessStruct.(blockName).completed;
                if completedBlocks{s,b} && ~strcmp(blockName(1:3), 'Tut')
                    if s == 1
                        lastValid{1} = blockName;
                        lastValid{2} = blockType;
                    end
%                     fprintf(char(10))
%                     fprintf([blockName, ' ', lastValid{1}, lastValid{2}])
%                     fprintf(char(10))
                    if strcmp(lastValid{1}, blockName)
                        if ~strcmp(lastValid{2}, blockType)
%                             disp('set to 1')
                            completed_pair = 1;
                        end
                    end
                    lastValid{1} = blockName;
                    lastValid{2} = blockType;
                end
            elseif b == num_bools
                completedBlocks{s,b} = completed_pair;
                completed_pair = 0;
                type{s} = blockType;
            else
                completedBlocks{s,b} = 0;
            end
        end
    end
    fprintf(char(10))  % new line
    fprintf('Session metadata for subject %s', subjcode);
    fprintf(char(10))  % new line
    tab = cell2table(completedBlocks, ...
        'VariableNames', blockList(1:end-1), ...
        'RowNames', datesArray);
    tab.BlockType = type;
    disp(tab)
else
    % if subject is new
    %   say subject is new
    fprintf(char(10))
    fprintf('Subject %s is new for this experiment', subjcode);
    fprintf(char(10))
    tab=table();
end

end