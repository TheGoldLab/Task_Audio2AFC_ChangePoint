function typetest
clc;
clear all;

tic;
timekeeper = 0;
%kb = dotsReadableHIDKeyboard();
kb=dotsReadableHIDButtons();
IDs = kb.getComponentIDs();
for ii = 1:numel(IDs)
    try
        kb.defineEvent(kb.components(ii).name, 'component', IDs(ii));
    catch
        warning(['pb with ',kb.components(ii).name])
    end
end
% kb.defineEvent('k');
% kb.defineEvent('d');
for i=1:length(kb.eventDefinitions)
    kb.eventDefinitions(i).isActive = 1;
end
kb.isAutoRead = true;
letter = dotsDrawableText;
dotsTheScreen.openWindow;
while timekeeper <= 200
    dotsDrawable.drawFrame({letter}, false);
    name = kb.getNextEvent();
    
    if ~isempty(name)
        dotsTheScreen.blankScreen();
        letter.string = name;
    end
    timekeeper = toc;
end
dotsTheScreen.closeWindow;