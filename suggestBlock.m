function [bsqCell, bparams]=suggestBlock(sc)
% based on an analysis of the subject sessions metadata, generates a 
% pair (tutorial, block) where block is picked from the appropriate pair
% RETURNS:
%  bsqCell: block names as cell array, e.g. {'TutReport', 'Block001'}
%  bparams: block type, e.g. "pred" or "rep"
% NOTE: if subject is new, a new entry is created in metadata file

rng('shuffle');

% display what the subject has completed and what is left to complete
sessionsTable = subjSummary(sc);

% get default block names sequence
bsqCell=readDefaultPairSequence();

% if subject is not new
if size(sessionsTable, 1) > 0  
    
    % check whether last session was the completion of a pair or not
    lastWasCompletion = sessionsTable{end, 'PairCompletion'};
    if lastWasCompletion
        % move to next pair
        nextPairIndex = find(~sum(sessionsTable{:,1:length(bsqCell)}), 1);
        nextPair = bsqCell{nextPairIndex};
        lastBlockType = sessionsTable{end, 'BlockType'};
        % flip block type
        if strcmp(lastBlockType, 'rep')
            nextBlockType = 'pred';
        else
            nextBlockType = 'rep';
        end
    else
        % repeat same pair as last session
        nextPairIndices = find(sum(sessionsTable{:,1:length(bsqCell)}), 1);
        nextPair = bsqCell{nextPairIndices(end)};
        % if last session was completed, flip block type, otherwise repeat
        lastBlockType = sessionsTable{end, 'BlockType'};
        if sessionsTable{end, nextPair}
            if strcmp(lastBlockType, 'rep')
                nextBlockType = 'pred';
            else
                nextBlockType = 'rep';
            end
        else
            nextBlockType = lastBlockType;
        end
    end
    
    % the 'compulsory' cell below is the one that will eventually contain
    % the ordered list of blocks for this session
    % we always start with appropriate tutorial
    if strcmp(nextBlockType, 'rep')
        compulsory={'TutReport'};
    else
        compulsory={'TutPrediction'};
    end
    
   
    compulsory{2} = nextPair;

    
    % set the variables to return
    bsqCell=compulsory;
    
    % get the key-value pairs by trimming with the appropriate function
    bparams = nextBlockType;
else  % subject is new and new entry should be created in metadata file
    if rand < 0.5
        startH = 'low';
        first = 'odd';  % low h blocks are at odd indices
        bsqCell = bsqCell{1};
    else
        startH = 'high';
        first = 'even';
        bsqCell = bsqCell{2};
    end
    if rand < 0.5
        btype = 'rep';
    else
        btype = 'pred';
    end
    bparams = btype;
    originalFile = loadjson('subj_metadata.json');
    originalFile.(sc) = struct();
    savejson('', originalFile, 'subj_metadata.json');
end
end