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
# S -> E -> I -> R
#             -> D
def SEIRModel(d_grid,init,params):
    N, beta, sigma, gamma, mr = params
    S, E, I, R, D = init
    
    # System of ordinary difference equations
    dS = - (beta*S*I)/N
    
    dE = (beta*S*I)/N - sigma*E
    
    dI = sigma*E - gamma*I
    
    dR = gamma*I
    
    dD = gamma*I*mr
    
    return(dS, dE, dI, dR, dD)
    
# Define SEIR model parameters
N = 4413146 # Population 
beta = 0.1 # Infectious rate (probability of transmission per contact)
sigma = 1/5.2 # Incubation rate (1/avg. incubation period in days)
gamma = 1/18 # Recovery rate (1/avg. duration of illness in days)
mr = 0.01 # Mortality rate

paramsAB = [N,beta,sigma,gamma,mr]

# Implied basic reproductive number
Rnot = beta/gamma

# Define initial values
S = N # Susceptible
E = 300 # Exposed
I = 300 # Infected
R = 0 # Recovered
D = 0 # Deceased

init = [S,E,I,R,D]

# Define ad-hoc parameters
hr = 0.05 # Case hospitalization rate
icur = 0.01 # Case icu rate

# Define the time grid
d_min = 0
d_max = 365
d_grid = np.linspace(d_min,d_max,366)

# Solve the model
solution = solve_ivp(fun=lambda t, y:SEIRModel(t,y,paramsAB),t_span=[d_min,d_max],y0=init,t_eval=d_grid)

# Place solution in a pandas data frame
output = pd.DataFrame({"t":solution["t"],"S":solution["y"][0],"E":solution["y"][1],"I":solution["y"][2],"R":solution["y"][3],"D":solution["y"][4]}) 

# Use ad-hoc parameters to calculate hospitalizations, icu admissions, deaths
output['hospital'] = output['I']*hr
output['icu'] = output['I']*icur

# Plot
## Infected
inf_curve = plt.plot("t","I","",data=output,color="blue",linewidth=2, label='Infected')
## Hospital
hospital_curve = plt.plot("t","hospital","",data=output,color="green",linewidth=2, label='Hospitalizations')
## ICU
icu_curve = plt.plot("t","icu","",data=output,color="black",linewidth=2, label='ICU')
## Deaths
death_curve = plt.plot("t","D","",data=output,color="red",linewidth=2, label='Deaths')
## Environment
plt.xlabel('Days')
plt.ylabel('Individuals')
plt.title("Alberta")
plt.legend()









