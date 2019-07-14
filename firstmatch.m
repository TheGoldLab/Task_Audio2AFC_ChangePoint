function idx = firstmatch(list, strVal)
% returns index in list of first element that matches the string strVal
    idx = find(strcmp(strVal, list), 1);
end