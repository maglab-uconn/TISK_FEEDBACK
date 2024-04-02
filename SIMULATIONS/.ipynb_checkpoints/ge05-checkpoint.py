import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK
from Model_Setup import *
import numpy as np

def Ganong_Effect(model, forms, critical_position, step=0.055, step_Count=7, prefix=""):
    if prefix != "" and prefix[-1] != ".":
        prefix += "."

    # step = 100 / (step_Count + 1) / 100
    step_Limit = step * (step_Count + 1)
    print(f'step limit: {step_Limit}')
    peak_Dict = {}
    ratio_Dict = {}

    phonemes = [form[critical_position] for form in forms]
    common_phonemes = [forms[0][:critical_position], forms[0][critical_position + 1:]]
    base_form = list(forms[0])
    base_form[critical_position] = "".join(phonemes)
    
    for value in np.arange(step, step_Limit, step):
        pronunciation = "".join(base_form)
        for phoneme in phonemes:
            peak_Dict[pronunciation, value, phoneme] = 0
            ratio_Dict[pronunciation, value, phoneme] = np.nan
          
    # print(f'PEAK DICT:\n{peak_Dict}\nRATIO DICT\n{ratio_Dict}')

    fudge = 0.000001
    for value in np.arange(step, step_Limit, step):
        activation_ratio_dict = {critical_position: (value, step_Limit - value)}
        activation_Single_Phone, = model.Extract_Data(
            pronunciation=base_form, 
            activation_Ratio_Dict=activation_ratio_dict,
            extract_Single_Phone_List=phonemes
        )
        pronunciation = "".join(base_form)
        for i, phoneme in enumerate(phonemes):
            peak_Dict[pronunciation, value, phoneme] = np.max(activation_Single_Phone[i]) + fudge
            peak_sum = sum(peak_Dict[pronunciation, value, p] for p in phonemes)

            if peak_sum > 0:
                for phoneme in phonemes:
                    ratio_Dict[pronunciation, value, phoneme] = peak_Dict[pronunciation, value, phoneme] / peak_sum
            else:
                for phoneme in phonemes:
                    ratio_Dict[pronunciation, value, phoneme] = np.nan

                    
    # print(f'######POST####\nPEAK DICT:\n{peak_Dict}\nRATIO DICT\n{ratio_Dict}')
    
    # Construct column headers
    if critical_position == 0:  # Critical phoneme is first
        header_phonemes = f"#{''.join(common_phonemes)}"
    elif critical_position == len(base_form) - 1:  # Critical phoneme is last
        header_phonemes = f"{''.join(common_phonemes)}#"
    else:  # Critical phoneme is in the middle
        header_phonemes = f"{common_phonemes[0]}#{common_phonemes[1]}"

    header = ["Continuum_Step"] + [f"{header_phonemes}_{phoneme}" for phoneme in phonemes]
    extract_Data = ["\t".join(header)]

    for continuum_Step, value in enumerate(np.arange(step, step * (step_Count + 1), step)):
        line = [str(continuum_Step)]
        for phoneme in phonemes:
            line.append(str(ratio_Dict[pronunciation, value, phoneme]))
        extract_Data.append("\t".join(line))
       
    form_string = "_".join([forms[0], forms[1], str(critical_position)])
    results_dir = os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect"
    os.makedirs(results_dir, exist_ok=True)
    with open(f"{results_dir}/{prefix}Ganong_effect.{form_string}.Raw.txt", "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data) + '\n')

if __name__ == "__main__":
    feedback_TISK = Get_Feedback_Model()
    no_feedback_TISK = Get_No_Feedback_Model()
    original_TISK = Get_Original_Model()

    forms_pairs = [('b^s', 'b^S'), ('r^s', 'r^S'), ('s', 'S')]
    critical_positions = [2, 2, 0]

    for forms, critical_position in zip(forms_pairs, critical_positions):
        print(f'\n---- {forms} ---- original TISK ---- ')
        Ganong_Effect(original_TISK, forms=forms, critical_position=critical_position, step=0.055, step_Count=7, prefix="original")
        print(f'\n---- {forms} ---- feedback TISK ---- ')
        Ganong_Effect(feedback_TISK, forms=forms, critical_position=critical_position, step=0.055, step_Count=7, prefix="feedback")
        print(f'\n---- {forms} ---- no feedback TISK ---- ')
        Ganong_Effect(no_feedback_TISK, forms=forms, critical_position=critical_position, step=0.055, step_Count=7, prefix="nofeedback")