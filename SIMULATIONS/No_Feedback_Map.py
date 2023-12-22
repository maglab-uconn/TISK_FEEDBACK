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
for nPhone_Decay in reversed(np.arange(0.00, 0.16, 0.01)):
    for word_to_Word_Weight in reversed(np.arange(-0.015, 0.001, 0.001)):
        nPhone_Decay = np.round(nPhone_Decay, 2);
        word_to_Word_Weight = np.round(word_to_Word_Weight, 3);
        #Setting TISK1.1 fb
        no_Feedback_TISK = TISK(
            phoneme_List = phoneme_List,
            word_List = pronunciation_List,
            time_Slots = 10,
            nPhone_Threshold = 0.91
            )
        no_Feedback_TISK.Decay_Parameter_Assign(
            decay_Phoneme = 0.001, 
            decay_Diphone = nPhone_Decay, 
            decay_SPhone = nPhone_Decay, 
            decay_Word = 0.05
            )
        no_Feedback_TISK.Weight_Parameter_Assign(
            input_to_Phoneme_Weight = 1.0, 
            phoneme_to_Phone_Weight = 0.1, 
            diphone_to_Word_Weight = 0.05, 
            sPhone_to_Word_Weight = 0.01, 
            word_to_Word_Weight = word_to_Word_Weight
            )
        no_Feedback_TISK.Feedback_Parameter_Assign(
            word_to_Diphone_Activation = 0,
            word_to_SPhone_Activation = 0,
            word_to_Diphone_Inhibition = 0,
            word_to_SPhone_Inhibition = 0,
            )
        no_Feedback_TISK.Weight_Initialize();

        Graceful_Degradation(
            model= no_Feedback_TISK,
            pronunciation_List= pronunciation_List,
            participants = 16,
            noise_LOC_Step = 0.01,
            noise_LOC_Step_Count = 15,
            prefix="No_Feedback.PD_{0:.2f}.WW_{1:.3f}".format(nPhone_Decay, word_to_Word_Weight)
            )

#Integration
##Graceful Degradation
extract_Data = ["\t".join(["NPhone_Decay", "WtoW_Weight", "Participant_Index","Noise_LOC","Reaction_Time","Accuracy"])];

for nPhone_Decay in reversed(np.arange(0.00, 0.16, 0.01)):
    for word_to_Word_Weight in reversed(np.arange(-0.015, 0.001, 0.001)):
        nPhone_Decay = np.round(nPhone_Decay, 2);
        word_to_Word_Weight = np.round(word_to_Word_Weight, 3);
        with open("Results/Graceful_Degradation/No_Feedback.PD_{0:.2f}.WW_{1:.3f}.Graceful_Degradation.txt".format(nPhone_Decay, word_to_Word_Weight), "r") as f:
            readLines = f.readlines()[1:];
            for readLine in readLines:
                extract_Data.append("\t".join([str(nPhone_Decay), str(word_to_Word_Weight), readLine.strip()]));

with open("Results/Graceful_Degradation/No_Feedback.PD.WW.Map.txt", "w") as f:
    f.write("\n".join(extract_Data));
