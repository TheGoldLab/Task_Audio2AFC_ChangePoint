function val = access(list, key)
    val = list{find(strcmp(key, list))+1};
end