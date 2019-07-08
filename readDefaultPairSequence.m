function bl =readDefaultPairSequence()
% reads default block sequence from file DefaultBlockSequence.csv
% returns a Nx1 cell array with one block name per entry (N names if
% N lines in the file).
c=readtable('BlockPairs.csv', 'Format','%s%s');
bl = table2cell(c(:,1));
end