clear
% args is 3x1 vector of:
       %    frequency (Hz)
       %    duration  (sec)
       %    intensity (normalized)
t=dotsPlayableTone.makePlayableTone([400; 1; .01]);
t.side='right'; % can't check that with broken headphones yet.
t.play();