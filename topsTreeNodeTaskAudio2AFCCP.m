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
            'unselectedTargetOff', ...
            'fixationOn', ...
            'fixationBlue', ...
            'targetOn', ...
            'sound1On', ...
            'sound2On', ...
            'sound1Off', ...
            'sound2Off', ...
            'sourceOn', ...
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
            'targetLeft',                    struct( ...
            'fevalable',                  @dotsDrawableTargets, ...
            'settings',                   struct( ...
            'nSides',                     100,              ...
            'width',                      2*[1 1],       ...
            'height',                     2*[1 1])),      ...
            ...
            ...   % Smiley face for feedback
            'smiley',                     struct(  ...
            'fevalable',                  @dotsDrawableImages, ...
            'settings',                   struct( ...
            'fileNames',                  {{'smiley.jpg'}}, ...
            'height',                     2)), ...
             ...
            'targetRight',                struct( ...
            'fevalable',                  @dotsDrawableTargets, ...
            'settings',                   struct( ...
            'nSides',                     100,              ...
            'width',                      2*[1 1],       ...
            'height',                     2*[1 1]))));
        
        % Playables settings
        playable = struct( ...
            ...
            ...   % Stimulus ensemble and settings
            'audStimulusEnsemble',              struct( ...
            ...
            ...   % Sound settings
            'sound',                    struct( ...
            'fevalable',                  @dotsCustomPlayableTone, ...
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
             ...   % single-hand buttons
             'dotsReadableHIDButtons',     struct( ...
             'start',                      {@disp, 'doing nothing'}), ...
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
                
        % if false, then task is prediction task about the next sound location
        % if true, then task is report the location of the last sound
        isReportTask;  
        
        % if prediction task, is the correct response based on predicting
        % the next sound or the next source?
        isPredictNextSource;
        
        % Check for changes in properties that require drawables to be
        %  recomputed
        targetDistance;
        
        trueSource;
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
        
        
        function setReportProperty(self, boolVal)
            self.isReportTask = boolVal;
            if boolVal
                self.setPredictNextSourceProperty(false)
            end
        end
        
        function setPredictNextSourceProperty(self, boolVal)
            self.isPredictNextSource = boolVal;
            if boolVal
                self.setReportProperty(false)
            end
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
%             metaData = ...
%                 loadjson(self.trialSettings.jsonFile);
            
            % set values that are common to all trials
            self.trialSettings.numTrials = self.trialIterations;
            ntr = self.trialSettings.numTrials;
            
            % produce copies of trialData struct to render it ntr x 1
            self.trialData = repmat(self.trialData(1), ntr, 1);
            
            % taskID
            [self.trialData.taskID] = deal(self.taskID);
            
%             % condProbCP
%             [self.trialData.hazard] = ...
%                 deal(metaData.hazard);
%             
%             % condProbCP
%             [self.trialData.meta_hazard] = ...
%                 deal(metaData.meta_hazard);
            
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
                    if self.isReportTask
                        self.trialData(tr).catch = 1.0; % numeric for FIRA
                    else
                        self.trialData(tr).catch = 0;
                    end
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
            elseif isa(readableObj, 'dotsReadableHIDButtons')
                IDs = readableObj.getComponentIDs();
                for ii = 1:numel(IDs)
                    try
                        eventName = readableObj.components(ii).name;
                        if strcmp(eventName, 'Button1')
                            eventName = 'choseLeft';
                        elseif strcmp(eventName, 'Button2')
                            eventName = 'choseRight';
                        end
                        readableObj.defineEvent(eventName, 'component', IDs(ii));
                    catch
                        warning(['pb with ',readableObj.components(ii).name])
                    end
                end
                for i=1:length(readableObj.eventDefinitions)
                    readableObj.eventDefinitions(i).isActive = 1;
                end
                readableObj.isAutoRead = true;
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
        
        function earlyEventWarning(self, events)
            eventName = self.helpers.reader.readEvent(events, self, 'choiceTime');
%             disp(eventName)
            if ~isempty(eventName)
                
                % Get current task/trial
                trial = self.getTrial();
                trial.RT = trial.choiceTime - trial.sound1Off;
                % Save the choice
                trial.choice = double(strcmp(eventName, 'choseRight'));
                % ---- Re-save the trial
                self.setTrial(trial);
                
                self.stateMachine.editStateByName('earlyEvents', 'next', 'blankNoFeedback');
%                 self.stateMachine.editStateByName('earlyEvents', 'exit', ...
%                 {@draw,self.helpers.stimulusEnsemble, {[], 1}, self, 'fixationOff'});
            
                pause(0.1)
                
                self.helpers.stimulusEnsemble.draw({[], 1}, self, 'fixationOff');
                self.helpers.feedback.show('text', ...
                    {'You answered too soon.', ...
                    'Please wait until sound finishes.'}, ...
                    'showDuration', 4, ...
                    'blank', true);
            else
%                 disp('entered no early event case')
                if self.isCatch
                    self.stateMachine.editStateByName('earlyEvents', 'next', 'catchSound');
                else
                    self.stateMachine.editStateByName('earlyEvents', 'next', 'waitForChoiceFX');
                end
%                 self.stateMachine.editStateByName('earlyEvents', 'exit', {});
            end
                      
            self.flushEventsQueue()
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
            
            trial = self.getTrial();
            
            if self.isReportTask
                trial.RT = trial.choiceTime - trial.sound1Off;
            else
                trial.RT = trial.choiceTime - trial.fixationOn;
            end
            
            trial.choice = double(strcmp(eventName, 'choseRight'));

            %
            %             if trial.RT < 0 || isnan(trial.RT)
            %                 % this whole block should be redundant now
            %                 nextState = 'waitForReleasFX';
            %                 pause(0.1)
            %                 self.helpers.feedback.show('text', ...
            %                     {'You answered too soon.', ...
            %                      'Please wait until the cross turns blue.'}, ...
            %                      'showDuration', 4, ...
            %                      'blank', true);
            %             else
            % Jump to next state when done
            if self.isCatch
                nextState = 'waitForReleasFX';
            else
                if self.isReportTask
                    nextState = 'blank';
                else
                    nextState = 'delay';
                end
                
                % Override completedTrial flag
                self.completedTrial = true;
            end
            
            % Mark as correct/error
            if self.isReportTask
                trial.correct = double( ...
                    (trial.choice==0 && trial.direction==180) || ...
                    (trial.choice==1 && trial.direction==0));
            else
                
                
                if self.isPredictNextSource
                    refSide = trial.source;  % predict next source
                else
                    refSide = trial.direction; % predict next sound
                end
                % compare answer to aforementioned source or sound
                % decide whether correct or not
                trial.correct = double( ...
                    (trial.choice==0 && refSide==180) || ...
                    (trial.choice==1 && refSide==0));
                
            end
            %                 % ---- Possibly show smiley face
            %                 if (trial.correct == 1) ...
            %                         && (self.timing.showSmileyFace > 0) ...
            %                         && (~self.isCatch) ...
            %                         && (self.isReportTask || ...
            %                         (~self.isReportTask && ~lastTrial))
            %
            %                     self.helpers.stimulusEnsemble.draw( ...
            %                         {'isVisible', true, 3}, ...
            %                         {'isVisible', false, [1 2 4]});
            %                     pause(self.timing.showSmileyFace);
            %                 end
            %             end
            
            
            
            % ---- Re-save the trial
            %
            self.setTrial(trial);
            
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
            
            if self.isReportTask
                nextState = 'blank';
            else
                nextState = 'delay';
            end
            % Override completedTrial flag
            self.completedTrial = true;
            
            trial = self.getTrial();
            
            % COMPUTE correct TRIAL
            if trial.choice == 0
                firstChoice = 'choseLeft';
            elseif trial.choice == 1
                firstChoice = 'choseRight';
            end
            if ~strcmp(eventName, firstChoice)  % second button press doesn't match the first one
                trial.correct = 0;
                self.setTrial(trial)
                pause(0.1)
                self.helpers.feedback.show('text', ...
                    {'On catch trials you should press the same button twice.'}, ...
                    'showDuration', 4, ...
                    'blank', true);
            end
            
%             totTrials = numel(self.trialData);
%             isLastTrial = (totTrials == trial.trialIndex);
%             skipFb = ~self.isReportTask && isLastTrial;  
%             
%             % ---- Possibly show smiley face
%             if trial.correct == 1 && self.timing.showSmileyFace > 0 ...
%                     && ~skipFb
%                 self.helpers.stimulusEnsemble.draw({3, [1 2 4]});
%                 pause(self.timing.showSmileyFace);
%             end
%             
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
            if self.isCatch
                nextState = 'secondChoice';
            else
                nextState = 'blank';
            end
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
                    'image', imageIndex, ...
                    'eventTag', 'feedbackOn'};
                feedbackColor = [0 0.6 0];

            elseif trial.correct == 0
                feedbackStr = 'Error';
                feedbackArgs = { ...
                    'text',  [feedbackStr RTstr], ...
                    'image', self.settings.errorImageIndex, ...
                    'eventTag', 'feedbackOn'};
                feedbackColor = [1 0 0];
            else
                feedbackStr = 'No choice';
                feedbackArgs = {'text', 'No choice, please try again.', ...
                    'eventTag', 'feedbackOn'};
                feedbackColor = [0 0 0];
            end
            
            % --- Show trial feedback in GUI/text window
            %
            self.statusStrings{2} = ...
                sprintf('Trial %d/%d, dir=%d: %s, RT=%.2f', ...
                self.trialCount, numel(self.trialData), ...
                trial.direction, feedbackStr, trial.RT);
            self.updateStatus(2); % just update the second one
            
           
            totTrials = numel(self.trialData);
            isLastTrial = (totTrials == trial.trialIndex);
%             skipFb = ~self.isReportTask && isLastTrial;
            skipFb = false;
            
%             % ---- Possibly show smiley face
%             if (trial.correct == 1) ...
%                     && (self.timing.showSmileyFace > 0) ...
%                     && (~self.isCatch) ...
%                     && (self.isReportTask || ...
%                     (~self.isReportTask && ~lastTrial))
%                 
%                 self.helpers.stimulusEnsemble.draw( ...
%                     {'isVisible', true, 3}, ...
%                     {'isVisible', false, [1 2 4]});
%                 pause(self.timing.showSmileyFace);
%             end
            
            
            % --- Show trial feedback on the screen
            %
            if self.timing.showSmileyFace > 0 && ~skipFb
                dotsTheScreen.blankScreen(feedbackColor);
                self.helpers.feedback.show(feedbackArgs{:});
            end
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
                ensemble.setObjectProperty('xCenter', fpX - td, 2);
                ensemble.setObjectProperty('xCenter', fpX + td, 4);
                ensemble.setObjectProperty('yCenter', fpY, 2);
                ensemble.setObjectProperty('yCenter', fpY, 4);
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
        end
        
        %% shorten sound duration
        function modifySound(self)
            % get the sound object
            if self.isCatch
                self.helpers.audStimulusEnsemble.theObject.duration = .05; % 50 msec
                self.helpers.audStimulusEnsemble.theObject.prepareToPlay();
            end
        end
        
        function resetSound(self)
            % get the sound object
            self.helpers.audStimulusEnsemble.theObject.duration = .3; % 300 msec
            self.helpers.audStimulusEnsemble.theObject.prepareToPlay();
        end
        function dispWaintingText1(self, stringarg)
            self.helpers.feedback.show('text', ...
                stringarg, ...
                'showDuration', 3.5, ...
                'blank', true);
        end
        
        function flushEventsQueue(self)
%             disp('flushing event queue')
            [nextEvent, ~] = self.helpers.reader.theObject.getNextEvent();
%             disp(nextEvent)
            while ~isempty(nextEvent)
                [nextEvent, ~] = self.helpers.reader.theObject.getNextEvent();
%                 disp(nextEvent)
            end
        end
        
        
        function prepareTutorialStates(self)
            trial = self.getTrial();
            if trial.trialIndex < 40
                self.stateMachine.editStateByName('showFixation', 'next', 'showSource');
            else
                self.stateMachine.editStateByName('showFixation', 'next', 'waitForChoiceFX');
            end
            self.trueSource = trial.source;
        end
        
        function showTrueSource(self)
            if self.trueSource == 180
                self.helpers.stimulusEnsemble.draw({{'colors', ...
                    [1 0 0], 2}, {'isVisible', true, [2]}, {'isVisible', false, 4}},  self, 'sourceOn');
            else
                self.helpers.stimulusEnsemble.draw({{'colors', ...
                    [0 0 1], 4}, {'isVisible', true, 4}, {'isVisible', false, 2}},  self, 'sourceOn');
            end
        end
        
        function rmUnselectedTarget(self)
            trial = self.getTrial();
            if trial.choice == 0  % if subject chose right target
                self.helpers.stimulusEnsemble.draw({{'colors', ...
                    [1 1 1], 2}, {'isVisible', true, 2}, {'isVisible', false, 4}},  self, 'unselectedTargetOff');
            else
                self.helpers.stimulusEnsemble.draw({{'colors', ...
                    [1 1 1], 4}, {'isVisible', true, 4}, {'isVisible', false, 2}},  self, 'unselectedTargetOff');
            end
        end
        
        %% Initialize StateMachine
        %
        function initializeStateMachine(self)
            
            % ---- Fevalables for state list
            %
            dnow    = {@drawnow};  % this is a MATLAB built-in function
            blanks  = {@dotsTheScreen.blankScreen};
            chkuic  = {@checkForChoice, self, {'choseLeft' 'choseRight'}, 'choiceTime'};
            chkuic2  = {@checkForReleaseDirChoice, self, {'choseLeft' 'choseRight'}, 'dirReleaseChoiceTime'};
            chkuic3  = {@checkForCatchChoice, self, {'choseLeft' 'choseRight'}, 'secondChoiceTime'};
            showfx  = {@draw, self.helpers.stimulusEnsemble, {{'colors', ...
                [1 1 1], 1}, {'isVisible', true, 1}, {'isVisible', false, [2 3 4]}},  self, 'fixationOn'};
            showfxp  = {@draw, self.helpers.stimulusEnsemble, {{'colors', ...
                [1 1 1], [1,2]}, {'isVisible', true, [1, 2, 4]}, {'isVisible', false, 3}},  self, 'fixationOn'};
            rmtgt  = {@rmUnselectedTarget, self};
            shfxb  = {@draw, self.helpers.stimulusEnsemble, {{'colors', ...
                [0 0 1], 1}, {'isVisible', true, 1}, {'isVisible', false, [2 3]}},  self, 'fixationBlue'};
            showfb  = {@showFeedback, self};
            plays1 = {@play, self.helpers.audStimulusEnsemble.theObject, self, 'sound1On', 'sound1Off'};
            plays2 = {@play, self.helpers.audStimulusEnsemble.theObject, self, 'sound2On', 'sound2Off'};
            hided   = {@draw,self.helpers.stimulusEnsemble, {[], [1,2,4]}, self, 'fixationOff'};
            mdfs = {@modifySound, self};
            rsts = {@resetSound, self};
            pdbr = {@setNextState, self, 'isCatch', 'playSound', 'catchSound', 'blank'};
            wtng = {@dispWaintingText1, self, 'waiting for response'};
            gdby = {@dispWaintingText1, self, 'good bye'};
            % drift correction
%             hfdc  = {@reset, self.helpers.reader.theObject, true};
            
            % Activate/deactivate readable events
            sea   = @setEventsActiveFlag;
%             gwfxw = {sea, self.helpers.reader.theObject, 'holdFixation'};
%             gwfxh = {};

            % activate left/right choices events
            gwts  = {sea, self.helpers.reader.theObject, {'choseLeft', 'choseRight'}};
            
            
            flsh = {@flushData, self.helpers.reader.theObject};
            dque = {@flushEventsQueue, self};
            evtwrn = {@earlyEventWarning, self, {'choseLeft', 'choseRight'}};
            
            ppst = {@prepareTutorialStates, self};
            showsc  = {@showTrueSource, self};

            % ---- Timing variables, read directly from the timing property struct
            %
            t = self.timing;
            
            % ---- Make the state machine. These will be added into the
            %        stateMachine (in topsTreeNode)
            %
            if self.isReportTask
                states = {...
                    'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
                    'showFixation'      showfx   {}       t.preStim             gwts       'playSound'       ; ...
                    'playSound'         plays1   {}       0                     mdfs       'earlyEvents'     ; ...
                    'earlyEvents'       evtwrn   {}       0                     {}         ''                ; ...
                    'catchSound'        plays2   {}       0                     rsts       'waitForChoiceFX' ; ...
                    'waitForChoiceFX'   {}       chkuic   t.choiceTimeout       {}         'blank'           ; ...
                    'waitForReleasFX'   {}       chkuic2  t.choiceTimeout       dque       ''                ; ...
                    'secondChoice'      {}       chkuic3  t.choiceTimeout       {}         'blank'           ; ...
                    'blank'             hided    {}       0.2                   {}         'showFeedback'    ; ...
                    'showFeedback'      showfb   {}       t.showFeedback        blanks     'done'            ; ...
                    'blankNoFeedback'   {}       {}       0                     blanks     'done'            ; ...
                    'done'              dnow     {}       t.interTrialInterval  {}         ''                ; ...
                    };
%             elseif strcmp(self.name, 'TutPrediction')
%                 states = {...
%                     'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
%                     'prepareStates'     ppst     {}       0                     {}         'showFixation'    ; ...
%                     'showFixation'      showfx   {}       t.preStim             gwts       'waitForChoiceFX'       ; ...
%                     'waitForChoiceFX'   {}       chkuic   t.choiceTimeout       pdbr       'blank'           ; ...
%                     'waitForReleasFX'   {}       chkuic2  t.choiceTimeout       dque       ''                ; ...
%                     'secondChoice'      {}       chkuic3  t.choiceTimeout       {}         'blank'           ; ...
%                     'showSource'        showsc   {}       0                     {}         'delay'           ; ...
%                     'delay'             {}       {}       .5                    {}         'playSound'       ; ...
%                     'playSound'         plays1   {}       0                     mdfs       ''                ; ...
% %                     'earlyEvents'       evtwrn   {}       0                     {}         ''                ; ...
%                     'catchSound'        plays2   {}       0                     rsts       'blank'           ; ...
%                     'blank'             hided    {}       0.2                   {}         'showFeedback'    ; ...
%                     'showFeedback'      showfb   {}       t.showFeedback        blanks     'done'            ; ...
%                     'blankNoFeedback'   {}       {}       0                     blanks     'done'            ; ...
%                     'done'              dnow     {}       0                     {}         ''                ; ...
%                     };
            else  % prediction block
                states = {...
                    'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
                    'showFixation'      showfxp   {}       t.preStim             gwts       'waitForChoiceFX'       ; ...
                    'waitForChoiceFX'   {}       chkuic   t.choiceTimeout       pdbr       'blank'           ; ...
                    'waitForReleasFX'   {}       chkuic2  t.choiceTimeout       dque       ''                ; ...
                    'secondChoice'      {}       chkuic3  t.choiceTimeout       {}         'blank'           ; ...
                    'delay'             rmtgt    {}       1.5                   {}         'playSound'       ; ...
                    'playSound'         plays1   {}       0                     mdfs       ''                ; ...
%                     'earlyEvents'       evtwrn   {}       0                     {}         ''                ; ...
                    'catchSound'        plays2   {}       0                     rsts       'blank'           ; ...
                    'blank'             hided    {}       0.2                   {}         'showFeedback'    ; ...
                    'showFeedback'      showfb   {}       t.showFeedback        blanks     'done'            ; ...
                    'blankNoFeedback'   {}       {}       0                     blanks     'done'            ; ...
                    'done'              dnow     {}       0                     {}         ''                ; ...
                    };
            end
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
