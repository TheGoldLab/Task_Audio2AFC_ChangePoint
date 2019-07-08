function copy_audioGoldLab(str)
% run audio 2afc cp task
clear all

tbUseProject('Task_Audio2AFC_ChangePoint')

hashed_sc = getSubjectCode();

% compute suggested block for current session
[block, params] = suggestBlock(hashed_sc);

if size(block,1) == 1
    block=block';  % transpose for aesthetic purposes
end
disp(block)

isOK = input('Is the above block OK? (y/n) ', 's');
end
