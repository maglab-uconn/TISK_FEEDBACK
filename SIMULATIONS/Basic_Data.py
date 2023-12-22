import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;
#from Basic_TISK_Class import TISK_Model as TISK;
#from Basic_TISK_Class import List_Generate;
from Model_Setup import *;
import numpy as np;
import os;

if __name__ == "__main__":
    feedback_TISK = Get_Feedback_Model();
    no_Feedback_TISK = Get_No_Feedback_Model();
    original_TISK = Get_Original_Model();

    print(feedback_TISK.Run_List(
        absolute_Acc_Criteria=0.32,
        relative_Acc_Criteria=0.05,
        time_Acc_Criteria=10,
        pronunciation_List= feedback_TISK.word_List,
        output_File_Name= "Results/Basic_Data/Feedback",
        raw_Data= True,
        categorize= True,
        reaction_Time= True
        ))

    print(no_Feedback_TISK.Run_List(
        absolute_Acc_Criteria=0.3,
        relative_Acc_Criteria=0.05,
        time_Acc_Criteria=10,
        pronunciation_List= no_Feedback_TISK.word_List,
        output_File_Name= "Results/Basic_Data/No_Feedback",        
        raw_Data= True,
        categorize= True,
        reaction_Time= True
        ))

    print(original_TISK.Run_List(
        absolute_Acc_Criteria=0.3,
        relative_Acc_Criteria=0.05,
        time_Acc_Criteria=10,
        pronunciation_List= original_TISK.word_List,
        output_File_Name= "Results/Basic_Data/Original",
        raw_Data= True,
        categorize= True,
        reaction_Time= True
        ))
