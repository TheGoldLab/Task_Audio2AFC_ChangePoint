clear
% args is 3x1 vector of:
       %    frequency (Hz)
       %    duration  (sec)
       %    intensity (normalized)
t_long=dotsPlayableTone.makePlayableTone([400; .3; .01]);
t_long.side='left'; % can't check that with broken headphones yet.
t_long.playBlocking = true;
t_long.prepareToPlay();

t_short=dotsPlayableTone.makePlayableTone([412; .03; .01]);
t_short.side='right'; % can't check that with broken headphones yet.
t_short.playBlocking = true;
t_short.prepareToPlay();

for i=1:5
    t_long.play();
    t_short.play(); pause(0.001); t_short.play();
    pause(.04)
end
