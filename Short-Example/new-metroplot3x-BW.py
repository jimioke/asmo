import matplotlib.pyplot as plt
import numpy as np

def setAxLinesBW(ax):
    """
    Take each Line2D in the axes, ax, and convert the line style to be 
    suitable for black and white viewing.
    """
    MARKERSIZE = 8

    COLORMAP = {
        'r': {'marker': 'o', 'dash': (None,None)},
        'g': {'marker': 'o', 'dash': [5,5]},
        'b': {'marker': 'o', 'dash': [5,3,1,3]},
        'DarkOrange': {'marker': None, 'dash': [1,3]},
        'm': {'marker': 'o', 'dash': [5,2,5,2,5,10]},
        'y': {'marker': 'o', 'dash': [5,3,1,2,1,10]},
        #'k': {'marker': 'o', 'dash': (None,None)} #[1,2,1,10]}
        }

    for line in ax.get_lines() + ax.get_legend().get_lines():
        origColor = line.get_color()
        line.set_color('black')
        line.set_dashes(COLORMAP[origColor]['dash'])
        #line.set_marker(COLORMAP[origColor]['marker'])
        #line.set_markersize(MARKERSIZE)

def setFigLinesBW(fig):
    """
    Take each axes in the figure, and for each line in the axes, make the
    line viewable in black and white.
    """
    for ax in fig.get_axes():
        setAxLinesBW(ax)

xval = np.arange(100)*.01

fig = plt.figure()
ax = fig.add_subplot(211)

ax.plot(xval,np.cos(2*np.pi*xval))
ax.plot(xval,np.cos(3*np.pi*xval))
ax.plot(xval,np.cos(4*np.pi*xval))
ax.plot(xval,np.cos(5*np.pi*xval))
ax.plot(xval,np.cos(6*np.pi*xval))
ax.plot(xval,np.cos(7*np.pi*xval))
ax.plot(xval,np.cos(8*np.pi*xval))

ax = fig.add_subplot(212)
ax.plot(xval,np.cos(2*np.pi*xval))
ax.plot(xval,np.cos(3*np.pi*xval))
ax.plot(xval,np.cos(4*np.pi*xval))
ax.plot(xval,np.cos(5*np.pi*xval))
ax.plot(xval,np.cos(6*np.pi*xval))
ax.plot(xval,np.cos(7*np.pi*xval))
ax.plot(xval,np.cos(8*np.pi*xval))

fig.savefig("colorDemo.png")
setFigLinesBW(fig)
fig.savefig("bwDemo.png")