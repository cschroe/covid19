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

paramsAB = [N,beta,sigma,gamma,mu]

# Implied basic reproductive number
brnr = (sigma/(mu+sigma))*(beta/(mu+gamma))

# Define initial values
S = N # Susceptible
E = 0 # Exposed
I = 1 # Infected
R = 0 # Recovered

init = [S,E,I,R]

# Define ad-hoc parameters
hr = 0.14 # Case hospitalization rate
icur = 0.06 # Case icu rate
mr = 0.02 # Case mortality rate

# Define the time grid
d_min = 0
d_max = 365
d_grid = np.linspace(d_min,d_max,366)

# Solve the model
solution = solve_ivp(fun=lambda t, y:SEIRModel(t,y,paramsAB),t_span=[d_min,d_max],y0=init,t_eval=d_grid)

# Place solution in a pandas data frame
output = pd.DataFrame({"t":solution["t"],"S":solution["y"][0],"E":solution["y"][1],"I":solution["y"][2],"R":solution["y"][3]}) 

# Use ad-hoc parameters to calculate hospitalizations, icu admissions, deaths
output['hospital'] = output['I']*hr
output['icu'] = output['I']*icur
output['new_deaths'] = output['I']*mr
output['cumu_deaths'] = output['new_deaths'].cumsum()

# Plot
## Infected
inf_curve = plt.plot("t","I","",data=output,color="blue",linewidth=2, label='Infected')
## Hospital
hospital_curve = plt.plot("t","hospital","",data=output,color="green",linewidth=2, label='Hospitalizations')
## ICU
icu_curve = plt.plot("t","icu","",data=output,color="black",linewidth=2, label='ICU')
## Deaths
death_curve = plt.plot("t","cumu_deaths","",data=output,color="red",linewidth=2, label='Deaths')
## Environment
plt.xlabel('Days')
plt.ylabel('Individuals')
plt.title("Alberta")
plt.legend()









