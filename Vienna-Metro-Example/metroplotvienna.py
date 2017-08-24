#load all required packages
import numpy as np
import pandas as pd
from pandas import *
import matplotlib.pyplot as plt
import matplotlib as mpl
from matplotlib import axes
from pylab import *

coords = read_csv('coordinates.csv')
edgesPerLine = pd.Series(coords['ln']).value_counts() 
line=coords.set_index(['ln'])
lineNumbers = line.index.unique() 
opacity= 1
plt.figure()  
for i in lineNumbers:  
    lineCoords = line[line.index==i] 
    numEdges = edgesPerLine.loc[i]
    if numEdges != 1:
        edges = np.arange(numEdges)
        for j in edges:
            edgeCoords = lineCoords.iloc[j]
            plt.plot([edgeCoords[0], edgeCoords[1]],[edgeCoords[2], edgeCoords[3]], linewidth=4,marker="o",\
                 alpha=opacity, markersize=8,color=edgeCoords[4],clip_on=False)
    # Exception for line(s) with only one edge
    else:
        edgeCoords = lineCoords.ix[i]
        plt.plot([edgeCoords[0], edgeCoords[1]],[edgeCoords[2], edgeCoords[3]],linewidth=4,marker="o",\
            alpha=opacity, markersize=8,color=edgeCoords[4],clip_on=False)
plt.gca().axison = False
plt.axes().set_aspect('equal')
plt.savefig("solution-ss.png",dpi=300,bbox_inches='tight',transparent="True")
plt.show()


