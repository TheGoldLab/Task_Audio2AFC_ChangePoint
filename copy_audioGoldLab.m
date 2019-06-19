function audioGoldLab(str)
% run audio 2afc cp task
% str should be one of 'tut_report', 'tut_prediction', 'report',
% 'prediction'
% Example:
%  audioGoldLab('tut_report')
if ismember(str, {'tut_report', 'tut_prediction', 'report', 'prediction'})
    tbUseProject('Task_Audio2AFC_ChangePoint')
    run_task(str)
else
    error('str arg should be one of "tut_report", "tut_prediction", "report", "prediction"')
end