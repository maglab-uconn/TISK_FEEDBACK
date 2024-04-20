'''
This takes long time because of graceful degradation.
'''

import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;
from SIMULATIONS.Ganong_Effect import Ganong_Effect
from SIMULATIONS.Graceful_Degradation import Graceful_Degradation
import numpy as np;

phoneme_List, pronunciation_List = List_Generate("Pronunciation_Data.txt");

#Rawdata generate
for feedback_Excitation in np.arange(0.00, 0.16, 0.01):
    for feedback_Inhibition in np.arange(-0.15, 0.01, 0.01):
        feedback_Excitation = np.round(feedback_Excitation, 2);
        feedback_Inhibition = np.round(feedback_Inhibition, 2);
        #Setting TISK1.1 fb
        feedback_TISK = TISK(
            phoneme_List = phoneme_List,
            word_List = pronunciation_List,
            time_Slots = 10,
            nPhone_Threshold = 0.91
            )
        feedback_TISK.Decay_Parameter_Assign(
            decay_Phoneme = 0.001, 
            decay_Diphone = 0.1, 
            decay_SPhone = 0.1, 
            decay_Word = 0.05
            )
        feedback_TISK.Weight_Parameter_Assign(
            input_to_Phoneme_Weight = 1.0, 
            phoneme_to_Phone_Weight = 0.1, 
            diphone_to_Word_Weight = 0.05, 
            sPhone_to_Word_Weight = 0.01, 
            word_to_Word_Weight = -0.01
            )
        feedback_TISK.Feedback_Parameter_Assign(
            word_to_Diphone_Activation = feedback_Excitation,
            word_to_SPhone_Activation = feedback_Excitation,
            word_to_Diphone_Inhibition = feedback_Inhibition,
            word_to_SPhone_Inhibition = feedback_Inhibition,
            )
        feedback_TISK.Weight_Initialize();

        print("Feedback.FE_{0:.2f}.FI_{1:.2f} Ganong....".format(feedback_Excitation, feedback_Inhibition));
        Ganong_Effect(
            model= feedback_TISK,
            step=0.055,
            step_Count = 7,
            prefix="Feedback.FE_{0:.2f}.FI_{1:.2f}".format(feedback_Excitation, feedback_Inhibition)
            )

        Graceful_Degradation(
            model= feedback_TISK,
            pronunciation_List= pronunciation_List,
            participants = 16,
            noise_LOC_Step = 0.01,
            noise_LOC_Step_Count = 15,
            prefix="Feedback.FE_{0:.2f}.FI_{1:.2f}".format(feedback_Excitation, feedback_Inhibition)
            )

#Integration
##Ganong Effect
extract_Data = ["\t".join(["Feedback_Excitation", "Feedback_Inhibition", "Continuum_Step","bus_Size", "rush_Size", "Avg_Size"])];

for feedback_Excitation in np.arange(0.00, 0.16, 0.01):
    for feedback_Inhibition in np.arange(-0.15, 0.01, 0.01):        
        feedback_Excitation = np.round(feedback_Excitation, 2);
        feedback_Inhibition = np.round(feedback_Inhibition, 2);
        with open("Results/Ganong_Effect/Feedback.FE_{0:.2f}.FI_{1:.2f}.Ganong_effect.txt".format(feedback_Excitation, feedback_Inhibition), "r") as f:
            readLines = f.readlines()[1:];
            for readLine in readLines:
                extract_Data.append("\t".join([str(feedback_Excitation), str(feedback_Inhibition), readLine.strip()]));

with open("Results/Ganong_Effect/Feedback.FE.FI.Map.txt", "w") as f:
    f.write("\n".join(extract_Data));


##Graceful Degradation
extract_Data = ["\t".join(["Feedback_Excitation", "Feedback_Inhibition", "Participant_Index","Noise_LOC","Reaction_Time","Accuracy"])];

for feedback_Excitation in np.arange(0.00, 0.16, 0.01):
    for feedback_Inhibition in np.arange(-0.15, 0.01, 0.01):        
        feedback_Excitation = np.round(feedback_Excitation, 2);
        feedback_Inhibition = np.round(feedback_Inhibition, 2);
        with open("Results/Graceful_Degradation/Feedback.FE_{0:.2f}.FI_{1:.2f}.Graceful_Degradation.txt".format(feedback_Excitation, feedback_Inhibition), "r") as f:
            readLines = f.readlines()[1:];
            for readLine in readLines:
                extract_Data.append("\t".join([str(feedback_Excitation), str(feedback_Inhibition), readLine.strip()]));

with open("Results/Graceful_Degradation/Feedback.FE.FI.Map.txt", "w") as f:
    f.write("\n".join(extract_Data));
