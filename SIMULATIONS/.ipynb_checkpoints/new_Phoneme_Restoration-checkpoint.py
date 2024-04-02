import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;
from Model_Setup import *;
import numpy as np;
import os;


def Phoneme_Activation_with_Noise(model, phoneme_List, pronunciation = "l^kS^ri", check_Location_List = [0, 3, 6], prefix=""):
    result_Dict = {};
    
    all_Phoneme_String = "".join(phoneme_List); #Noise making
    
    for location in check_Location_List:        
        #Intact
        result_Dict[location, "Intact"]  = model.Extract_Data(
            pronunciation = pronunciation, 
            extract_Single_Phone_List = [pronunciation[location]]
            )[0][0]
        #Noise
        for noise in np.arange(0, 1.1, 0.1):    #0 to 1.0. step is 0.1
            noise = np.round(noise, 1);
            list_Pronunciation = list(pronunciation);
            list_Pronunciation[location] = all_Phoneme_String;
            activation_Ratio_Dict = {location: [noise] * len(all_Phoneme_String)} 

            result_Dict[location, noise]  = model.Extract_Data(
                pronunciation = list_Pronunciation,
                activation_Ratio_Dict = activation_Ratio_Dict,
                extract_Single_Phone_List = [pronunciation[location]]
                )[0][0]

    extract_Data = [];
    extract_Data.append("\t".join(["Word", "Location","Noise", "Cycle", "Activation"]));    
    for location in check_Location_List:
        for noise in ["Intact"] + list(np.arange(0, 1.1, 0.1)):
            if noise != "Intact":
                noise = np.round(noise, 1);
            for cycle, activation in enumerate(result_Dict[location, noise]):
                new_Line = [];            
                new_Line.append(str(pronunciation));
                new_Line.append(str(location));
                new_Line.append(str(noise));
                new_Line.append(str(cycle));
                new_Line.append(str(activation));
                extract_Data.append("\t".join(new_Line));
                    
    os.makedirs(os.getcwd().replace("\\", "/") + "/Results/Phoneme_Restoration", exist_ok= True);
        
    if prefix != "" and prefix[-1] != ".":
        prefix += ".";
    with open(os.getcwd().replace("\\", "/") + "/Results/Phoneme_Restoration/{}Phoneme_Restoration.txt".format(prefix), "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data));
        

if __name__ == "__main__":
    feedback_TISK = Get_Feedback_Model();
    no_Feedback_TISK = Get_No_Feedback_Model();
    original_TISK = Get_Original_Model();

    # Read the list of words from a text file
    words_list = []
    with open("words_list.txt", "r") as file:
        words_list = [line.strip() for line in file.readlines()]

    # Phoneme restoration for each word
    for word in words_list:
        print(f'-- Working on {word}')
        check_Location_List = list(range(len(word)))  # Specify all positions in the word
        Phoneme_Activation_with_Noise(feedback_TISK, feedback_TISK.phoneme_List, pronunciation=word, check_Location_List=check_Location_List, prefix="Feedback")
        Phoneme_Activation_with_Noise(no_Feedback_TISK, no_Feedback_TISK.phoneme_List, pronunciation=word, check_Location_List=check_Location_List, prefix="No_Feedback")
        # Phoneme_Activation_with_Noise(original_TISK, original_TISK.phoneme_List, pronunciation=word, check_Location_List=check_Location_List, prefix="Original")
