function topNode = run_task(location, blocks, type, subjcode)
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
    case {'EMU'}
        arglist = { ...
            'taskSpecs',            {blocks, type}, ...
            'subjectCode',          subjcode, ...
            'readables',            {'customButtonsClass'}, ...
            'displayIndex',         1, ... % 0=small, 1=main, 2=other screen
            'remoteDrawing',        false, ...
            'sendTTLs',             true, ...
            'buttonBox',            'EMU'
            };
    case {'office'}
        arglist = { ...
            'taskSpecs',            {blocks, type}, ...
            'subjectCode',          subjcode, ...
            'readables',            {'customButtonsClass'}, ...
            'displayIndex',         0, ... % 0=small, 1=main, 2=other screen
            'remoteDrawing',        false, ...
            'sendTTLs',             false, ...
            'buttonBox',            'Gold'
            };
end

%% ---- Call the configuration routine
%
topNode = configure_task(arglist{:});

%% ---- Run it!
%
topNode.run();
