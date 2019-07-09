function copy_audioGoldLab(callTbTb)
if nargin < 1
    callTbTb = true;
end
if callTbTb
    tbUseProject('Task_Audio2AFC_ChangePoint')
end

hashed_sc = getSubjectCode();

% compute suggested block for current session
[block, type] = suggestBlock(hashed_sc);

if size(block,1) == 1
    block=block';  % transpose for aesthetic purposes
end

disp(['About to run: ', block{1} , ' + ', block{2}, ' (', type,')'])

run_task('office', block, type, hashed_sc)

end
