function topNode = run_task(location)
%% function [mainTreeNode, datatub] = run_task(location)
%
% run_task = auditory change-point task
%
% This function configures, initializes, runs, and cleans up an Audio2AFCCP 
% task experiment 
%
% 04/02/19   aer wrote it

%% ---- Clear globals
%
% umm, duh
clear globals

%% ---- Configure experiment based on location
%
%   locations are 'pilot'
%
% UIs:
%  'dotsReadableEyeEyelink'
%  'dotsReadableEyePupilLabs'
%  'dotsReadableEyeEOG'
%  'dotsReadableHIDKeyboard'
%  'dotsReadableEyeMouseSimulator'
%  'dotsReadableHIDButtons'
%  'dotsReadableHIDGamepad'

switch location
    case {'office'}
        arglist = { ...
            'taskSpecs',            {'Block1' 3}, ...%{'Quest' 50 'SN' 50 'AN' 50}, ...
            'trialFolder',          'Blocks001/', ...  % folder where trial generation data resides
            'readables',            {'dotsReadableHIDGamepad'}, ...
            'displayIndex',         0, ... % 0=small, 1=main, 2=other screen
            'remoteDrawing',        false, ...
            'sendTTLs',             false, ...
            'showFeedback',         0, ... % timeout for feedback
            'showSmileyFace',       0, ... % timeout for smiley face on correct target
            };
end

%% ---- Call the configuration routine
%
topNode = configure_task(arglist{:});

%% ---- Run it!
%
topNode.run();
