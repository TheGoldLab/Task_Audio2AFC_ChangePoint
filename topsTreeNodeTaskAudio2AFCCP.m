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
            'errorPlayableIndex',         4,    ...
            'buttonBox',                  'EMU', ... % Gold and EMU are the only two valid strings
            'subjectCode',                '');  
        
        % settings about the trial sequence to use
        trialSettings = struct( ...
            'numTrials',        205, ... % theoretical number of valid trials per block
            'loadFromFile',     true,      ... % load trial sequence from files?
            'csvFile',          'Block001/Block001.csv',  ... % file of the form filename.csv
            'jsonFile',         'Block001/Block001_metadata.json');  ... % file of the form filename_metadata.json
            
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
            'dirReleaseChoiceTime', ...
            'catchChoiceMissing', ...
            'catchChoiceOpposite'};
        
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
            ...   % The readable object
            'reader',                    	struct( ...
            ...
            'copySpecs',                  struct( ...
             ...   % single-hand buttons
             'customButtonsClass',     struct( ...
             'start',                      {{@nullfunc}}))));
         
        metadatafile = 'subj_metadata.json';
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
        
        % additional readable object, useful to catch custom key presses
        % to skip task or abort
        extraKeyboard;
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
        
        %% Self paced break screen
        function nextState = pauseScreen(self, beginning)
            if ~beginning  % we are mid-block
                trial = self.getTrial();
                if trial.trialIndex ~= 103
                    nextState = 'showFixation';
                    return
                else
                    % ---- Check for event
                    events = {'choseLeft','choseRight'};
                    self.helpers.reader.theObject.setEventsActiveFlag(events)
                    eventName = self.helpers.reader.readEvent(events);
                    
                    % Nothing... keep checking
                    if isempty(eventName)
                        nextState = [];
                        return
                    end
                end
            else
                % ---- Activate event and check for it
                %
                events = {'choseLeft','choseRight'};
                self.helpers.reader.theObject.setEventsActiveFlag(events)
                eventName = self.helpers.reader.readEvent(events);
                
                % Nothing... keep checking
                while isempty(eventName)
                    
                    self.helpers.feedback.show('text', ...
                        {['You may start the next block by pressing', ...
                        ' the B button.']}, ...
                        'showDuration', 0.1, ...
                        'blank', false);
                    
                    eventName = self.helpers.reader.readEvent(events);
                end
            end
            
            % a button has been pressed
            if strcmp(eventName, 'choseLeft')  % abort whole experiment
                self.helpers.feedback.show('text', ...
                    {'Thanks again for your cooperation', ...
                     'We wish you the best!'}, ...
                    'showDuration', 1.5, ...
                    'blank', true);
                nextState = 'done';
                self.abortStateMachine();
            else  % carry on with task
                nextState = 'showFixation';
            end
        end
        
        
        function activateSkipKey(self)
            % only activate the skip button, i.e. s key
            for i=1:length(self.extraKeyboard.eventDefinitions)
                if strcmp(self.extraKeyboard.eventDefinitions(i).name, ...
                        'KeyboardS')
                    disp('activating S keyboard key')
                    self.extraKeyboard.eventDefinitions(i).isActive = 1;
                else
                    self.extraKeyboard.eventDefinitions(i).isActive = 0;
                end
            end
        end
        
        function abortStateMachine(self)
            % abort the task from within the state machine
               self.finish();
%                self.stateMachine.isRunning = false;
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
                    % FOR THIS VERSION OF THE TASK, DISABLE ALL CATCH TRIALS
                    self.trialData(tr).catch = 0;
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
            elseif isa(readableObj, 'customButtonsClass')
                IDs = readableObj.getComponentIDs();
                for ii = 1:numel(IDs)
                    try
                        eventName = readableObj.components(ii).name;
                        if strcmp(self.settings.buttonBox, 'Gold')
                            if strcmp(eventName, 'Button1')
                                eventName = 'choseLeft';
                            elseif strcmp(eventName, 'Button2')
                                eventName = 'choseRight';
                            end
                        elseif strcmp(self.settings.buttonBox, 'EMU')
                            if strcmp(eventName, 'KeyboardLeftShift')
                                eventName = 'choseLeft';
                            elseif strcmp(eventName, 'KeyboardSlash')
                                eventName = 'choseRight';
                            end
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
            
            
            self.pauseScreen();
            
            % ---- Initialize the state machine
            %
            self.initializeStateMachine();
            
            
            % create additional keyboard readable
            self.extraKeyboard = dotsReadableHIDKeyboard();
            % define events
            IDs = self.extraKeyboard.getComponentIDs();
            for ii = 1:numel(IDs)
                try
                    self.extraKeyboard.defineEvent(self.extraKeyboard.components(ii).name, 'component', IDs(ii));
                catch
                    warning(['pb with ',self.extraKeyboard.components(ii).name])
                end
            end
            
            self.activateSkipKey();
            
            self.extraKeyboard.isAutoRead = true;  % not sure what this does
            
        end
        
        %% Finish task (overloaded)
        %
        % Put stuff here that you want to do after each time you run this
        % task
        function finishTask(self)
            
            early_abort = false;
            tot_trials = numel(self.trialData);
            valid_trials = 0;
            for t = 1:tot_trials
                trial = self.trialData(t);
                if isnan(trial.correct)
                    early_abort = true;
                    break
                end
                valid_trials = valid_trials + 1;
            end
            
            % store metadata

            % first get the session struct
            fullMetaData = loadjson(self.metadatafile);
            tmpStruct=fullMetaData.(self.settings.subjectCode);
            all_fields = fieldnames(tmpStruct);
            if length(all_fields) == 1  % recall first field is seqType
                lastSessionName = 'session0';
            else
                lastSessionName = all_fields{end};
            end
            
            if self.taskID == 1  
                % for first block in session, create struct
                currSessionName = [lastSessionName(1:end-1),...
                    num2str(str2double(lastSessionName(end))+1)];  % here currSessionName is of the form sessionN
               
                fullMetaData.(self.settings.subjectCode).(currSessionName) = struct();
                
                fullMetaData.(self.settings.subjectCode).(currSessionName).trialFolder = self.name;
                
                % is stg below the right string???
                stg = self.caller.filename(end-31:end-16);
                fullMetaData.(self.settings.subjectCode).(currSessionName).sessionTag = stg;
                
            else
                currSessionName = lastSessionName;
            end
            subjStruct = fullMetaData.(self.settings.subjectCode);
            
            % initialize block struct
            subjStruct.(currSessionName).(self.name) = struct();
            subjBlockStruct = subjStruct.(currSessionName).(self.name);
            
            if strcmp(self.name(1:3), 'Tut')
                iscomplete = valid_trials > 0;
            else
                iscomplete = ~early_abort;
            end
            
            % then fill out the struct with task data
            if self.isReportTask
                type = 'rep';
            else
                type = 'pred';
            end
            subjBlockStruct.type = type;
            subjBlockStruct.completed = iscomplete; 
            subjBlockStruct.numTrials = valid_trials;
            
            % then save back struct to metadata file
            fullMetaData.(self.settings.subjectCode).(currSessionName).(self.name) = ...
                subjBlockStruct;
            savejson('', fullMetaData, self.metadatafile);
            
            % flush events for extraKeyboard
            [nextEvent, ~] = self.extraKeyboard.getNextEvent();
            while ~isempty(nextEvent)
                [nextEvent, ~] = self.extraKeyboard.getNextEvent();
            end
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
            self.activateSkipKey();
            
            % ---- Show information about the task/trial
            %
            % Task information
            taskString = sprintf('%s (task %d/%d): %d correct, %d error, mean RT=%.2f', ...
                self.name, self.taskID, length(self.caller.children), ...
                sum([self.trialData.correct]==1), sum([self.trialData.correct]==0), ...
                nanmean([self.trialData.RT]));
            
            % Trial information
            trial = self.getTrial();
            
            self.isCatch = trial.catch == 1;  % recall, always false when catch trials disabled
            
            trialString = sprintf('Trial %d/%d, dir=%d, src=%d, catch=%d', ...
                self.trialCount, numel(self.trialData), ...
                trial.direction, trial.source, trial.catch);
            
            % Show the information
            self.statusStrings = {taskString, trialString};
            self.updateStatus(); % just update the second one
        end
        
        %% Finish Trial
        %
        function finishTrial(self)
        end
        
        function nextState = skipTrial(self)
            % ---- Check for event

            eventName = self.extraKeyboard.getNextEvent();
            
            % Nothing... keep checking
            if isempty(eventName)
                nextState = [];
                return
            end
            nextState = 'skipState';
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

                pause(0.1)
                
                self.helpers.stimulusEnsemble.draw({[], 1}, self, 'fixationOff');
                self.helpers.feedback.show('text', ...
                    {'You answered too soon.', ...
                    'Please wait until sound finishes.'}, ...
                    'showDuration', 4, ...
                    'blank', true);
            else
                if self.isCatch
                    self.stateMachine.editStateByName('earlyEvents', 'next', 'catchSound');
                else
                    self.stateMachine.editStateByName('earlyEvents', 'next', 'waitForChoiceFX');
                end

            end
                      
            self.flushEventsQueue()
        end
        function missFeedback(self)
            self.helpers.stimulusEnsemble.draw({[], 1}, self, 'fixationOff');
            self.helpers.feedback.show('text', ...
                {'When second sound occurs,', ...
                'please press the button twice.'}, ...
                'showDuration', 4, ...
                'blank', true);
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

            % Jump to next state when done
            if self.isCatch
                nextState = 'waitForReleasFX';
                trial.catchChoiceMissing = 1;  % set to 0 if catch choice provided later (in checkForCatchChoice)
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
            trial.catchChoiceMissing = 0;
            
            % COMPUTE correct TRIAL
            if trial.choice == 0
                firstChoice = 'choseLeft';
            elseif trial.choice == 1
                firstChoice = 'choseRight';
            end
            if ~strcmp(eventName, firstChoice)  % second button press doesn't match the first one
                trial.correct = 0;
                trial.catchChoiceOpposite = 1;
                
                pause(0.1)
                self.helpers.feedback.show('text', ...
                    {'On catch trials you should press the same button twice.'}, ...
                    'showDuration', 4, ...
                    'blank', true);
            else
                trial.catchChoiceOpposite = 0;
            end
            self.setTrial(trial)
    
        end
        %% Check for direction choice trigger Release
        %
        % Save choice/RT information and set up feedback for the dots task
        function nextState = checkForReleaseDirChoice(self, events, eventTag)
            
            % ---- Check for event
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
            
            if trial.catchChoiceMissing == 1
                trial.correct = 0;
            end
            
            %  Check for RT feedback
            RTstr = '';
            imageIndex = self.settings.correctImageIndex;
            
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
            
           
            skipFb = false;
            
           
            % --- Show trial feedback on the screen
            %
            if self.timing.showSmileyFace > 0 && ~skipFb
                dotsTheScreen.blankScreen(feedbackColor);
                self.helpers.feedback.show(feedbackArgs{:});
            end
            dotsTheScreen.blankScreen([0 0 0]);
        end
        
        function pauseOn(self)
            trial = self.getTrial();
            if trial.trialIndex ~= 103
                breakstr = 'Well done!!! Take a break if you wish.';
                self.helpers.feedback.show('text', ...
                    {breakstr,  ...
                    'To continue press RIGHT, to abort, press LEFT.'}, ...
                    'blank', false);
            end
        end
        function pauseOff(self)
            trial = self.getTrial();
            if trial.trialIndex ~= 103
                dotsTheScreen.blankScreen([0 0 0]);
            end
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
            [nextEvent, ~] = self.helpers.reader.theObject.getNextEvent();
            while ~isempty(nextEvent)
                [nextEvent, ~] = self.helpers.reader.theObject.getNextEvent();
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
            mssfb = {@missFeedback, self};

            % Activate/deactivate readable events
            sea   = @setEventsActiveFlag;

            % activate left/right choices events
            gwts  = {sea, self.helpers.reader.theObject, {'choseLeft', 'choseRight'}};
            
            
            flsh = {@flushData, self.helpers.reader.theObject};
            dque = {@flushEventsQueue, self};
            evtwrn = {@earlyEventWarning, self, {'choseLeft', 'choseRight'}};
            skcheck = {@skipTrial, self};
            ppst = {@prepareTutorialStates, self};
            showsc  = {@showTrueSource, self};
            xsm = {@abortStateMachine, self};
            
            pseon = {@pauseOn, self};
            pseoff = {@pauseOff, self};
            psechk = {@pauseScreen, self, false};
            % ---- Timing variables, read directly from the timing property struct
            %
            t = self.timing;
            
            % ---- Make the state machine. These will be added into the
            %        stateMachine (in topsTreeNode)
            %
            if self.isReportTask
                states = {...
                    'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
                    'midBlock'          pseon    psechk   1000000              pseoff       ''               ; ...
                    'showFixation'      showfx   {}       t.preStim             gwts       'playSound'       ; ...
                    'playSound'         plays1   {}       0                     mdfs       'earlyEvents'     ; ...
                    'earlyEvents'       evtwrn   {}       0                     {}         ''                ; ...
                    'catchSound'        plays2   {}       0                     rsts       'waitForChoiceFX' ; ...
                    'waitForChoiceFX'   {}       chkuic   t.choiceTimeout       {}         'blank'           ; ...
%                     'waitForReleasFX'   {}       chkuic2  t.choiceTimeout       dque       ''                ; ...
%                     'secondChoice'      {}       chkuic3  t.choiceTimeout       {}         'missedCatchChoice' ; ...
%                     'missedCatchChoice' mssfb    {}       0                     {}         'blank'           ; ...
                    'blank'             hided    {}       0.2                   {}         'showFeedback'    ; ...
                    'showFeedback'      showfb   {}       t.showFeedback        blanks     'skipCheck'       ; ...
                    'blankNoFeedback'   {}       {}       0                     blanks     'skipCheck'       ; ...
                    'skipCheck'         {}       skcheck  t.interTrialInterval*.99 {}      'done'         ; ...
                    'done'              dnow     {}       t.interTrialInterval*.01 {}      ''             ; ...
                    'skipState'         xsm      {}       0                     {}         ''                ; ... 
                    };
            else  % prediction block
                states = {...
                    'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
                    'showFixation'      showfxp   {}      t.preStim             gwts       'waitForChoiceFX'       ; ...
                    'waitForChoiceFX'   {}       chkuic   t.choiceTimeout       pdbr       'blank'           ; ...
%                     'waitForReleasFX'   {}       chkuic2  t.choiceTimeout       dque       ''                ; ...
%                     'secondChoice'      {}       chkuic3  t.choiceTimeout       {}         'blank'           ; ...
                    'delay'             rmtgt    {}       1.5                   {}         'playSound'       ; ...
                    'playSound'         plays1   {}       0                     mdfs       ''                ; ...
                    'blank'             hided    {}       0.2                   {}         'showFeedback'    ; ...
                    'showFeedback'      showfb   {}       t.showFeedback        blanks     'skipCheck'       ; ...
                    'blankNoFeedback'   {}       {}       0                     blanks     'skipCheck'       ; ...
                    'skipCheck'         {}       skcheck  t.interTrialInterval*.99 {}      'done'         ; ...
                    'done'              dnow     {}       t.interTrialInterval*.01 {}      ''             ; ...
                    'skipState'         xsm      {}       0                     {}         ''                ; ... 
                    };
            end
            % ---- Set up ensemble activation list. This determines which
            activeList = [];

            compositeChildren = { ...
                self.helpers.stimulusEnsemble.theObject, ...
                self.helpers.screenEnsemble.theObject};
            
            % Call utility to set up the state machine
            self.addStateMachine(states, activeList, compositeChildren);
        end
    end
    
    methods (Static)
        
        %% ---- Utility for defining standard configurations
        function task = getStandardConfiguration(name, varargin)
            
            % ---- Get the task object, with optional property/value pairs
            %
            task = topsTreeNodeTaskAudio2AFCCP(name, varargin{:});

        end
    end
end
