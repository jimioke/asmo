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


# titles = pd.read_csv('vienna_results.txt', skiprows=16,skipfooter = 3,
#                    header = [0,1,2,3,4],comment='jump')
# reader = pd.read_csv('viennafrontier.csv', chunksize=90)
# data = {};
# for k in arange(1,6):
#     data[k] = reader.get_chunk(90) 

# for k in arange(1,6):
#     soln = titles.loc[k-1]   #index properly
#     soln = soln[0].split()  #separate values
#     data1 = data[k]
#     edgesperline = pd.Series(data1['ln']).value_counts()
#     ind=data1.set_index(['ln'])
#     indlist = ind.index.unique() #changed from "list" to "indlist" 7/29/14
#     opacity= 1
#     plt.figure(num=k) # new figure instance
#     for i in indlist:  #changed from list to indlist
#         new = ind[ind.index==i] #changed from ind.loc[i]
#         stations = edgesperline.loc[i]
#         if stations != 1:
#             edges = np.arange(stations)
#             for j in edges:
#                 new2 = new.iloc[j]
#                 plt.plot([new2[0], new2[1]],[new2[2], new2[3]], linewidth=4,marker="o",\
#                      alpha=opacity, markersize=8,color=new2[4],clip_on=False)
#         else:
#             new2 = new
#             plt.plot([new2[0], new2[1]],[new2[2], new2[3]],linewidth=4,marker="o",\
#                 alpha=opacity, markersize=8,color=new2[4],clip_on=False)
        

#     #color=next(colors)
#     #plt.axis([-2, 15, -2, 15])
#     #plt.axis('off')
#     #plt.title('First Example Metro Map')
#     #plt.spines.set_color('none')
#     #plt.legend(loc='upper left')
#     #plt.grid(False)
#     plt.gca().axison = False
#     plt.axes().set_aspect('equal')
#     #plt.savefig("mapvienna-%s-%s.png" %(soln[1].replace(".00",""),soln[2].replace(".00","")),
#     #    dpi=300,bbox_inches='tight',transparent="True") 
#     plt.show()



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
    plt.figure(num=k+1)  
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
    plt.savefig("sol-vienna-%s-%s.png" %(soln[k][0].replace(".00",""),soln[k][1].replace(".00","")),
                dpi=300,bbox_inches='tight',transparent="True")
    plt.close()
plt.show()