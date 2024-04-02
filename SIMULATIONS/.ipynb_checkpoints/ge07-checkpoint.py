import sys, os
import csv
import random

sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK
from Model_Setup import *
import numpy as np

def Ganong_Effect(model, forms, position, step=0.055, step_Count=7, prefix=""):
    if prefix != "" and prefix[-1] != ".":
        prefix += "."

    # step = 100 / (step_Count + 1) / 100 # this would seem a more reasonable way, but it does not work! 
    step_Limit = step * (step_Count + 1)
    print(f'step limit: {step_Limit}')
    peak_Dict = {}
    ratio_Dict = {}

    phonemes = [form[position] for form in forms]
    print(f'For forms {forms} phonemes are {phonemes}')
    common_phonemes = [forms[0][:position], forms[0][position + 1:]]
    base_form = list(forms[0])
    base_form[position] = "".join(phonemes)
    
    for value in np.arange(step, step_Limit, step):
        pronunciation = "".join(base_form)
        for phoneme in phonemes:
            peak_Dict[pronunciation, value, phoneme] = 0
            ratio_Dict[pronunciation, value, phoneme] = np.nan
          
    # print(f'PEAK DICT:\n{peak_Dict}\nRATIO DICT\n{ratio_Dict}')

    fudge = 0.000001
    for value in np.arange(step, step_Limit, step):
        activation_ratio_dict = {position: (value, step_Limit - value)}
        resultsx = model.Extract_Data(
            pronunciation=base_form, 
            activation_Ratio_Dict=activation_ratio_dict,
            extract_Single_Phone_List=phonemes
        )
        activation_Single_Phone, = model.Extract_Data(
            pronunciation=base_form, 
            activation_Ratio_Dict=activation_ratio_dict,
            extract_Single_Phone_List=phonemes
        )
        print(f'# RESULTS: base_form:{base_form}, phonemes:{phonemes}, act_ratio_dic {activation_ratio_dict}\n --> act_Sing_Phon: {activation_Single_Phone}\n-----------------')
        pronunciation = "".join(base_form)
        print(f'Check peaks for phonemes {phonemes}')
        for i, phoneme in enumerate(phonemes):
            peak_Dict[pronunciation, value, phoneme] = np.max(activation_Single_Phone[i]) + fudge
            print(f'\t{i}:{phoneme}:{np.max(activation_Single_Phone[i])}')

        peak_sum = sum(peak_Dict[pronunciation, value, p] for p in phonemes)

        if peak_sum > 0:
            for phoneme in phonemes:
                ratio_Dict[pronunciation, value, phoneme] = peak_Dict[pronunciation, value, phoneme] / peak_sum
        else:
            for phoneme in phonemes:
                ratio_Dict[pronunciation, value, phoneme] = np.nan
                    

                    
    # print(f'######POST####\nPEAK DICT:\n{peak_Dict}\nRATIO DICT\n{ratio_Dict}')
    
    # Construct column headers
    if position == 0:  # Critical phoneme is first
        header_phonemes = f"#{''.join(common_phonemes)}"
    elif position == len(base_form) - 1:  # Critical phoneme is last
        header_phonemes = f"{''.join(common_phonemes)}#"
    else:  # Critical phoneme is in the middle
        header_phonemes = f"{common_phonemes[0]}#{common_phonemes[1]}"

    header = ["Continuum_Step"] + [f"{header_phonemes}_{phoneme}" for phoneme in phonemes]
    extract_Data = ["\t".join(header)]

    for continuum_Step, value in enumerate(np.arange(step, step * (step_Count + 1), step)):
        line = [str(continuum_Step)]
        for phoneme in phonemes:
            line.append(str(ratio_Dict[pronunciation, value, phoneme]))
            ### NEW LINE
        # for phoneme in phonemes:
        #     line.append(str(peak_Dict[pronunciation, value, phoneme]))
        extract_Data.append("\t".join(line))
       
    form_string = "_".join([forms[0], forms[1], str(position)])
    results_dir = os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect"
    os.makedirs(results_dir, exist_ok=True)
    with open(f"{results_dir}/{prefix}Ganong_effect.{form_string}.Raw.txt", "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data) + '\n')
        
        

def read_and_process_csv(filename, maxlength=4):
    form_pairs = []
    positions = []
    with open(filename, 'r', encoding='utf-8') as csvfile:
        csvreader = csv.reader(csvfile)
        #next(csvreader)  # Skip header
        for row in csvreader:
            length, original_word = int(row[0]), row[1]
            if length > maxlength:
                continue
            modified_words = row[2:]
            for modified_word in modified_words:
                # Identify the position of the modification
                for position, (orig_char, mod_char) in enumerate(zip(original_word, modified_word)):
                    if orig_char != mod_char:
                        form_pairs.append((original_word, modified_word))
                        positions.append(position)
                        break  # Assuming only one modification per pair
    return form_pairs, positions

if __name__ == "__main__":
    # Update with the correct paths and model setup functions
    # filename = "ganong_modified_words_test.csv"
    filename = "ganong_modified_words.csv"
    form_pairs, positions = read_and_process_csv(filename)
    
    # Assuming model setup functions are defined correctly
    original_TISK = Get_Original_Model()
    feedback_TISK = Get_Feedback_Model()
    no_feedback_TISK = Get_No_Feedback_Model()


    # Determine step count based on your CSV data or specific needs
    step_Count = 7
    stepconstant = 0.055 * step_Count

    step = stepconstant / step_Count # max should be 0.4
    # step = 0.01
    # step = 0.23

    # Process each pair for each model
    for forms, position in zip(form_pairs, positions):

        # Check that forms and positions seem correct
        # print(f'{forms}  -->    {position}')
        
        prefix = f"p{len(forms[0])}"  # Prefix based on word length
        # print(f'\n---- {prefix} -- {forms} ---- original TISK ---- ')
        # Ganong_Effect(original_TISK, forms=forms, position=position, step=step, step_Count=step_Count, prefix=prefix + "_original")
        print(f'\n---- {prefix} -- {forms} ---- feedback TISK ---- ')
        Ganong_Effect(feedback_TISK, forms=forms, position=position, step=step, step_Count=step_Count, prefix=prefix + "_feedback")
        print(f'\n---- {prefix} -- {forms} ---- no feedback TISK ---- ')
        Ganong_Effect(no_feedback_TISK, forms=forms, position=position, step=step, step_Count=step_Count, prefix=prefix + "_nofeedback")

