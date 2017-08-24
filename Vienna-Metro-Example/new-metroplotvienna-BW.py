#load all required packages
import numpy as np
import pandas as pd
from pandas import *
import matplotlib.pyplot as plt
import matplotlib as mple
from matplotlib import axes
from pylab import *
import matplotlib.cm as cm
import itertools


def setAxLinesBW(ax):
    """
    Take each Line2D in the axes, ax, and convert the line style to be 
    suitable for black and white viewing.
    """
    MARKERSIZE = 8

    COLORMAP = {
        'r': {'marker': 'o', 'dash': (None,None)},
        'Brown': {'marker': 'o', 'dash': [5,5]},
        'g': {'marker': 'o', 'dash': [5,3,1,3]},
        'DarkOrange': {'marker': 'o', 'dash': [1,3]},
        'DarkViolet': {'marker': 'o', 'dash': [5,2,5,2,5,10]},
        'y': {'marker': 'o', 'dash': [5,3,1,2,1,10]},
        #'k': {'marker': 'o', 'dash': (None,None)} #[1,2,1,10]}
        }

    for line in ax.get_lines(): # + ax.get_legend().get_lines():
        origColor = line.get_color()
        line.set_color('black')
        line.set_dashes(COLORMAP[origColor]['dash'])
        line.set_marker(COLORMAP[origColor]['marker'])
        line.set_markersize(MARKERSIZE)
        #line.set_markerfacecolor('w')
        #line.set_markeredgecolor('k')
        #line.set_markeredgewidth(4)

def setFigLinesBW(fig):
    """
    Take each axes in the figure, and for each line in the axes, make the
    line viewable in black and white.
    """
    for ax in fig.get_axes():
        setAxLinesBW(ax)


fname = 'vienna_results.txt'
fname2 = 'viennafrontier.csv'


# Opens results file and obtains solution bend and shift costs
with open(fname) as f:
    content = f.readlines()
for k in range(len(content)):
    if content[k].startswith('Efficient'):
        firstSolIndex = k+1
    if content[k].startswith('Infeasibilities'):
        lastSolIndex = k-2
soln = {}
for i in range(firstSolIndex-firstSolIndex,lastSolIndex+1-firstSolIndex):
    soln[i] = content[i+firstSolIndex].rsplit()[1:3]

# Number of Pareto points
if content[lastSolIndex].rsplit()[1]=='infeasible':
    numPOS = int(content[lastSolIndex-1].rsplit()[0]) 
else:
    numPOS = int(content[lastSolIndex].rsplit()[0]) 
f.close()

# Opens coordinates file and determines chunk lengths
with open(fname2) as f:
    content = f.readlines()
length2 = len(content)
f.close()
content = None
numChunks = length2/numPOS


reader = pd.read_csv(fname2, chunksize=numChunks)
POSCoords = {};

for k in arange(numPOS):
    POSCoords[k] = reader.get_chunk(numChunks) # Dataframe of coords for each POS
    coords = POSCoords[k]
    edgesPerLine = pd.Series(coords['ln']).value_counts() 
    line=coords.set_index(['ln'])
    lineNumbers = line.index.unique() 
    opacity= 1
    fig=plt.figure(num=k+1)  
    ax = fig.add_subplot(111)
    for i in lineNumbers:  
        lineCoords = line[line.index==i] 
        numEdges = edgesPerLine.loc[i]
        if numEdges != 1:
            edges = np.arange(numEdges)
            for j in edges:
                edgeCoords = lineCoords.iloc[j]
                ax.plot([edgeCoords[0], edgeCoords[1]],[edgeCoords[2], edgeCoords[3]], linewidth=4,marker="o",\
                     alpha=opacity, markersize=8,color=edgeCoords[4],clip_on=False)
                ax.axison = False
                ax.set_aspect('equal')
        # Exception for line(s) with only one edge
        else:
            edgeCoords = lineCoords.ix[i]
            ax.plot([edgeCoords[0], edgeCoords[1]],[edgeCoords[2], edgeCoords[3]],linewidth=4,marker="o",\
                alpha=opacity, markersize=8,color=edgeCoords[4],clip_on=False)
            ax.axison = False
            ax.set_aspect('equal')
    plt.tight_layout()
    setFigLinesBW(fig)
    fig.savefig("sol-vienna-BW-%s-%s.png" %(soln[k][0].replace(".00",""),soln[k][1].replace(".00","")),
        dpi=300,bbox_inches='tight',transparent="True")
#plt.show()


