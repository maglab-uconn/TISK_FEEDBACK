import sys, os
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK
from Torch_TISK_Class import List_Generate
from Model_Setup import *
import numpy as np

def Ganong_Effect(model, forms, critical_position, step=0.055, step_Count=7, prefix=""):
    """
    Adjusts the Ganong Effect simulation to be dynamic based on user inputs.
    
    Args:
    model: The TISK model to use.
    forms: A tuple of the two forms to compare (e.g., ('b^s', 'b^S')).
    critical_position: The position of the critical phoneme in the forms.
    step: The step size for activation ratio adjustments.
    step_Count: The number of steps to simulate.
    prefix: Optional prefix for output files.
    """
    if prefix != "" and prefix[-1] != ".":
        prefix += "."

    step_Limit = step * (step_Count + 1)
    peak_Dict = {}
    ratio_Dict = {}

    # Dynamic form creation based on user input
    phonemes = [form[critical_position] for form in forms]  # Extract critical phonemes
    base_form = list(forms[0])  # Use the first form as base
    base_form[critical_position] = "".join(phonemes)  # Replace critical position with both phonemes
    
    # Initialize peak and ratio dictionaries
    for value in np.arange(step, step_Limit, step):
        pronunciation = "".join(base_form)
        for phoneme in phonemes:
            peak_Dict[pronunciation, value, phoneme] = 0  # Initialize peak values
            ratio_Dict[pronunciation, value, phoneme] = np.nan  # Initialize ratio values as NaN

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
            
            print(f'Working on "{pronunciation}". {phoneme}: {peak_Dict[pronunciation, value, phoneme]}, peak_sum: {peak_sum}')

    # Extract data and save results
    # Data extraction and writing
    header = ["Continuum_Step"] + [f"{form}_{phoneme}" for form in forms for phoneme in phonemes]
    extract_Data = ["\t".join(header)]
    for continuum_Step, value in enumerate(np.arange(step, step * (step_Count + 1), step)):
        line = [str(continuum_Step)]
        for form in forms:
            pronunciation = "".join(base_form)
            for phoneme in phonemes:
                line.append(str(ratio_Dict[pronunciation, value, phoneme]))
        extract_Data.append("\t".join(line))
    
    
    form_string = "_".join(forms)
    results_dir = os.getcwd().replace("\\", "/") + "/Results/Ganong_Effect"
    os.makedirs(results_dir, exist_ok=True)
    with open(f"{results_dir}/{prefix}Ganong_effect.{form_string}.Raw.txt", "w", encoding="utf8") as f:
        f.write("\n".join(extract_Data) + '\n')

if __name__ == "__main__":
    feedback_TISK = Get_Feedback_Model()
    no_feedback_TISK = Get_No_Feedback_Model()
    original_TISK = Get_Original_Model()

    # Example usage
    forms_pairs = [('b^s', 'b^S'), ('r^s', 'r^S'), ('s', 'S')]  # Example pairs
    critical_positions = [2, 2, 0]  # Corresponding critical positions

    for forms, critical_position in zip(forms_pairs, critical_positions):
        print(f'\n---- {forms} ---- original TISK ---- ')
        Ganong_Effect(original_TISK, forms=forms, critical_position=critical_position, step=0.055, step_Count=7, prefix="original")
        print(f'\n---- {forms} ---- feedback TISK ---- ')
        Ganong_Effect(feedback_TISK, forms=forms, critical_position=critical_position, step=0.055, step_Count=7, prefix="feedback")
        print(f'\n---- {forms} ---- no feedback TISK ---- ')
        Ganong_Effect(no_feedback_TISK, forms=forms, critical_position=critical_position, step=0.055, step_Count=7, prefix="nofeedback")
