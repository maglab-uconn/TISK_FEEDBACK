import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;
from Model_Setup import *;
import numpy as np;
import os;


def Graceful_Degradation(model, pronunciation_List, participants = 16, noise_LOC_Step = 0.005, noise_LOC_Step_Count = 15, prefix=""):    
    result_List_Dict = {};
    
    for noise_LOC in [0] + list(np.arange(noise_LOC_Step, noise_LOC_Step * (noise_LOC_Step_Count + 1), noise_LOC_Step)):
        result_List_Dict[noise_LOC] = [];

    if prefix != "" and prefix[-1] != ".":
        prefix += ".";

    for index in range(participants):
        print("{}Participant_{}....".format(prefix, index))
        _, _, _, _, reaction_Time, accuracy = model.Run_List(pronunciation_List, batch_Size = 212)
        result_List_Dict[0].append((reaction_Time, accuracy));            
        for noise_LOC in np.arange(noise_LOC_Step, noise_LOC_Step * (noise_LOC_Step_Count + 1), noise_LOC_Step):
            _, _, _, _, reaction_Time, accuracy = model.Run_List(pronunciation_List, noise = (noise_LOC, noise_LOC / 2));
            result_List_Dict[noise_LOC].append((reaction_Time, accuracy));

    extract_Data = [];
    extract_Data.append("\t".join(["Participant_Index", "Noise_LOC", "Reaction_Time","Accuracy"]));
    for index in range(participants):          
        for noise_LOC in [0] + list(np.arange(noise_LOC_Step, noise_LOC_Step * (noise_LOC_Step_Count + 1), noise_LOC_Step)):        
            new_Line = [];
            new_Line.append(str(index));
            new_Line.append(str(noise_LOC));
            new_Line.append(str(result_List_Dict[noise_LOC][index][0]));
            new_Line.append(str(result_List_Dict[noise_LOC][index][1]));
            extract_Data.append("\t".join(new_Line));
                
    os.makedirs(os.getcwd().replace("\\", "/") + "/Results/Graceful_Degradation", exist_ok= True);

    with open(os.getcwd().replace("\\", "/") + "/Results/Graceful_Degradation/{}Graceful_Degradation.txt".format(prefix), "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data));
        
        
if __name__ == "__main__":
    feedback_TISK = Get_Feedback_Model();
    no_Feedback_TISK = Get_No_Feedback_Model();
    original_TISK = Get_Original_Model();

    #Graceful Degradation
    Graceful_Degradation(
        model= feedback_TISK,
        pronunciation_List= feedback_TISK.word_List,
        participants = 16,
        noise_LOC_Step = 0.01,
        noise_LOC_Step_Count = 15,
        prefix="Feedback"
        ) 
    Graceful_Degradation(
        model= no_Feedback_TISK,
        pronunciation_List= no_Feedback_TISK.word_List,
        participants = 16,
        noise_LOC_Step = 0.01,
        noise_LOC_Step_Count = 15,
        prefix="No_Feedback"
        )
    Graceful_Degradation(
        model= original_TISK,
        pronunciation_List= original_TISK.word_List,
        participants = 16,
        noise_LOC_Step = 0.01,
        noise_LOC_Step_Count = 15,
        prefix="Original"
        )
