% convert sim_data.csv into appropriate format
clear
t1=readtable('sim_data.csv');
t1.source_switch = [];
t1.sound_switch = [];
t1.hazard = [];
t1.hazard_switch = [];
t1.Var1 = [];
t1.soundLoc = t1.sound;
t1.sourceLoc = t1.source;
t1.sound = [];
t1.source = [];
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

% save
writetable(t1)