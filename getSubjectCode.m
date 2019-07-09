function h = getSubjectCode()
% ask for subject's info (assumed to be de-identified)
HUP = strtrim(input('Enter HUP number for subject: ', 's'));
h = ['HUP_', HUP];
end