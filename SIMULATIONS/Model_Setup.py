from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;

def Get_Feedback_Model(pronunciation_File= "Pronunciation_Data.txt"):
    phoneme_List, pronunciation_List = List_Generate(pronunciation_File);

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
        word_to_Diphone_Activation = 0.09,
        word_to_SPhone_Activation = 0.09, 
        word_to_Diphone_Inhibition = -0.06, 
        word_to_SPhone_Inhibition = -0.06
        )
    feedback_TISK.Weight_Initialize();

    return feedback_TISK

def Get_No_Feedback_Model(pronunciation_File= "Pronunciation_Data.txt"):
    phoneme_List, pronunciation_List = List_Generate(pronunciation_File);

    #Setting TISK1.1 fb
    #Setting No FB
    no_Feedback_TISK = TISK(
        phoneme_List = phoneme_List,
        word_List = pronunciation_List,
        time_Slots = 10,
        nPhone_Threshold = 0.91
        )
    no_Feedback_TISK.Decay_Parameter_Assign(
        decay_Phoneme = 0.001, 
        decay_Diphone = 0.15, 
        decay_SPhone = 0.15, 
        decay_Word = 0.05
        )
    no_Feedback_TISK.Weight_Parameter_Assign(
        input_to_Phoneme_Weight = 1.0, 
        phoneme_to_Phone_Weight = 0.1,
        diphone_to_Word_Weight = 0.05, 
        sPhone_to_Word_Weight = 0.01, 
        word_to_Word_Weight = -0.001
        )
    no_Feedback_TISK.Feedback_Parameter_Assign(
        word_to_Diphone_Activation = 0,
        word_to_SPhone_Activation = 0,
        word_to_Diphone_Inhibition = 0,
        word_to_SPhone_Inhibition = 0,
        )
    no_Feedback_TISK.Weight_Initialize();

    return no_Feedback_TISK

def Get_Original_Model(pronunciation_File= "Pronunciation_Data.txt"):
    phoneme_List, pronunciation_List = List_Generate(pronunciation_File);
        
    original_TISK = TISK(
        phoneme_List = phoneme_List,
        word_List = pronunciation_List,
        time_Slots = 10,
        nPhone_Threshold = 0.91
        )
    original_TISK.Decay_Parameter_Assign(
        decay_Phoneme = 0.01,
        decay_Diphone = 0.01, 
        decay_SPhone = 0.01, 
        decay_Word = 0.05
        )
    original_TISK.Weight_Parameter_Assign(
        input_to_Phoneme_Weight = 1.0, 
        phoneme_to_Phone_Weight = 0.1,
        diphone_to_Word_Weight = 0.05, 
        sPhone_to_Word_Weight = 0.01, 
        word_to_Word_Weight = -0.005
        )
    original_TISK.Feedback_Parameter_Assign(
        word_to_Diphone_Activation = 0,
        word_to_SPhone_Activation = 0,
        word_to_Diphone_Inhibition = 0,
        word_to_SPhone_Inhibition = 0,
        )
    original_TISK.Weight_Initialize();

    return original_TISK
