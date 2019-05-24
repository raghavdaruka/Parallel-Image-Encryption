# -*- coding: utf-8 -*-
"""
Created on Thu Apr 11 14:15:23 2019

@author: raghav
"""

import matplotlib.pyplot as plt
import numpy as np
import pylab
n =[10,50,100,150]
serial=[0.0070742,0.0458006,0.11834478,0.245316]
openMpi=[1.96695,6.9930,52.64,362.299]
cuda=np.array([1.289920,5.9012,15.5872,33.7572])
div=np.array([0.001,0.001,0.001,0.001])
cuda=cuda*div;
openMpi=openMpi*div;
#plt.plot(n,serial,color='r')
#plt.plot(n,cuda,color='g')
pylab.plot(n,serial,'-r',label='Serial')
pylab.plot(n,cuda,'-g',label='CUDA')
pylab.plot(n,openMpi,'-b',label='MPI')
pylab.legend(loc='upper left')

pylab.show()