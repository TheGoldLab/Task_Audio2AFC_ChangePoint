function [bsqCell, bparams]=suggestBlock(sc)
% based on an analysis of the subject sessions metadata, generates a 
% pair (tutorial, block) where block is picked from the appropriate pair
% RETURNS:
%  bsqCell: block names as cell array, e.g. {'TutReport', 'Block001'}
%  bparams: block type, e.g. "pred" or "rep"
% NOTE: if subject is new, a new entry is created in metadata file

rng('shuffle');

% display what the subject has completed and what is left to complete
[sessionsTable, seqType] = subjSummary(sc);

% if subject is not new
if size(sessionsTable, 1) > 0  
    % get default block names sequence
    bseq=readDefaultPairSequence(seqType);  % seqType should never be NaN here
    
    % check whether last session was the completion of a pair or not
    lastWasCompletion = sessionsTable{end, 'PairCompletion'};
    if lastWasCompletion
        % move to next pair
        nextPairIndex = find(~sum(sessionsTable{:,1:length(bseq)}), 1);
        nextPair = bseq{nextPairIndex};
        lastBlockType = sessionsTable{end, 'BlockType'};
        % flip block type
        if strcmp(lastBlockType, 'rep')
            nextBlockType = 'pred';
        else
            nextBlockType = 'rep';
        end
    else
        % repeat same pair as last session
        nextPairIndices = find(sum(sessionsTable{:,1:length(bseq)}), 1);
        nextPair = bseq{nextPairIndices(end)};
        % if last session was completed, flip block type, otherwise repeat
        lastBlockType = sessionsTable{end, 'BlockType'};
        if iscell(lastBlockType)
            if length(lastBlockType) > 1
                error('cell should have at most length 1')
            end
            lastBlockType = lastBlockType{1};
        end
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
        bsqCell={'TutReport'};
    else
        bsqCell={'TutPrediction'};
    end
    
   
    bsqCell{2} = nextPair;

    % get the key-value pairs by trimming with the appropriate function
    bparams = nextBlockType;
    
else  % subject is new and new entry should be created in metadata file
    if rand < 0.5
        seqType = 'lowFirst';
    else
        seqType = 'highFirst';
    end
    
    bseq = readDefaultPairSequence(seqType);
    
    if rand < 0.5
        bparams = 'rep';    
        bsqCell = {'TutReport', bseq{1}};
    else
        bparams = 'pred';
        bsqCell = {'TutPrediction', bseq{1}};
    end
      originalFile = loadjson('subj_metadata.json');
    originalFile.(sc) = struct('seqType', seqType);
    savejson('', originalFile, 'subj_metadata.json');
end
end