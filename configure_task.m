function topNode =  configure_task(varargin)
%% function topNode =  configure_task(varargin)
%
% This function sets up an auditory change-point experiment. We
% keep this logic separate from
% running and cleaning up an experiment because we may want to decide
% when/how do do those other things on the fly (e.g., add/subtract tasks
% depending on the subject's motivation, etc).
%
% Arguments:
%  varargin  ... optional <property>, <value> pairs for settings variables
%                 note that <property> can be a cell array for nested
%                 property structures in the task object
%
% Returns:
%  mainTreeNode ... the topsTreeNode at the top of the hierarchy
%
% 04/02/19   aer wrote it, based on DBSconfigure.m in
% Lab-Matlab-Control/tasks/DBSStudy/DBSconfigure.m

%% ---- Parse arguments for configuration settings
%
% Name of the experiment, which determines where data are are stored
name = 'Audio2AFC_CP';

% Other defaults
settings = { ...
    'taskSpecs',                  {{'TutReport', 'Block001'}, 'rep'},...
    'subjectCode',                '', ...
    'type',                       'rep', ...
    'remoteDrawing',              false, ...
    'instructionDuration',        0, ...
    'displayIndex',               0, ... % 0=small, 1=main
    'readables',                  {'dotsReadableHIDKeyboard'}, ...
    'doCalibration',              true, ...
    'doRecording',                true, ...
    'queryDuringCalibration',     false, ...
    'sendTTLs',                   false, ...
    'gazeWindowSize',             6, ...
    'gazeWindowDuration',         0.15, ...
    'saccadeDirections',          [0 180], ...
    'referenceRT',                500, ... % for speed feedback
    'showFeedback',               .5, ... % timeout for feedback
    'showSmileyFace',             .2, ...
    'trialFolder',                '', ...
    'isReport',                   true, ...
    'predictSource',              false, ...
    'buttonBox',                  'EMU'};

% Update from argument list (property/value pairs)
for ii = 1:2:nargin
    settings = setval(settings, varargin{ii}, varargin{ii+1});
end

c = access(settings, 'taskSpecs');
type = c{2};
setval(settings, 'type', type);
if strcmp(type, 'pred')
    settings = setval(settings, 'isReport', false);
    settings = setval(settings, 'predictSource', true);
end

if access(settings, 'predictSource') + access(settings, 'isReport') == 2
    error('should not be both a report and a prediction block')
end

%% ---- Create topsTreeNodeTopNode to control the experiment
%
% Make the topsTreeNodeTopNode
topNode = topsTreeNodeTopNode(name);
topNode.closingMessage = '';
% Add a topsGroupedList as the nodeData, which here just stores the
% property/value "settings" we use to control task behaviors
topNode.nodeData = topsGroupedList.createGroupFromList('Settings', settings);

% Add GUIS. The first is the "run gui" that has some buttons to start/stop
% running and some real-time output of eye position. The "database gui" is
% a series of dialogs that execute at the beginning to collect subject/task
% information and store it in a standard format.
% topNode.addGUIs('run', topNode.nodeData{'Settings'}{'runGUIname'}, ...
%     'database', topNode.nodeData{'Settings'}{'databaseGUIname'});

% Add the screen ensemble as a "helper" object. See
% topsTaskHelperScreenEnsemble for details
topNode.addHelpers('screenEnsemble',  ...
    topNode.nodeData{'Settings'}{'displayIndex'}, ...
    topNode.nodeData{'Settings'}{'remoteDrawing'}, ...
    topNode);

% Add a basic feedback helper object, which includes text, images,
% and sounds. See topsTaskHelperFeedback for details.
topNode.addHelpers('feedback');

% Add readable(s). See topsTaskHelperReadable for details.
readables = topNode.nodeData{'Settings'}{'readables'};
for ii = 1:length(readables)
   topNode.addReadable('readable', ...
      topNode.nodeData{'Settings'}{'doRecording'}, ...
      topNode.nodeData{'Settings'}{'doCalibration'}, ...
      false, ... % this boolean value cooresponds to the doShow argument in topsTreeNodeTopNode.addReadable()
      readables{ii});    
end

% Add writable (TTL out). See topsTaskHelperTTL for details.
if topNode.nodeData{'Settings'}{'sendTTLs'}
    topNode.addHelpers('TTL', @dotsWritableDOutLabJack);
end

%% ---- Make call lists to show text/images between tasks
%
%  Use the sharedHelper screenEnsemble
%
% Welcome call list
paceStr = '';
strs = { ...
    'dotsReadableEye',         paceStr, ''; ...
    'dotsReadableHIDGamepad',  paceStr, ''; ...
    'dotsReadableHIDButtons',  paceStr, ''; ...
    'dotsReadableHIDKeyboard', paceStr, ''; ...
    'default',                 '', ''};
for index = 1:size(strs,1)
    if ~isempty(topNode.getHelperByClassName(strs{index,1}))
        break;
    end
end

%% ---- Loop through the task specs array, making tasks with appropriate arg lists
%
taskSpecs = topNode.nodeData{'Settings'}{'taskSpecs'};
noDots    = true;

blockList = readDefaultPairSequence('lowFirst');  % the taskTypeID below matches the order of the lowFirst pair sequence
num_pairs = length(blockList);
blockList{num_pairs + 1} = 'TutReport';
blockList{num_pairs + 2} = 'TutPrediction';

taskCounter =1;
for ii = 1:2
    if ii == 1 && strcmp(type, 'rep')
        trialIter = 10; % tutorial report
    elseif ii == 1 && strcmp(type, 'pred')
        trialIter = 40;  % tutorial prediction
    else
        trialIter = 205;  % task
        topNode.nodeData{'Settings'}{'showFeedback'} = 0;
        topNode.nodeData{'Settings'}{'showSmileyFace'} = 0;
    end
    blockName = taskSpecs{1}{ii};
    % Make list of properties to send
    args = {blockName, ...   
        'trialIterations',                  trialIter, ...
        {'timing',   'showInstructions'},   topNode.nodeData{'Settings'}{'instructionDuration'}, ...
        {'timing',   'showFeedback'},       topNode.nodeData{'Settings'}{'showFeedback'}, ...
        {'timing',   'showSmileyFace'},     topNode.nodeData{'Settings'}{'showSmileyFace'}, ...
        'taskID',                           taskCounter, ...
        'taskTypeID',  firstmatch(blockList, blockName)};
    
   
    % Make Audio2AFCCP task with args
    task = topsTreeNodeTaskAudio2AFCCP.getStandardConfiguration(args{:});
    
    % Add special instructions for first dots task
    if noDots
        task.settings.textStrings = cat(1, ...
            {'', ...
            ''}, ...
            task.settings.textStrings);
        noDots = false;
    end
    
    task.settings.subjectCode = topNode.nodeData{'Settings'}{'subjectCode'};
    task.settings.buttonBox = topNode.nodeData{'Settings'}{'buttonBox'};
    
    trial_folder = [blockName, '/'];
    % Special case of quest ... use output as coh/RT refs

    task.trialSettings.loadFromFile = true;
    task.trialSettings.numTrials = trialIter;
    task.trialSettings.csvFile = [trial_folder, blockName, '.csv'];
    task.trialSettings.jsonFile = [trial_folder, blockName, '_metadata.json'];
    task.setReportProperty(topNode.nodeData{'Settings'}{'isReport'})
    task.setPredictNextSourceProperty(topNode.nodeData{'Settings'}{'predictSource'});
    
    % Add as child to the maintask.
    topNode.addChild(task);
    taskCounter = taskCounter + 1;
end
