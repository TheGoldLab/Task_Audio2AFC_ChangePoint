function topnode = copy_audioGoldLab(callTbTb)
clear mex; 
if nargin < 1
    callTbTb = true;
end
if callTbTb
    tbUseProject('Task_Audio2AFC_ChangePoint');
end

hashed_sc = getSubjectCode();

% compute suggested block for current session
[block, type] = suggestBlock(hashed_sc);

if size(block,1) == 1
    block=block';  % transpose for aesthetic purposes
end
fprintf(char(10))
fprintf('About to run: %s + %s (%s)', block{1}, block{2}, type)
fprintf(char(10))
topnode = run_task('office', block, type, hashed_sc);

end
