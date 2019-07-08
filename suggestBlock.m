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

% only change something if subject is not new
if size(sessionsTable, 1) > 0  
    
    % the 'compulsory' cell below is the one that will eventually contain
    % the ordered list of blocks for this session
    % we always start by these first 5
    compulsory={};
    
    % loop through remaining default blocks and add them to the compulsory
    % list until the list reaches the default length. Blocks should be
    % added in sequential order, always favoring first the ones which have
    % been completed the least amount of time
    
    % full list of default blocks (bsqCell will be changed later)
    defaultBlocks = bsqCell;
    
    % total length of compulsory list at end of algorithm
    seqLength=length(defaultBlocks);
    
    % length of compulsory initial blocks listed above
    minLength=length(compulsory);
    
    % index in block sequence where blocks should start being added
    startIdx=minLength+1;
    
    % number of blocks to add to the compulsory list
    numBlocksToAdd = 2;
    
    % pool of blocks to pick from
    bPool=defaultBlocks(startIdx:seqLength);
    
    % total number of completions for each block
    tally = sum(sessionsTable{:,startIdx:seqLength},1);
    
    % total number of blocks added so far to 'compulsory'
    addedBlocks=0;
    
    % index in compulsory list where next block should be added
    insertionIdx = startIdx;  
    
    % add until compulsory list has desired length
    while addedBlocks < numBlocksToAdd
        % get the index (in tally vector) of next block to add
        [~, newBlockIdx] = min(tally);
        compulsory{insertionIdx} = bPool{newBlockIdx};
        insertionIdx=insertionIdx+1;
        addedBlocks=addedBlocks+1;
        tally(newBlockIdx)=tally(newBlockIdx)+1;
    end
    
    % set the variables to return
    bsqCell=compulsory{1};
    
    % get the key-value pairs by trimming with the appropriate function
    bparams = buildkvpairs(bparams, bsqCell);
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