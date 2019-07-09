function s = setval(list, key, val)
    list{find(strcmp(key, list))+1} = val;
    s = list;
end