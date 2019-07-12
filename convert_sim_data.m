% % convert sim_data.csv into appropriate format
% clear
% t1=readtable('sim_data.csv');
% t1.source_switch = [];
% t1.sound_switch = [];
% t1.hazard = [];
% t1.hazard_switch = [];
% t1.Var1 = [];
% t1.soundLoc = t1.sound;
% t1.sourceLoc = t1.source;
% t1.sound = [];
% t1.source = [];
% rng('shuffle')
% catchVector={};
% for i=1:size(t1,1)
%     if rand < 0.05  % 5% of catch trials
%         catchVector{i}='True';
%     else
%         catchVector{i} = 'False';
%     end
% end
% t1.isCatch = catchVector';
% 
% % save
% writetable(t1)

%% make 60 trials for TutPredictionLow
clear
t1=readtable('Block004/Block004.csv');
t1.source_switch = [];
t1.sound_switch = [];
t1.hazard = [];
t1.hazard_switch = [];
% t1.Var1 = [];
% t1.soundLoc = t1.soundLoc;
% t1.sourceLoc = t1.sourceLoc;
% t1.sound = [];
% t1.source = [];
rng('shuffle')
catchVector={};
for i=1:size(t1,1)
    if rand < 0.05  % 5% of catch trials
        catchVector{i}='True';
    else
        catchVector{i} = 'False';
    end
end
t1.isCatch = catchVector';

t1 = t1(end-59:end,:);

% save
writetable(t1(:, [2,1,3]),'TutPredictionLow/toappend.csv')

%% make 60 trials for TutPredictionHigh
clear
t1=readtable('Block008/Block008.csv');
t1.source_switch = [];
t1.sound_switch = [];
t1.hazard = [];
t1.hazard_switch = [];
% t1.Var1 = [];
% t1.soundLoc = t1.soundLoc;
% t1.sourceLoc = t1.sourceLoc;
% t1.sound = [];
% t1.source = [];
rng('shuffle')
catchVector={};
for i=1:size(t1,1)
    if rand < 0.05  % 5% of catch trials
        catchVector{i}='True';
    else
        catchVector{i} = 'False';
    end
end
t1.isCatch = catchVector';

t1 = t1(end-59:end,:);

% save
writetable(t1(:, [2, 1, 3]),'TutPredictionHigh/toappend.csv')