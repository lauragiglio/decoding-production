# -*- coding: utf-8 -*-
"""
Created on Tue Apr  5 18:23:12 2022

@author: laugig
"""

import os
#from mvpa2.suite import *
import glob
import pandas as pd
import sys

for s in range(1,41):

    nruns = [1,2,3,4,5,6]   

    subj = str(s).zfill(2)
    subjdir = 'sub-0'+subj
    
    spmdir = 'P:/3011226.02/bids/derivatives/SPM/firstlevel/'+subjdir
    MVPAdir = 'P:/3011226.02/bids/derivatives/pyMVPA/'+subjdir+'/allsents/'
    
      # find indices per categories
    allsents=[]
    count = 0
    for r in nruns:
        sentrun = pd.read_csv(spmdir+'/sents'+str(r)+'.csv')
        sentrun['chunks'] = count
        allsents.append(sentrun)
        count += 1
        
    allsents = pd.concat(allsents,ignore_index=True)  
    
    agents= allsents[['cat_agentsaid','chunks']]
    patients= allsents[['cat_patientsaid','chunks']]
    subjs = allsents[['cat_noun1said','chunks']]
    objs = allsents[['cat_noun2said','chunks']]
    verb = allsents[['cat_verb1said','chunks']]
    voice = allsents[['Voicesaid','chunks']]
    voice.Voicesaid = ['Active' if x == 'Active' else 'Passive' for x in voice.Voicesaid]
    
    agents.to_csv(MVPAdir+'/agent_cat.txt',sep='\t',header=False,index=False)
    patients.to_csv(MVPAdir+'/patient_cat.txt',sep='\t',header=False,index=False)
    subjs.to_csv(MVPAdir+'/subj_cat.txt',sep='\t',header=False,index=False)
    objs.to_csv(MVPAdir+'/obj_cat.txt',sep='\t',header=False,index=False)
    verb.to_csv(MVPAdir+'/verb_cat.txt',sep='\t',header=False,index=False)
    voice.to_csv(MVPAdir+'/voice_cat.txt',sep='\t',header=False,index=False)
