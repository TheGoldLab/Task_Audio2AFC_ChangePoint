classdef topsTreeNodeTaskAudio2AFCCP < topsTreeNodeTask
    % @class topsTreeNodeTaskAudio2AFCCP
    %
    % Auditory change-point task
    %
    % For standard configurations, call:
    %  topsTreeNodeTaskAudio2AFCCP.getStandardConfiguration
    %
    % 06/13/19 created by aer 
 
    properties % (SetObservable) % uncomment if adding listeners
        
        settings = struct( ...
            'directionPriors',            [],   ... % put [80 20] for asymmetric priors for instance
            'referenceRT',                [],   ...
            'fixationRTDim',              0.4,  ...
            'targetDistance',             8,    ...
            'textStrings',                '',   ...
            'correctImageIndex',          1,    ...
            'errorImageIndex',            3,    ...
            'errorTooSlowImageIndex',     4,    ... % see topsTaskHelperFeedback
            'correctPlayableIndex',       3,    ...
            'errorPlayableIndex',         4);
        
        % settings about the trial sequence to use
        trialSettings = struct( ...
            'numTrials',        400, ... % theoretical number of valid trials per block
            'loadFromFile',     true,      ... % load trial sequence from files?
            'csvFile',          'Blocks001/Block1.csv',  ... % file of the form filename.csv
            'jsonFile',         'Blocks001/Block1_metadata.json');  ... % file of the form filename_metadata.json
            
        % Timing properties, referenced in statelist
        timing = struct( ...
            'showInstructions',          10.0, ...
            'waitAfterInstructions',     0.5, ...
            'fixationTimeout',           5.0, ...
            'holdFixation',              0.5, ...
            'showSmileyFace',            0,   ...
            'showFeedback',              1.0, ...
            'interTrialInterval',        1.0, ...
            'preStim',                   .2,  ...%[0.2 0.5 1.0], ...
            'dotsDuration',              [],   ...
            'dotsTimeout',               5.0, ...
            'choiceTimeout',             3.0);
        
        % Fields below are optional but if found with the given names
        %  will be used to automatically configure the task
        
        % Array of structures of independent variables, used by makeTrials
        independentVariables = struct( ...
            'name',        {'direction'}, ...
            'values',      {[0 180]}, ...
            'priors',      {[], []});
        
        % dataFieldNames are used to set up the trialData structure
        trialDataFields = {...
            'RT', ...
            'choice', ...
            'correct', ...
            'direction', ...
            'source', ...
            'catch', ...
            'randSeedBase', ...
            'fixationOn', ...
            'fixationStart', ...
            'targetOn', ...
            'soundOn', ...
            'choiceTime', ...
            'secondChoiceTime', ...
            'targetOff', ...
            'fixationOff', ...
            'feedbackOn', ...
            'dirReleaseChoiceTime'};
        
        % Drawables settings
        drawable = struct( ...
            ...
            ...   % Stimulus ensemble and settings
            'stimulusEnsemble',              struct( ...
            ...
            ...   % Fixation drawable settings
            'fixation',                   struct( ...
            'fevalable',                  @dotsDrawableTargets, ...
            'settings',                   struct( ...
            'xCenter',                    0,                ...
            'yCenter',                    0,                ...
            'nSides',                     4,                ...
            'width',                      3.0.*[1.0 0.1],   ...
            'height',                     3.0.*[0.1 1.0],   ...
            'colors',                     [1 1 1])),        ...
            ...
            ...   % Targets drawable settings
            'targets',                    struct( ...
            'fevalable',                  @dotsDrawableTargets, ...
            'settings',                   struct( ...
            'nSides',                     100,              ...
            'width',                      1.5.*[1 1],       ...
            'height',                     1.5.*[1 1])),      ...
            ...
            ...   % Smiley face for feedback
            'smiley',                     struct(  ...
            'fevalable',                  @dotsDrawableImages, ...
            'settings',                   struct( ...
            'fileNames',                  {{'smiley.jpg'}}, ...
            'height',                     2))));
        
        % Playables settings
        playable = struct( ...
            ...
            ...   % Stimulus ensemble and settings
            'audStimulusEnsemble',              struct( ...
            ...
            ...   % Sound settings
            'sound',                    struct( ...
            'fevalable',                  @dotsPlayableTone, ...
            'settings',                   struct( ...
            'frequency',                  500,                ...
            'duration',                   .3,                ... % 300 msec
            'intensity',                  .02))));     
        
        % Readable settings
        readable = struct( ...
            ...
            ...   % The readable object
            'reader',                    	struct( ...
            ...
            'copySpecs',                  struct( ...
            ...
            ...   % The gaze windows
            'dotsReadableEye',            struct( ...
            'bindingNames',               'stimulusEnsemble', ...
            'prepare',                    {{@updateGazeWindows}}, ...
            'start',                      {{@defineEventsFromStruct, struct( ...
            'name',                       {'holdFixation', 'breakFixation', 'choseLeft', 'choseRight'}, ...
            'ensemble',                   {'stimulusEnsemble', 'stimulusEnsemble', 'stimulusEnsemble', 'stimulusEnsemble'}, ... % ensemble object to bind to
            'ensembleIndices',            {[1 1], [1 1], [2 1], [2 2]})}}), ...
            ...
            ...   % The keyboard events .. 'uiType' is used to conditinally use these depending on the theObject type
            'dotsReadableHIDKeyboard',    struct( ...
            'start',                      {{@defineEventsFromStruct, struct( ...
            'name',                       {'holdFixation', 'choseLeft', 'choseRight'}, ...
            'component',                  {'KeyboardSpacebar', 'KeyboardLeftArrow', 'KeyboardRightArrow'}, ...
            'isRelease',                  {true, false, false})}}), ...
            ...
            ...   % Gamepad
            'dotsReadableHIDGamepad',     struct( ...
            'start',                      {{@defineEventsFromStruct, struct( ...
            'name',                       {'holdFixation', ...  % A button
                                            'choseLeft', ...    % left trigger
                                            'choseRight', ...   % right trigger
                                            'startTask', ...    % B button
                                            'choseCP', ...      % X button
                                            'choseNOCP'}, ...   % Y button
            'component',                  {'Button1', ...  % button ID 3
                                            'Trigger1', ...% button ID 7
                                            'Trigger2', ...% button ID 8
                                            'Button2', ... % button ID 4
                                            'Button3', ... % button ID 5
                                            'Button4'}, ...% button ID 6
            'isRelease',                  {true, ...
                                           false, ...
                                           false, ...
                                           false, ...
                                           false, ...
                                           false})}}), ...
            ...
            ...   % Ashwin's magic buttons
            'dotsReadableHIDButtons',     struct( ...
            'start',                      {{@defineEventsFromStruct, struct( ...
            'name',                       {'holdFixation', 'choseLeft', 'choseRight'}, ...
            'component',                  {'KeyboardSpacebar', 'KeyboardLeftShift', 'KeyboardRightShift'}, ...
            'isRelease',                  {true, false, false})}}), ...
            ...
            ...   % Dummy to run in demo mode
            'dotsReadableDummy',          struct( ...
            'start',                      {{@defineEventsFromStruct, struct( ...
            'name',                       {'holdFixation'}, ...
            'component',                  {'auto_1'})}}))));
    end
    
    properties (SetAccess = protected)
        % Boolean flag, whether the trial is catch trial or not
        isCatch;
                
        % Boolean flag, whether an RT task or not
        isRT;
        isReportTask;
        isPredictionTask;
        
        % Check for changes in properties that require drawables to be
        %  recomputed
        targetDistance;
    end
    
    methods
        
        %% Constuctor
        %  Use topsTreeNodeTask method, which can parse the argument list
        %  that can set properties (even those nested in structs)
        function self = topsTreeNodeTaskAudio2AFCCP(varargin)
            
            % ---- Make it from the superclass
            %
            self = self@topsTreeNodeTask(varargin{:});
        end
        
        %% Make trials (overloaded)
        % this method exists in the super class, but for now, I reimplement
        % it as I find it to be buggy in the superclass.
        %
        %  Utility to make trialData array using array of structs (independentVariables),
        %     which must be a property of the given task with fields:
        %
        %     1. name: string name
        %     2. values: vector of unique values
        %     3. priors: vector of priors (or empty for equal priors)
        %
        %  trialIterations is number of repeats of each combination of
        %     independent variables
        %
        function makeTrials(self, ~, ~)
            trialsTable = ...
                readtable(self.trialSettings.csvFile);
            metaData = ...
                loadjson(self.trialSettings.jsonFile);
            
            % set values that are common to all trials
            self.trialSettings.numTrials = self.trialIterations;
            ntr = self.trialSettings.numTrials;
            
            % produce copies of trialData struct to render it ntr x 1
            self.trialData = repmat(self.trialData(1), ntr, 1);
            
            % taskID
            [self.trialData.taskID] = deal(self.taskID);
            
            % condProbCP
            [self.trialData.hazard] = ...
                deal(metaData.hazard);
            
            % condProbCP
            [self.trialData.meta_hazard] = ...
                deal(metaData.meta_hazard);
            
            trlist = num2cell(1:ntr);
            
            % trialIndex
            [self.trialData.trialIndex] = deal(trlist{:});
            
            % set values that are specific to each trial
            for tr = 1:ntr
                % sound location
                if strcmp(trialsTable.soundLoc(tr), 'left')
                    self.trialData(tr).direction = 180;
                else
                    self.trialData(tr).direction = 0;
                end
                
                % source location
                if strcmp(trialsTable.sourceLoc(tr), 'left')
                    self.trialData(tr).source = 180;
                else
                    self.trialData(tr).source = 0;
                end
                
                
                % catch trial
                if strcmp(trialsTable.isCatch(tr), 'True')
                    self.trialData(tr).catch = 1.0; % numeric for FIRA
                else
                    self.trialData(tr).catch = 0;
                end
            end
        end
        
        
        %% Start task (overloaded)
        %
        % Put stuff here that you want to do before each time you run this
        % task
        function startTask(self)
            % manually add dummy events related to x and y directions of
            % directional cross on gamepad
            readableObj = self.helpers.reader.theObject;
            if isa(readableObj,'dotsReadableHIDGamepad')
                readableObj.defineEvent('x', 'component', 9);
                readableObj.defineEvent('y', 'component', 10);
            end
            
            self.trialIterationMethod = 'sequential';  % enforce sequential
            self.randomizeWhenRepeating = false;
            
            % ---- Initialize the state machine
            %
            self.initializeStateMachine();
            
            % ---- Show task-specific instructions
            %
%             self.helpers.feedback.show('text', self.settings.textStrings, ...
%                 'showDuration', self.timing.showInstructions);
%             pause(self.timing.waitAfterInstructions);
        end
        
        %% Finish task (overloaded)
        %
        % Put stuff here that you want to do after each time you run this
        % task
        function finishTask(self)
        end
        
        %% Start trial
        %
        % Put stuff here that you want to do before each time you run a trial
        function startTrial(self)
            
            % ---- Prepare components
            %
            self.prepareDrawables();
            self.preparePlayables();
            self.prepareStateMachine();
            
            % ---- Inactivate all of the readable events
            %
            self.helpers.reader.theObject.deactivateEvents();
            
            % ---- Show information about the task/trial
            %
            % Task information
            taskString = sprintf('%s (task %d/%d): %d correct, %d error, mean RT=%.2f', ...
                self.name, self.taskID, length(self.caller.children), ...
                sum([self.trialData.correct]==1), sum([self.trialData.correct]==0), ...
                nanmean([self.trialData.RT]));
            
            % Trial information
            trial = self.getTrial();
            
            self.isCatch = trial.catch == 1;
            
            trialString = sprintf('Trial %d/%d, dir=%d, src=%d, catch=%d', ...
                self.trialCount, numel(self.trialData), ...
                trial.direction, trial.source, trial.catch);
            
            % Show the information
            self.statusStrings = {taskString, trialString};
            self.updateStatus(); % just update the second one
        end
        
        %% Finish Trial
        %
        % Could add stuff here
        function finishTrial(self)
        end
        
        %% Check for choice
        %
        % Save choice/RT information and set up feedback for the dots task
        function nextState = checkForChoice(self, events, eventTag)
            
            % ---- Check for event
            %
            eventName = self.helpers.reader.readEvent(events, self, eventTag);
            
            % Nothing... keep checking
            if isempty(eventName)
                nextState = [];
                return
            end
            
            % Jump to next state when done
            if self.isCatch
                % TO DO
                nextState = 'waitForReleasFX';
            else
                nextState = 'blank';
                % Override completedTrial flag
                self.completedTrial = true;
            end
            
            % Get current task/trial
            trial = self.getTrial();
            
            % Save the choice
            trial.choice = double(strcmp(eventName, 'choseRight'));
            
            % Mark as correct/error
            if self.isReportTask
                trial.correct = double( ...
                    (trial.choice==0 && trial.direction==180) || ...
                    (trial.choice==1 && trial.direction==0));
            elseif self.isPredictionTask
                % get total num of trials
                % check current trial is not the last one
                % get source of next trial in queue
                % compare answer to aforementioned source
                % decide whether correct or not
            end
            
            % Compute/save RT, wrt dotsOn for RT, dotsOff for non-RT
            if self.isRT
                trial.RT = trial.choiceTime - trial.soundOn;
            end
            
            % ---- Re-save the trial
            %
            self.setTrial(trial);
            
            % ---- Possibly show smiley face
            if trial.correct == 1 && self.timing.showSmileyFace > 0 && ~self.isCatch
                self.helpers.stimulusEnsemble.draw({3, [1 2 4]});
                pause(self.timing.showSmileyFace);
            end
        end
        
        %% Check for catch choice
        %
        % Save choice/RT information and set up feedback for the dots task
        function nextState = checkForCatchChoice(self, events, eventTag)
            
            % ---- Check for event
            %
            eventName = self.helpers.reader.readEvent(events, self, eventTag);
            
            % Nothing... keep checking
            if isempty(eventName)
                nextState = [];
                return
            end
            
            
            nextState = 'blank';
            % Override completedTrial flag
            self.completedTrial = true;
            
            % ---- Possibly show smiley face
            if trial.correct == 1 && self.timing.showSmileyFace > 0
                self.helpers.stimulusEnsemble.draw({3, [1 2 4]});
                pause(self.timing.showSmileyFace);
            end
        end
        %% Check for direction choice trigger Release
        %
        % Save choice/RT information and set up feedback for the dots task
        function nextState = checkForReleaseDirChoice(self, events, eventTag)
            
            % ---- Check for event
            %
%             self.helpers.reader.theObject.flushData()
%             self.helpers.reader.theObject.setEventsActiveFlag(events)
            eventName = self.helpers.reader.readEvent(events, self, eventTag);
            
            % Nothing... keep checking
            if isempty(eventName)
                nextState = [];
                return
            end
            
            % Jump to next state when done
            nextState = 'secondChoice';

            
        end
        
        %% Show feedback
        %
        function showFeedback(self)
            
            % Get current task/trial
            trial = self.getTrial();
            
            %  Check for RT feedback
            RTstr = '';
            imageIndex = self.settings.correctImageIndex;
            if self.name(1) == 'S'
                
                % Check current RT relative to the reference value
                if isa(self.settings.referenceRT, 'topsTreeNodeTaskRTDots')
                    RTRefValue = self.settings.referenceRT.settings.referenceRT;
                else
                    RTRefValue = self.settings.referenceRT;
                end
                
                if isfinite(RTRefValue)
                    if trial.RT <= RTRefValue
                        RTstr = ', in time';
                    else
                        RTstr = ', try to decide faster';
                        imageIndex = self.settings.errorTooSlowImageIndex;
                    end
                end
            end
            
            % Set up feedback based on outcome
            if trial.correct == 1
                feedbackStr = 'Correct';
                feedbackArgs = { ...
                    'text',  [feedbackStr RTstr], ...
                    'image', imageIndex};
                feedbackColor = [0 0.6 0];

            elseif trial.correct == 0
                feedbackStr = 'Error';
                feedbackArgs = { ...
                    'text',  [feedbackStr RTstr], ...
                    'image', self.settings.errorImageIndex};
                feedbackColor = [1 0 0];
            else
                feedbackStr = 'No choice';
                feedbackArgs = {'text', 'No choice, please try again.'};
                feedbackColor = [0 0 0];
            end
            
            % --- Show trial feedback in GUI/text window
            %
            self.statusStrings{2} = ...
                sprintf('Trial %d/%d, dir=%d: %s, RT=%.2f', ...
                self.trialCount, numel(self.trialData), ...
                trial.direction, feedbackStr, trial.RT);
            self.updateStatus(2); % just update the second one
            
            % --- Show trial feedback on the screen
            %
            dotsTheScreen.blankScreen(feedbackColor);
            self.helpers.feedback.show(feedbackArgs{:});
            dotsTheScreen.blankScreen([0 0 0]);
        end
    end
    
    methods (Access = protected)
        
        %% Prepare drawables for this trial
        %
        function prepareDrawables(self)
            
            % ---- Get the current trial and the stimulus ensemble
            %
            trial    = self.getTrial();
            ensemble = self.helpers.stimulusEnsemble.theObject;
            
            % ----- Get target locations
            %
            %  Determined relative to fp location
            fpX = ensemble.getObjectProperty('xCenter', 1);
            fpY = ensemble.getObjectProperty('yCenter', 1);
            td  = self.settings.targetDistance;
            
            % ---- Possibly update all stimulusEnsemble objects if settings
            %        changed
            %
            if isempty(self.targetDistance) || ...
                    self.targetDistance ~= self.settings.targetDistance
                
                % Save current value(s)
                self.targetDistance = self.settings.targetDistance;
                
                %  Now set the target x,y
                ensemble.setObjectProperty('xCenter', [fpX - td, fpX + td], 2);
                ensemble.setObjectProperty('yCenter', [fpY fpY], 2);
            end
            
            % ---- Set a new seed base for the dots random-number process
            %
            trial.randSeedBase = randi(9999);
            self.setTrial(trial);
            
            % ---- Possibly update smiley face to location of correct target
            %
            if self.timing.showSmileyFace > 0
                
                % Set x,y
                ensemble.setObjectProperty('x', fpX + sign(cosd(trial.direction))*td, 3);
                ensemble.setObjectProperty('y', fpY, 3);
            end
            
            % ---- Prepare to draw dots stimulus
            %
%             ensemble.callObjectMethod(@prepareToDrawInWindow);
        end
        
        
        %% Prepare drawables for this trial
        %
        function preparePlayables(self)
            
            % ---- Get the current trial and the stimulus ensemble
            %
            trial    = self.getTrial();
            ensemble = self.helpers.audStimulusEnsemble.theObject;
            
            % ---- Save sound properties
            %
            if trial.direction == 0
                side_str = 'right';
            else % 180
                side_str = 'left';
            end
            ensemble.side = side_str;
                        
            self.setTrial(trial);
            
            % ---- Prepare to play audio stimulus
            %
            ensemble.prepareToPlay();
        end
        
        %% Prepare stateMachine for this trial
        %
        function prepareStateMachine(self)
            
            % ---- Set RT/deadline
            %
            self.isRT = true;
            self.isReportTask = true;
        end
        
        %% shorten sound duration
        function modifySound(self)
            % get the sound object
            self.helpers.audStimulusEnsemble.theObject.duration = .01; % 10 msec
        end
        
        function resetSound(self)
            % get the sound object
            self.helpers.audStimulusEnsemble.theObject.duration = .3; % 300 msec
        end
        function dispWaintingText1(self, stringarg)
            self.helpers.feedback.show('text', ...
                stringarg, ...
                'showDuration', 3.5, ...
                'blank', true);
        end
        %% Initialize StateMachine
        %
        function initializeStateMachine(self)
            
            % ---- Fevalables for state list
            %
            dnow    = {@drawnow};
            blanks  = {@dotsTheScreen.blankScreen};
%             chkuif  = {@getNextEvent, self.helpers.reader.theObject, false, {'holdFixation'}};
%             chkuib  = {}; % {@getNextEvent, self.readables.theObject, false, {}}; % {'brokeFixation'}
            chkuic  = {@checkForChoice, self, {'choseLeft' 'choseRight'}, 'choiceTime'};
            chkuic2  = {@checkForReleaseDirChoice, self, {'choseLeft' 'choseRight'}, 'dirReleaseChoiceTime'};
            chkuic3  = {@checkForCatchChoice, self, {'choseLeft' 'choseRight'}, 'secondChoiceTime'};
            showfx  = {@draw, self.helpers.stimulusEnsemble, {{'colors', ...
                [1 1 1], 1}, {'isVisible', true, 1}, {'isVisible', false, [2 3]}},  self, 'fixationOn'};
%             showt   = {@draw, self.helpers.stimulusEnsemble, {2, []}, self, 'targetOn'};
            showfb  = {@showFeedback, self};
            plays = {@startPlaying, self.helpers.audStimulusEnsemble, self, 'soundOn'};
            hided   = {@draw,self.helpers.stimulusEnsemble, {[], 1}, self, 'fixationOff'};
            mdfs = {@modifySound, self};
            rsts = {@resetSound, self};
            pdbr = {@setNextState, self, 'isCatch', 'playSound', 'catchSound', 'waitForChoiceFX'};
            wtng = {@dispWaintingText1, self, 'waiting for response'};
            gdby = {@dispWaintingText1, self, 'good bye'};
            % drift correction
%             hfdc  = {@reset, self.helpers.reader.theObject, true};
            
            % Activate/deactivate readable events
            sea   = @setEventsActiveFlag;
%             gwfxw = {sea, self.helpers.reader.theObject, 'holdFixation'};
%             gwfxh = {};
            gwts  = {sea, self.helpers.reader.theObject, {'choseLeft', 'choseRight'}};
            
            % ---- Timing variables, read directly from the timing property struct
            %
            t = self.timing;
            
            % ---- Make the state machine. These will be added into the
            %        stateMachine (in topsTreeNode)
            %
            states = {...
                'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
                'showFixation'      showfx   {}       0                     pdbr       'preStim'         ; ...
%                 'waitForFixation'   gwfxw    chkuif   t.fixationTimeout     {}      'blankNoFeedback' ; ...
%                 'holdFixation'      gwfxh    chkuib   t.holdFixation        hfdc    'showTargets'     ; ...
%                 'showTargets'       showt    chkuib  0                   gwts    'preDots'         ; ...
                'preStim'           {}       {}       t.preStim             gwts       'playSound'       ; ...
                'playSound'         plays    {}       0                     mdfs       ''                ; ...
                'catchSound'        plays    {}       t.dotsTimeout         rsts       'waitForChoiceFX' ; ...
                'waitForChoiceFX'   {}     chkuic   t.choiceTimeout       {}       'blank'           ; ...
                'waitForReleasFX'   hided    chkuic2  t.choiceTimeout       {}         ''                ; ...
                'secondChoice'      hided    chkuic3  t.choiceTimeout       {}         'blank'           ; ...
                'blank'             {}       {}       0.2                   blanks     'showFeedback'    ; ...
                'showFeedback'      showfb   {}       t.showFeedback        blanks     'done'            ; ...
                'blankNoFeedback'   {}       {}       0                     blanks     'done'            ; ...
                'done'              dnow     {}       t.interTrialInterval  {}         ''                ; ...
                };
            
            % ---- Set up ensemble activation list. This determines which
            %        states will correspond to automatic, repeated calls to
            %        the given ensemble methods
            %
            % See topsActivateEnsemblesByState for details.
            activeList = [];
%             {{ ...
%                 self.helpers.stimulusEnsemble.theObject, 'draw'; ...
%                 self.helpers.screenEnsemble.theObject, 'flip'}, ...
%                 {'preDots'}};
            
            % --- List of children to add to the stateMachineComposite
            %        (the state list above is added automatically)
            %
            compositeChildren = { ...
                self.helpers.stimulusEnsemble.theObject, ...
                self.helpers.screenEnsemble.theObject};
            
            % Call utility to set up the state machine
            self.addStateMachine(states, activeList, compositeChildren);
        end
    end
    
    methods (Static)
        
        %% ---- Utility for defining standard configurations
        %
        % name is string:
        %  'Quest' for adaptive threshold procedure
        %  or '<SAT><BIAS>' tag, where:
        %     <SAT> is 'N' for neutral, 'S' for speed, 'A' for accuracy
        %     <BIAS> is 'N' for neutral, 'L' for left more likely, 'R' for
        %     right more likely
        function task = getStandardConfiguration(name, varargin)
            
            % ---- Get the task object, with optional property/value pairs
            %
            task = topsTreeNodeTaskAudio2AFCCP(name, varargin{:});
            
%             % ---- Instruction settings, by column:
%             %  1. tag (first character of name)
%             %  2. Text string #1
%             %  3. RTFeedback flag
%             %
%             SATsettings = { ...
%                 'S' 'Be as FAST as possible.'                 task.settings.referenceRT; ...
%                 'A' 'Be as ACCURATE as possible.'             nan;...
%                 'N' 'Be as FAST and ACCURATE as possible.'    nan};
%             
%             dp = task.settings.directionPriors;
%             BIASsettings = { ...
%                 'L' 'Left is more likely.'                    [max(dp) min(dp)]; ...
%                 'R' 'Right is more likely.'                   [min(dp) max(dp)]; ...
%                 'N' 'Both directions are equally likely.'     [50 50]};
%                     
%             % ---- Set strings, priors based on type
%             %
%             Lsat  = strcmp(name(1), SATsettings(:,1));
%             Lbias = strcmp(name(2), BIASsettings(:,1));
%             task.settings.textStrings = {SATsettings{Lsat, 2}, BIASsettings{Lbias, 2}};
%             task.settings.referenceRT = SATsettings{Lsat, 3};
% %             task.setIndependentVariableByName('direction', 'priors', BIASsettings{Lbias, 3});
        end
    end
end
