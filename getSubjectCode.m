function h = getSubjectCode()
% ask for subject's info (assumed to be de-identified
confirmed = false;
while ~confirmed
    HUP = strtrim(...
        input('Enter HUP number for subject: ', 's'));
    
    disp('')
    disp('Entered HUP:')
    disp(' ')    
    disp(['   ', HUP])
    disp(' ')
    confirmSubjData = input('Is this HUP correct? (y/n) ', 's');
    if strcmp(confirmSubjData, 'y')
        h = ['HUP_', HUP];
        confirmed = true;
    end
end
end