import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;
from Model_Setup import *;
import numpy as np;
import os;

def Retroactive_Effect(model, compound_Activation = 0.22, prefix=""):    
    result_Dict = {};
        
    activation_Single_Phone, = model.Extract_Data(
        pronunciation = "pl^g", 
        extract_Single_Phone_List=["p", "b"]            
        )
    result_Dict["pl^g", "p"] = activation_Single_Phone[0];
    result_Dict["pl^g", "b"] = activation_Single_Phone[1];

    activation_Single_Phone, = model.Extract_Data(
        pronunciation = "bl^S", 
        extract_Single_Phone_List=["p", "b"]
        )
    result_Dict["bl^S", "p"] = activation_Single_Phone[0];
    result_Dict["bl^S", "b"] = activation_Single_Phone[1];

    activation_Single_Phone, = model.Extract_Data(
        pronunciation = ["pb", "l", "^", "g"],
        activation_Ratio_Dict = {0: (compound_Activation, compound_Activation)},
        extract_Single_Phone_List=["p", "b"]
        )
    result_Dict["#l^g", "p"] = activation_Single_Phone[0];
    result_Dict["#l^g", "b"] = activation_Single_Phone[1];

    activation_Single_Phone, = model.Extract_Data(
        pronunciation = ["pb", "l", "^", "S"],
        activation_Ratio_Dict = {0: (compound_Activation, compound_Activation)},
        extract_Single_Phone_List=["p", "b"]
        )
    result_Dict["#l^S", "p"] = activation_Single_Phone[0];
    result_Dict["#l^S", "b"] = activation_Single_Phone[1];
        
    extract_Data = [];
    extract_Data.append("\t".join(["Cycle","/p/|pl^g","/b/|pl^g","/p/|bl^S","/b/|bl^S","/p/|#l^g","/b/|#l^g","/p/|#l^S","/b/|#l^S"]));    
    for cycle in range(100):
        new_Line = [];        
        new_Line.append(str(cycle));
        for pronunciation in ["pl^g", "bl^S", "#l^g", "#l^S"]:
            for phoneme in ["p", "b"]:
                new_Line.append(str(result_Dict[pronunciation, phoneme][cycle]));
        extract_Data.append("\t".join(new_Line));

    os.makedirs(os.getcwd().replace("\\", "/") + "/Results/Retroactive_Effect", exist_ok= True);

    if prefix != "" and prefix[-1] != ".":
        prefix += ".";
    with open(os.getcwd().replace("\\", "/") + "/Results/Retroactive_Effect/{}Retroactive_Effect.txt".format(prefix), "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data));


if __name__ == "__main__":
    feedback_TISK = Get_Feedback_Model(pronunciation_File= "Pronunciation_Data_with_bl^S.txt");
    no_Feedback_TISK = Get_No_Feedback_Model(pronunciation_File= "Pronunciation_Data_with_bl^S.txt");
    original_TISK = Get_Original_Model(pronunciation_File= "Pronunciation_Data_with_bl^S.txt");
    
    #Retroactive effect
    Retroactive_Effect(feedback_TISK, compound_Activation = 0.22, prefix="Feedback")
    Retroactive_Effect(no_Feedback_TISK, compound_Activation = 0.22, prefix="No_Feedback")
    Retroactive_Effect(original_TISK, compound_Activation = 0.22, prefix="Original")
