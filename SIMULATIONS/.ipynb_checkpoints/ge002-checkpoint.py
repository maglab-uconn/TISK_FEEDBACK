import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;
from Model_Setup import *;
import numpy as np;

def Ganong_Effect(model, forms, phoneme_position, step=0.055, step_Count=7, prefix=""):
    if prefix != "" and prefix[-1] != ".":
        prefix += "."

    if forms[0][phoneme_position-1] == forms[1][phoneme_position-1]:
        warnings.warn("The phonemes at the specified position are the same. Analysis might not be meaningful.")

    step_Limit = step * (step_Count + 1)
    peak_Dict = {}
    ratio_Dict = {}

    phonemes = [forms[0][phoneme_position-1], forms[1][phoneme_position-1]]

    for value in np.arange(step, step_Limit, step):
        for pronunciation in forms:
            # Construct ganong_form by replacing the critical phoneme with a blend of both phonemes
            ganong_form = list(pronunciation)
            ganong_form[phoneme_position-1] = ''.join(phonemes)  # Replace with 'sS' or equivalent

            activation_Single_Phone, = model.Extract_Data(
                pronunciation=ganong_form,
                activation_Ratio_Dict={phoneme_position-1: (value, step_Limit - value)},
                extract_Single_Phone_List=phonemes
            )
            
            key_base = "".join(ganong_form) + f"_{value}"


            peak_p1 = np.max(activation_Single_Phone[0])
            peak_p2 = np.max(activation_Single_Phone[1])
            peak_Dict[key_base, phonemes[0]] = peak_p1
            peak_Dict[key_base, phonemes[1]] = peak_p2
            
            # Check to prevent division by zero
            total_peak = peak_p1 + peak_p2
            if total_peak > 0:
                ratio_Dict[key_base, phonemes[0]] = peak_p1 / total_peak
                ratio_Dict[key_base, phonemes[1]] = peak_p2 / total_peak
            else:
                ratio_Dict[key_base, phonemes[0]] = np.nan  # Or set to 0 or another placeholder value
                ratio_Dict[key_base, phonemes[1]] = np.nan


    extract_Data = []
    headers = ["Continuum_Step"]
    # Dynamically create headers based on the forms and phonemes
    for form in forms:
        for phoneme in phonemes:
            headers.append(f"{form}_{phoneme}")
    extract_Data.append("\t".join(headers))
            
    for continuum_step, value in enumerate(np.arange(step, step * (step_Count + 1), step)):
        new_Line = [str(continuum_step)]
        for form in forms:
            ganong_form = list(form)
            ganong_form[phoneme_position-1] = ''.join(phonemes)
            ganong_form_str = "".join(ganong_form)
            for phoneme in phonemes:
                key_base = f"{ganong_form_str}_{value}"
                ratio = ratio_Dict.get((key_base, phoneme), 0)
                new_Line.append(str(ratio))
        extract_Data.append("\t".join(new_Line))

    if not os.path.exists(os.getcwd().replace("\\", "/") + "/Ganong_Effect"):
        os.makedirs(os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect", exist_ok= True);
    with open(os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect/{}Ganong_effect.Raw.txt".format(prefix), "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data) + "\n");

if __name__ == "__main__":
    feedback_TISK = Get_Feedback_Model()
    no_Feedback_TISK = Get_No_Feedback_Model()
    original_TISK = Get_Original_Model()

    forms = ('b^s', 'b^S')  # The two forms to analyze
    phoneme_position = 3  # Specifying the final position, assuming 1-based indexing

    # Ganong Effect
    Ganong_Effect(feedback_TISK, forms, phoneme_position, step=0.055, step_Count=7, prefix="Feedback")
    Ganong_Effect(no_Feedback_TISK, forms, phoneme_position, step=0.055, step_Count=7, prefix="No_Feedback")
    Ganong_Effect(original_TISK, forms, phoneme_position, step=0.055, step_Count=7, prefix="Original")
