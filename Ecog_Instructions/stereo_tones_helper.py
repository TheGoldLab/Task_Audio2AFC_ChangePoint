from psychopy import sound,core
import math, copy 
import numpy, numpy as np 
import pygame

'''
January 29th, 2019
Helper function to generate tones in the left and right ear using pygame

Adapted from Alex Holcombe: https://groups.google.com/forum/m/#!topic/psychopy-dev/NoSVA7ycBjM

INPUT:
    -sample_rate: sampling rate of your tone
    -bits: still not sure exactly what this is...but necessary for pygame tones
    - freq: wave frequency
    - duration: duration of tone

OUTPUT:
    Two (sample_rate*duration) x 2 array, with sine wave values in one colum and -1 in the other, each corresponding to a tone in the left or right ear
'''

## GENERATE LEFT AND RIGHT TONE ###
#Initialize stereo tone using pygame backend
def genLRtone(sample_rate,bits,freq,duration):
    n_samples = int(round(duration*sample_rate)) 
    max_sample = 2**(abs(bits) - 1) - 1 
    buf_left = numpy.zeros((n_samples, 2), dtype = numpy.int16) 
    buf_right = numpy.zeros((n_samples, 2), dtype = numpy.int16) 
    for s in range(n_samples): 
        t = float(s)/sample_rate        # time in seconds 
        val = math.sin(2*math.pi*freq*t)#spans from -1 to 1 
        val = max_sample * val 

        val = int(round(val)) #takes as 16-bit signed integer 
        buf_left[s][0] = val   # left 
        buf_left[s][1] = -1    #right 
        buf_right[s][0] = -1   # left 
        buf_right[s][1] = val  #right
    return(buf_right,buf_left)