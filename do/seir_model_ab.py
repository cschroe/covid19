#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Mar 22 11:46:26 2020

@author: Chris Schroeder
"""

# Import libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import pylab as pl
from scipy.integrate import ode, solve_ivp

# Define function
def SEIRModel(d_grid,init,params):
    N, beta, sigma, gamma, mu = params
    S, E, I, R = init
    
    # System of ordinary difference equations
    dS = mu*(N-S) - (beta*S*I)/N
    
    dE = (beta*S*I)/N - (mu+sigma)*E
    
    dI = sigma*E - (mu+gamma)*I
    
    dR = gamma*I - mu*R + mu*N
    
    return(dS, dE, dI, dR)
    
# Define SEIR model parameters
N = 4413146 # Population 
beta = 0.95 # Infectious rate (probability of transmission per contact)
sigma = 1/5.2 # Incubation rate (1/avg. incubation period in days)
gamma = 1/3 # Recovery rate (1/infectious period in days)
mu = 0 # Birth rate/death rate

# Assumed basic reproductive number
brnr = (sigma/(mu+sigma))*(beta/(mu+gamma))

paramsAB = [N,beta,sigma,gamma,mu]

# Define ad-hoc parameters
hr = 0.14 # Case hospitalization rate
icur = # Case icu rate
mr = 0.03 # Case mortality rate

# Define initial values
S = N # Susceptible
E = 0 # Exposed
I = 1 # Infected
R = 0 # Recovered

init = [S,E,I,R]

# Define the time grid
d_min = 0
d_max = 365
d_grid = np.linspace(d_min,d_max,366)

solution = solve_ivp(fun=lambda t, y:SEIRModel(t,y,paramsAB),t_span=[d_min,d_max],y0=init,t_eval=d_grid)
            
output = pd.DataFrame({"t":solution["t"],"S":solution["y"][0],"E":solution["y"][1],"I":solution["y"][2],"R":solution["y"][3]}) 

iline = plt.plot("t","I","",data=output,color="blue",linewidth=2)
        