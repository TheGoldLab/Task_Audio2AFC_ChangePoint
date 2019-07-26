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
            'targetDistance',             10,    ...
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
            'choiceTimeout',             8.0);
        
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
            'isCatch', ...
            'randSeedBase', ...
            'unselectedTargetOff', ...
            'showTrueSource', ...
            'showSelection', ...
            'showTrueSound', ...
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
            ...   % 1 Fixation drawable settings
            'fixation',                   struct( ...
            'fevalable',                  @dotsDrawableTargets, ...
            'settings',                   struct( ...
            'xCenter',                    0,                ...
            'yCenter',                    0,                ...
            'nSides',                     4,                ...
            'width',                      2.6*[1.0 0.1],   ...
            'height',                     2.6*[0.1 1.0],   ...
            'colors',                     [1 1 1])),        ...
            ...
            ...   % 2 left Target drawable settings
            'targetLeft',                    struct( ...
            'fevalable',                  @dotsDrawableTargets, ...
            'settings',                   struct( ...
            'nSides',                     100,              ...
            'width',                      2.5*[1 1],       ...
            'height',                     2.5*[1 1])),      ...
            ...
            ...   % 3 Smiley face for feedback
            'smiley',                     struct(  ...
            'fevalable',                  @dotsDrawableImages, ...
            'settings',                   struct( ...
            'y',                          8, ...
            'x',                          0, ...
            'pixelHeights',               50, ...
            'fileNames',                  {{'thumbsUp.jpg'}} ...  % for error, use Oops.jpg
            )), ...
             ...  % 4 right target
            'targetRight',                struct( ...
            'fevalable',                  @dotsDrawableTargets, ...
            'settings',                   struct( ...
            'nSides',                     100,              ...
            'width',                      2.5*[1 1],       ...
            'height',                     2.5*[1 1])), ...
            ...   % 5 left music note
            'noteLeft',                   struct(...
            'fevalable',                  @dotsDrawableImages, ...
            'settings',                   struct( ...
            'fileNames',                  {{'smiley.jpg'}}, ...
            'height',                     1.4)), ...
            ...   % 6 right music note
            'noteRight',                  struct(...
            'fevalable',                  @dotsDrawableImages, ...
            'settings',                   struct( ...
            'fileNames',                  {{'smiley.jpg'}}, ...
            'height',                     1.4)), ...
            ...   % 7 square that surrounds selected target
            'selectionSquare',           struct( ...
            'fevalable',                  @dotsDrawableTargets, ...
            'settings',                   struct( ...
            'nSides',                     4,              ...
            'yCenter',                    [0,0,-1.5,1.5], ...
            'width',                      [.1 .1 4.25 4.25],       ... % first two are vertical sides of square, last two are horizontal sides of square
            'height',                     [4.25 4.25 .1 .1]))));
        
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
        midblock = 103;  % should be 103 for 205-trial blocks, in any case, should be larger than the longest tutorial
        hasReachedMidBlock = false;
        halfDelay = .75; % seconds. This is half of the delay period
        
        % left color
        leftColor = [255 160 0] / 255;     % golden/orange
        rightColor = [191 116 255] / 255;  % purple
    end
    
    properties (SetAccess = protected)
        % Boolean flag, whether the trial is catch trial or not
        isCatch;
        
        noRespTrial;  % whether no response is expected from the subject
                
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
        
        %% pauseScreen
        function nextState = pauseScreen(self, beginning)
            if ~beginning  % we are within the state machine iteration
                trial = self.getTrial();
                if (trial.trialIndex ~= self.midblock) || self.hasReachedMidBlock  % start trial
                    nextState = 'showFixation';
                    return
                else                       % wait for subject's trigger
%                     fprintf('pauseScreen waiting for trigger')
%                     fprintf(char(10))
                    events = {'choseLeft','choseRight'};
                    
                    eventName = self.helpers.reader.readEvent(events);
                    
                    % Nothing... keep checking
                    if isempty(eventName)
                        nextState = [];
                        return
                    end
                    % if this line of code is reached, then continues
                    % outside of the outter 'if' block
                end
            else
               
                if self.taskID == 1
                    blockString = 'Tutorial';
                else
                    blockString = 'Task block';
                end
                
                % ---- Activate event and check for it
                %
                events = {'choseLeft','choseRight'};
                self.helpers.reader.theObject.setEventsActiveFlag(events)
                eventName = self.helpers.reader.readEvent(events);
                
                % Nothing... keep checking
                while isempty(eventName)
                    self.helpers.feedback.show('text', ...
                        {blockString, ...
                        ['Press ', ...
                        'RIGHT to start  (left to skip)']}, ...
                        'showDuration', 0.1, ...
                        'blank', false);
                    
                    eventName = self.helpers.reader.readEvent(events);
                end
            end
            
            % a button has been pressed
            if strcmp(eventName, 'choseLeft')  % skip block
                if self.taskID == 1
                    self.helpers.feedback.show('text', ...
                        {'Skipping tutorial'}, ...
                        'showDuration', 1.5, ...
                        'blank', true);
                    nextState = 'done';                    
                else
                    self.helpers.feedback.show('text', ...
                        {'Thanks again for your cooperation', ...
                        'We wish you the best!'}, ...
                        'showDuration', 1.5, ...
                        'blank', true);
                    nextState = 'done';
                end
                
                self.skipTask();
            else  % carry on with task
                nextState = 'showFixation';
            end
            self.flushEventsQueue();
        end
        
        %% activateSkipKey
        function activateSkipKey(self)
            % only activate the skip button, i.e. s key
            for i=1:length(self.extraKeyboard.eventDefinitions)
                if strcmp(self.extraKeyboard.eventDefinitions(i).name, ...
                        'KeyboardS')
%                     disp('activating S keyboard key')
                    self.extraKeyboard.eventDefinitions(i).isActive = 1;
                else
                    self.extraKeyboard.eventDefinitions(i).isActive = 0;
                end
            end
        end
        
        %% skipTask
        function skipTask(self)
            % abort the task from within the state machine
            
            self.flushEventsQueue(true)
            
            self.abort();
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
                    self.trialData(tr).isCatch = 0;
                else
                    self.trialData(tr).isCatch = 0;
                end
            end
        end
        
        
        %% Start task (overloaded)
        %
        % Put stuff here that you want to do before each time you run this
        % task
        function startTask(self)
%             fprintf('starting task %s with ID %d', self.name, self.taskID)
%             fprintf(char(10))
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
                        elseif strcmp(self.settings.buttonBox, 'GoldOnEMUlaptop')
                            if strcmp(eventName, 'KeyboardD')
                                eventName = 'choseLeft';
                            elseif strcmp(eventName, 'KeyboardK')
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
            
            self.pauseScreen(true);
        end
        
        %% Finish task (overloaded)
        %
        % Put stuff here that you want to do after each time you run this
        % task
        function finishTask(self)
%             fprintf('finishing task %s with ID %d', self.name, self.taskID)
%             fprintf(char(10))
            early_abort = false;
            tot_trials = numel(self.trialData);
            valid_trials = 0;
            for t = 1:tot_trials
                trial = self.trialData(t);
                if isfield(trial, 'correct')
                    if isnan(trial.correct)
                        early_abort = true;
                        break
                    end
                    valid_trials = valid_trials + 1;
                else  % task aborted before first trial started
                    early_abort = true;
                    break
                end
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
            

            iscomplete = ~early_abort;
            
            if (self.taskID == 2) && iscomplete
                self.helpers.feedback.show('text', ...
                    {'All done', ...
                    'Thanks again for your cooperation!'}, ...
                    'showDuration', 1.5, ...
                    'blank', true);
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
            
            % flush events from all readables
            self.flushEventsQueue(true)

        end
        
        %% Start trial
        %
        % Put stuff here that you want to do before each time you run a trial
        function startTrial(self)
            % Trial information
            trial = self.getTrial();
            
            self.isCatch = trial.isCatch == 1;  % recall, always false when catch trials disabled
            
            if ~self.isReportTask
                if self.taskID == 1  % not a report task, and it is a tutorial
                    if trial.trialIndex < 41  % no response required for first 40 trials
                        self.noRespTrial = true;
                    else
                        self.noRespTrial = false;
                    end
                end
            end
            
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
            

            
            trialString = sprintf('Trial %d/%d, dir=%d, src=%d, isCatch=%d', ...
                self.trialCount, numel(self.trialData), ...
                trial.direction, trial.source, trial.isCatch);
            
            % Show the information
            self.statusStrings = {taskString, trialString};
%             self.updateStatus(); % just update the second one
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
                    {'You answered too soon', ...
                    'Please wait until cross turns blue'}, ...
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
%                 if trial.trialIndex == 41
%                     disp('trial 41 set to complete')
%                 end
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
        
        
        %% tutorialScreen
        function tutorialScreen(self)
            % Get current task/trial
            trial = self.getTrial();
            
            % Display appropriate string
            if trial.trialIndex == 1
                feedbackStr = {'Sounds generated from', 'the GOLDEN SOURCE'};
                feedbackArgs = { ...
                    'text',  feedbackStr, 'showDuration', 4};
            elseif trial.trialIndex == 11
                feedbackStr = {'Sounds generated from', 'the PURPLE SOURCE'};
                feedbackArgs = { ...
                    'text',  feedbackStr, 'showDuration', 4};
            elseif trial.trialIndex == 21
                feedbackStr = {'Example of a real sequence of sources', ...
                    '(press any button to start)'};
                feedbackArgs = {'text', feedbackStr, 'showDuration', .1, ...
                    'blank', false};
            elseif trial.trialIndex == 41
                feedbackStr = {'Now predict the SOURCE as best as you can', ...
                    '(press any button to start)'};
                feedbackArgs = {'text', feedbackStr, 'showDuration', .1, ...
                    'blank', false};
            elseif trial.trialIndex == 61
                feedbackStr = {'Keep practicing', 'we will hide the source and sound (press button)'};
                feedbackArgs = {'text', feedbackStr, 'showDuration', .1, ...
                    'blank', false};
            end
            if ismember(trial.trialIndex, [21,41,61])
                % ---- Activate event and check for it
                %
                pause(.5)
                self.flushEventsQueue()
                
                events = {'choseLeft', 'choseRight'};
                self.helpers.reader.theObject.setEventsActiveFlag(events)
                eventName = self.helpers.reader.readEvent(events);
                
                % Nothing... keep checking
                while isempty(eventName)
                    self.helpers.feedback.show(feedbackArgs{:});
                    eventName = self.helpers.reader.readEvent(events);
                end
                
%                 pause(.5)
%                 self.flushEventsQueue()
%                 
                dotsTheScreen.blankScreen([0 0 0]);
            elseif ismember(trial.trialIndex, [1,11])
                self.helpers.feedback.show(feedbackArgs{:});
                dotsTheScreen.blankScreen([0 0 0]);
            end
            self.flushEventsQueue();  % somehow this doesn't work!
        end
        
        
        %% Show feedback
        %
        function showFeedback(self)
            
            % Get current task/trial
            trial = self.getTrial();
            ensemble = self.helpers.stimulusEnsemble.theObject;
            if trial.catchChoiceMissing == 1
                trial.correct = 0;
            end
            
            useFB = false;
            
            % Set up feedback based on outcome
            if trial.correct == 1
                ensemble.setObjectProperty('fileNames', {'thumbsUp.jpg'}, 3);
                feedbackStr = 'correct';
            elseif trial.correct == 0
                ensemble.setObjectProperty('fileNames', {'Oops.jpg'}, 3);
                feedbackStr = 'wrong';
            else
                feedbackStr = 'No choice';
                feedbackArgs = {'text', 'No choice, please try again.', ...
                    'eventTag', 'feedbackOn'};
                
                useFB = true;

            end
            
            % --- Show trial feedback in GUI/text window
            %
            self.statusStrings{2} = ...
                sprintf('Trial %d/%d, dir=%d: %s', ...
                self.trialCount, numel(self.trialData), ...
                trial.direction, feedbackStr);
            %             self.updateStatus(2); % just update the second one
            
            
            skipFb = false;

            % --- Show trial feedback on the screen
            %
            if self.timing.showSmileyFace > 0 && ~skipFb
                if useFB
                    self.helpers.feedback.show(feedbackArgs{:})
                else
                    if (trial.trialIndex) > 40 && (trial.trialIndex < 61)
                        pause(.5)
                    end
                    ensemble.callObjectMethod(@prepareToDrawInWindow);
                    self.helpers.stimulusEnsemble.draw( ...
                    { ...
                    {'isVisible', true, 3}, ...
                    }, ...
                    self, 'feedbackOn');  
                end
            end

%             dotsTheScreen.blankScreen([0 0 0]);
        end
        
        function pauseOn(self)
            trial = self.getTrial();
            if (trial.trialIndex == self.midblock) && ~self.hasReachedMidBlock
%                 fprintf('pauseOn on trial %d', trial.trialIndex)
%                 fprintf(char(10))
                pause(.5)
                self.flushEventsQueue()
                breakstr = 'Well done!!! Take a break if you wish.';
                continuestr = 'to continue press RIGHT';
                abortstr = 'To abort, press LEFT';
                a = dotsDrawableText.makeEnsemble('midblockPause', 3, 3);
                a.objects{1}.string = breakstr;
                a.objects{2}.string = continuestr;
                a.objects{3}.string = abortstr;
                
                self.helpers.reader.theObject.setEventsActiveFlag({'choseLeft', 'choseRight'})
                name = self.helpers.reader.readEvent({'choseLeft', 'choseRight'});
                while isempty(name)
                    name = self.helpers.reader.readEvent({'choseLeft', 'choseRight'});
                    dotsDrawable.drawFrame(a.objects, false);         
                end
                
%                 dotsDrawableText.drawEnsemble(a, {breakstr, continuestr, abortstr});

                %                 self.helpers.feedback.show('text', ...
                %                     {''}, ...
%                     'blank', false);
                
            end
            self.flushEventsQueue();
        end
        function pauseOff(self)
            trial = self.getTrial();
            if (trial.trialIndex == self.midblock) && ~self.hasReachedMidBlock
                self.hasReachedMidBlock = true;
                dotsTheScreen.blankScreen([0 0 0]);
            end
            self.flushEventsQueue();
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
            for d = 1:7
                % forcefully hide all visual objects
                ensemble.setObjectProperty('isVisible', false, d)
            end
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
                ensemble.setObjectProperty('xCenter', fpX - td, 2); % left target
                ensemble.setObjectProperty('x', fpX - td, 5); % left music note
                ensemble.setObjectProperty('xCenter', fpX + td, 4); % right target
                ensemble.setObjectProperty('x', fpX + td, 6); % right music note
                ensemble.setObjectProperty('yCenter', fpY, 2);
                ensemble.setObjectProperty('y', fpY + 3, 5);  % music note above target
                ensemble.setObjectProperty('yCenter', fpY, 4);
                ensemble.setObjectProperty('y', fpY + 3, 6);  % music note above target
            end
            
            % ---- Set a new seed base for the dots random-number process
            %
            trial.randSeedBase = randi(9999);
            self.setTrial(trial);
            
%             % ---- Possibly update smiley face to location of correct target
%             %
%             if self.timing.showSmileyFace > 0
%                 
%                 % Set x,y
%                 ensemble.setObjectProperty('x', fpX + sign(cosd(trial.direction))*td, 3);
%                 ensemble.setObjectProperty('y', fpY, 3);
%             end
            
            % assign correct file for music notes
            if trial.direction == 180
                if trial.source == 180
                    ensemble.setObjectProperty('fileNames', {'goldennote.png'}, 5);
                else
%                     disp('right source and left sound')
                    ensemble.setObjectProperty('fileNames', {'purplenote.png'}, 5);
                end
            else
                if trial.source == 180
                    ensemble.setObjectProperty('fileNames', {'goldennote.png'}, 6);
                else
%                     disp('right source and right sound')
                    ensemble.setObjectProperty('fileNames', {'purplenote.png'}, 6);
                end
            end
            % ---- Prepare to draw dots stimulus
            %
            ensemble.callObjectMethod(@prepareToDrawInWindow);
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
            if self.noRespTrial
                self.completedTrial = true;
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
        
        
        
        function flushEventsQueue(self, extra)
            if nargin < 2
                extra = false;
            end
            
            % flush queue in helper's readable
            [nextEvent, ~] = self.helpers.reader.theObject.getNextEvent();
            while ~isempty(nextEvent)
                [nextEvent, ~] = self.helpers.reader.theObject.getNextEvent();
            end
            
            if extra
                % flush extra keyboard writable
                [nextEvent, ~] = self.extraKeyboard.getNextEvent();
                while ~isempty(nextEvent)
                    [nextEvent, ~] = self.extraKeyboard.getNextEvent();
                end
            end
        end
        
        
%         function prepareTutorialStates(self)
%             trial = self.getTrial();
%             if trial.trialIndex < 40
%                 self.stateMachine.editStateByName('showFixation', 'next', 'showSource');
%             else
%                 self.stateMachine.editStateByName('showFixation', 'next', 'waitForChoiceFX');
%             end
%             self.trueSource = trial.source;
%         end
        
        function showTrueSource(self)
            if self.trueSource == 180
                self.helpers.stimulusEnsemble.draw({{'colors', ...
                    [1 0 0], 2}, {'isVisible', true, 2}, {'isVisible', false, 4}},  self, 'sourceOn');
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
        
        
        function tutPredEntry(self)
            self.flushEventsQueue();
            trial = self.getTrial();
            % if within first 40 trials, no subject's answer required
            % show true source in appropriate color + fixation cross
            if trial.source == 180
                sidx = 2;
                thide = 4;
                col = self.leftColor;
            else
                sidx = 4;
                thide = 2;
                col = self.rightColor;
            end
            if trial.trialIndex < 41  
                self.helpers.stimulusEnsemble.draw( ...
                    { ...
                    {'colors', col, sidx}, ...  % source in color
                    {'colors', [1 1 1], 1}, ... % white fixation cross
                    {'isVisible', true, [1, sidx]}, ...
                    {'isVisible', false, thide}, ...
                    }, ...
                    self, 'fixationOn');
            elseif trial.trialIndex > 40
                 self.helpers.stimulusEnsemble.draw( ...
                    { ...
                    {'colors', [0 0 1], 1}, ... % blue fixation cross
                    {'isVisible', true, 1}, ...
                    {'isVisible', false, [2, 4]}, ... % hide sources
                    }, ...
                    self, 'fixationOn');  
            end
        end
        
        function delayEntry(self)
            % controls display at beginning of delay period
            % only gets called in TutPrediction tasks
            trial = self.getTrial();
            % if within first 40 trials, no subject's answer required
            % show true source in appropriate color + fixation cross
            if trial.source == 180
                sidx = 2;
                thide = 4;
                col = self.leftColor;
            else
                sidx = 4;
                thide = 2;
                col = self.rightColor;
            end
            if trial.trialIndex > 40
                self.stateMachine.editStateByName('delay', 'timeout', self.halfDelay);
                
                % set up appropriate coordinates for selection square
                sqHalfWidth = 1.5; 
                ensemble = self.helpers.stimulusEnsemble.theObject;
                if trial.choice == 0  % subject picked left
                    center = - self.settings.targetDistance;
                else
                    center = self.settings.targetDistance;
                end
                ensemble.setObjectProperty('xCenter', ...
                    [center - sqHalfWidth, center + sqHalfWidth, ...
                     center, center], 7); 
                
                % first display selection + turn cross white
                
                self.helpers.stimulusEnsemble.draw( ...
                    { ...
                    {'colors', [1 1 1], [1,7]}, ... % white fixation cross + selection
                    {'isVisible', true, [1, 7]}, ...
                    {'isVisible', false, thide}, ...
                    }, ...
                    self, 'showSelection');
                
                % wait a bit
                pause(self.halfDelay)
                
                % display true source if below trial 61
                if trial.trialIndex < 61
                    self.helpers.stimulusEnsemble.draw( ...
                        { ...
                        {'colors', col, sidx}, ...  % source in color
                        {'isVisible', true, sidx}, ...
                        {'isVisible', false, thide}, ...
                        }, ...
                        self, 'showTrueSource');
                end
            else
                self.stateMachine.editStateByName('delay', 'timeout', 2*self.halfDelay);
            end
        end
        
        function delayExit(self)
            trial = self.getTrial();
            % for now, only do something if within first 60 trials
            % show true sound in appropriate color up to trial 60
            if trial.direction == 180
                midx = 5;
                thide = 6;
            else
                midx = 6;
                thide = 5;
            end
            if trial.trialIndex < 61  
%                 disp('draw is called for image...')
                self.helpers.stimulusEnsemble.draw( ...
                    { ...
                    {'isVisible', true, midx}, ...
                    {'isVisible', false, thide}, ...
                    }, ...
                    self, 'showTrueSound');
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
            
            % show white fixation cross only
            showfx  = {@draw, self.helpers.stimulusEnsemble, {{'colors', ...
                [1 1 1], 1}, {'isVisible', true, 1}, {'isVisible', false, [2 3 4 5 6 7]}},  self, 'fixationOn'};
            
            % show fixation cross in blue and two targets in white
            showfxp  = {@draw, self.helpers.stimulusEnsemble, {...
                {'colors', [0 0 1], 1}, {'colors', [1 1 1], [2,4]}, {'isVisible', true, [1, 2, 4]}, {'isVisible', false, [3 5 6 7]} ...
                },  self, 'fixationOn'};
            
            % first display in prediction tutorial
            tutent = {@tutPredEntry, self};
            
            % entry and exit function for delay state
            delent  = {@delayEntry, self};
            delex = {@delayExit, self};
            
            % only show blue fixation cross
            shfxb  = {@draw, self.helpers.stimulusEnsemble, {{'colors', ...
                [0 0 1], 1}, {'isVisible', true, 1}, {'isVisible', false, [2 3 4 5 6 7]}},  self, 'fixationBlue'};
            
%             shfxw  = {@draw, self.helpers.stimulusEnsemble, {{'colors', ...
%                 [1 1 1], 1}, {'isVisible', true, 1}, {'isVisible', false, [2 3 4]}},  self, 'fixationBlue'};
            
            showfb  = {@showFeedback, self};
            plays1 = {@play, self.helpers.audStimulusEnsemble.theObject, self, 'sound1On', 'sound1Off'};
            plays2 = {@play, self.helpers.audStimulusEnsemble.theObject, self, 'sound2On', 'sound2Off'};
            
            % hide everything but smiley face for feedback
            hided   = {@draw,self.helpers.stimulusEnsemble, {[], [1,2,4,5,6,7]}, self, 'fixationOff'};
            % hide everything (equivalent to blanks but with timestamp?)
            hidea   = {@draw,self.helpers.stimulusEnsemble, {[], [1,2,3,4,5,6,7]}, self, 'fixationOff'};
            % possibly shorten bip duration if we are in a catch trial
            % NOTE: On trials that don't require a subject's answer, this
            % function sets the trial as "complete"
            mdfs = {@modifySound, self};
            
            % reset sound to usual duration, once catch sound has been
            % emitted
            rsts = {@resetSound, self};
            
            
            pdbr = {@setNextState, self, 'isCatch', 'playSound', 'catchSound', 'showFeedback'};
            
            % if no response is expected from subject, set next state of
            % showFixation to delay, otherwise, set it to waitForChoiceFX
            skresp = {@setNextState, self, 'noRespTrial', 'showFixation', 'delay', 'waitForChoiceFX'};

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
            
            
            % check whether subject hits 's' on keyboard to trigger
            % abortion of task
            skcheck = {@skipTrial, self};
            
            
%             ppst = {@prepareTutorialStates, self};
            showsc  = {@showTrueSource, self};
            
            % skip whole task
            xsm = {@skipTask, self};
            
            pseon = {@pauseOn, self};
            pseoff = {@pauseOff, self};
            psechk = {@pauseScreen, self, false};
            
            % pause screen in-between parts of prediction tutorial
            bscreen = {@tutorialScreen, self};
            
            % ---- Timing variables, read directly from the timing property struct
            %
            t = self.timing;
            
            % ---- Make the state machine. These will be added into the
            %        stateMachine (in topsTreeNode)
            %
            if self.isReportTask
                states = {...
                    'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
                    'skipCheck'         {}       skcheck  0.1                   {}         'midBlock'        ; ...
                    'midBlock'          pseon    psechk   1000000              pseoff       ''               ; ...
                    'showFixation'      showfx   {}       t.preStim             gwts       'playSound'       ; ...
                    'playSound'         plays1   {}       0                     mdfs       'earlyEvents'     ; ...
                    'earlyEvents'       evtwrn   {}       0                     {}         ''                ; ...
                    'catchSound'        plays2   {}       0                     rsts       'waitForChoiceFX' ; ...
                    'waitForChoiceFX'   shfxb    chkuic   t.choiceTimeout       {}         'blank'           ; ...
                    'blank'             hided    {}       0.2                   {}         'showFeedback'    ; ...
                    'showFeedback'      showfb   {}       t.showFeedback        {}         'done'       ; ...
                    'blankNoFeedback'   {}       {}       0                     blanks     'done'       ; ...
                    'done'              dnow     {}       t.interTrialInterval*.01 {}      ''             ; ...
                    'skipState'         xsm      {}       0                     {}         ''                ; ... 
                    };
            else  % prediction block
                if self.taskID == 2  % this is not a tutorial
                    states = {...
                        'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
                        'skipCheck'         {}       skcheck  0.1                   {}         'midBlock'        ; ...
                        'midBlock'          pseon    psechk   1000000               pseoff       ''              ; ...
                        'showFixation'      shfxb    {}       t.preStim             gwts       'waitForChoiceFX' ; ...
                        'waitForChoiceFX'   {}       chkuic   t.choiceTimeout       {}         'blank'           ;...
                        'delay'             showfx   {}       1.5                   {}         'playSound'       ; ...
                        'playSound'         plays1   {}       0                     mdfs       'blankNoFeedback' ; ...
                        'blank'             hidea    {}       0                     {}         'showFeedback'    ; ...
                        'showFeedback'      showfb   {}       t.showFeedback        {}         'done'       ; ...
                        'blankNoFeedback'   hidea    {}       0                     {}         'done'       ; ...
                        'done'              dnow     {}       t.interTrialInterval*.01 {}      ''             ; ...
                        'skipState'         xsm      {}       0                     {}         ''                ; ...
                        };
                else  % this is a tutorial
                    states = {...
                        'name'              'entry'  'input'  'timeout'             'exit'     'next'            ; ...
                        'skipCheck'         {}       skcheck  0.1                   {}         'miniblock'       ; ...
                        'miniblock'         bscreen   {}      0                     skresp     'showFixation'    ; ...
                        'showFixation'      tutent    {}      t.preStim             gwts       ''       ; ...
                        'waitForChoiceFX'   {}       chkuic   t.choiceTimeout       pdbr       'blank'           ; ...
                        'delay'             delent   {}       self.halfDelay        delex      'playSound'       ; ...
                        'playSound'         plays1   {}       0                     mdfs       ''                ; ...
                        'blank'             hided    {}       0.2                   {}         'showFeedback'    ; ...
                        'showFeedback'      showfb   {}       3*t.showFeedback      {}         'done'       ; ...
                        'blankNoFeedback'   {}       {}       0                     blanks     'done'       ; ...
                        'done'              dnow     {}       t.interTrialInterval*.01 {}      ''             ; ...
                        'skipState'         xsm      {}       0                     {}         ''                ; ...
                        };
                end
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
