#load all required packages
import numpy as np
import pandas as pd
from pandas import *
import matplotlib.pyplot as plt
#import matplotlib as mpl
from matplotlib import axes
from pylab import *
import matplotlib.cm as cm
#import itertools

bend = [4,5,6,7,9]
rpos = [5,4,3,1,0]

plt.plot(bend, rpos, marker='o')
        

#color=next(colors)
plt.axis([-1, 10, -1, 10])
plt.xlabel('Relative position cost')
plt.ylabel('Bend cost')
plt.title('Third Example Pareto Frontier')
#plt.spines.set_color('none')
#plt.legend(loc='upper left')
plt.grid(True)
plt.show()

