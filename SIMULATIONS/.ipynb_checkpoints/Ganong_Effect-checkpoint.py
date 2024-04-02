import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;
from Model_Setup import *;
import numpy as np;

def Ganong_Effect(model, step=0.055, step_Count = 7, prefix=""):
    if prefix != "" and prefix[-1] != ".":
        prefix += ".";

    step_Limit = step * (step_Count + 1);
    peak_Dict = {};
    ratio_Dict = {};

    # initialize to avoid key errors
    for value in np.arange(step, step_Limit, step):
        for pronunciation in ["b^sS", "r^sS", "sS"]:
            for phoneme in ["s", "S"]:
                # Initialize missing keys to 0
                if (pronunciation, value, phoneme) not in peak_Dict:
                    peak_Dict[pronunciation, value, phoneme] = 0

    fudge = 0.0000001
    for value in np.arange(step, step_Limit, step):        
        activation_Single_Phone, = model.Extract_Data(
            pronunciation=["b", "^", "sS"], 
            activation_Ratio_Dict = {2: (value, step_Limit - value)},
            extract_Single_Phone_List=["s", "S"]
            )
        peak_Dict["b^sS", value, "s"] = np.max(activation_Single_Phone[0]) + fudge
        peak_Dict["b^sS", value, "S"] = np.max(activation_Single_Phone[1]) + fudge
        
        peak_0 = peak_Dict["b^sS", value, "s"]
        peak_1 = peak_Dict["b^sS", value, "S"]
        peak_sum = peak_0 + peak_1

        print(f'Working on "b^sS". peak_0:{peak_0}, peak_1:{peak_1}, peak_sum:{peak_sum}')

        if peak_sum > 0:
            ratio_Dict["b^sS", value, "s"] = peak_0 / peak_sum
            ratio_Dict["b^sS", value, "S"] = peak_1 / peak_sum
        else:
            ratio_Dict["b^sS", value, "s"] = np.nan
            ratio_Dict["b^sS", value, "S"] = np.nan

        activation_Single_Phone, = model.Extract_Data(
            pronunciation=["r", "^", "sS"], 
            activation_Ratio_Dict = {2: (value, step_Limit - value)},
            extract_Single_Phone_List=["s", "S"]
            )
        peak_Dict["r^sS", value, "s"] = np.max(activation_Single_Phone[0]) + fudge
        peak_Dict["r^sS", value, "S"] = np.max(activation_Single_Phone[1]) + fudge
        
        peak_0 = peak_Dict["r^sS", value, "s"]
        peak_1 = peak_Dict["r^sS", value, "S"]
        peak_sum = peak_0 + peak_1

        print(f'Working on "r^sS". peak_0:{peak_0}, peak_1:{peak_1}, peak_sum:{peak_sum}')
        
        if peak_sum > 0:
            ratio_Dict["r^sS", value, "s"] = peak_Dict.get(("r^sS", value, "s"), 0) / peak_sum
            ratio_Dict["r^sS", value, "S"] = peak_Dict.get(("r^sS", value, "S"), 0) / peak_sum
        else:
            ratio_Dict["r^sS", value, "s"] = np.nan
            ratio_Dict["r^sS", value, "S"] = np.nan


        activation_Single_Phone, = model.Extract_Data(
            pronunciation=["sS"], 
            activation_Ratio_Dict = {0: (value, step_Limit - value)},
            extract_Single_Phone_List=["s", "S"]
            )
        peak_Dict["sS", value, "s"] = np.max(activation_Single_Phone[0]) + fudge
        peak_Dict["sS", value, "S"] = np.max(activation_Single_Phone[1]) + fudge
        
        peak_0 = peak_Dict["sS", value, "s"]
        peak_1 = peak_Dict["sS", value, "S"]
        peak_sum = peak_0 + peak_1

        print(f'Working on "sS". peak_0:{peak_0}, peak_1:{peak_1}, peak_sum:{peak_sum}')
        if peak_sum > 0:
            ratio_Dict["sS", value, "s"] = peak_Dict.get(("sS", value, "s"), 0) / peak_sum
            ratio_Dict["sS", value, "S"] = peak_Dict.get(("sS", value, "S"), 0) / peak_sum
        else:
            ratio_Dict["sS", value, "s"] = np.nan
            ratio_Dict["sS", value, "S"] = np.nan
    
    extract_Data = [];
    extract_Data.append("\t".join(["Continuum_Step","bus_s", "bus_S", "rush_s", "rush_S", "Single_s", "Single_S"]));
    for continuum_Step, value in enumerate(np.arange(step, step * (step_Count + 1), step)):
        bus_Effect_Size = ratio_Dict["b^sS", value, "s"] - ratio_Dict["sS", value, "s"]
        rush_Effect_Size = ratio_Dict["r^sS", value, "S"] - ratio_Dict["sS", value, "S"]
        
        new_Line = [];
        new_Line.append(str(continuum_Step));
        new_Line.append(str(ratio_Dict["b^sS", value, "s"]));
        new_Line.append(str(ratio_Dict["b^sS", value, "S"]));
        new_Line.append(str(ratio_Dict["r^sS", value, "s"]));        
        new_Line.append(str(ratio_Dict["r^sS", value, "S"]));
        new_Line.append(str(ratio_Dict["sS", value, "s"]));        
        new_Line.append(str(ratio_Dict["sS", value, "S"]));
        
        extract_Data.append("\t".join(new_Line));
    
    if not os.path.exists(os.getcwd().replace("\\", "/") + "/Ganong_Effect"):
        os.makedirs(os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect", exist_ok= True);
    with open(os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect/{}Ganong_effect.Raw.txt".format(prefix), "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data) + '\n');

            
    extract_Data = [];
    extract_Data.append("\t".join(["Continuum_Step","bus_Size", "rush_Size", "Avg_Size"]));
    for continuum_Step, value in enumerate(np.arange(step, step * (step_Count + 1), step)):
        bus_Effect_Size = ratio_Dict["b^sS", value, "s"] - ratio_Dict["sS", value, "s"]
        rush_Effect_Size = ratio_Dict["r^sS", value, "S"] - ratio_Dict["sS", value, "S"]
        new_Line = [];
        new_Line.append(str(continuum_Step));
        new_Line.append(str(bus_Effect_Size));        
        new_Line.append(str(rush_Effect_Size));
        new_Line.append(str(np.mean([bus_Effect_Size, rush_Effect_Size])));
        
        extract_Data.append("\t".join(new_Line));    
    
    os.makedirs(os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect", exist_ok= True);

    with open(os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect/{}Ganong_effect.txt".format(prefix), "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data) + '\n');


if __name__ == "__main__":
    feedback_TISK = Get_Feedback_Model();
    no_Feedback_TISK = Get_No_Feedback_Model();
    original_TISK = Get_Original_Model();

    #Ganong Effect
    Ganong_Effect(feedback_TISK, step=0.055, step_Count = 7, prefix="Feedback")
    Ganong_Effect(no_Feedback_TISK, step=0.055, step_Count = 7, prefix="No_Feedback")
    Ganong_Effect(original_TISK, step=0.055, step_Count = 7, prefix="Original")
