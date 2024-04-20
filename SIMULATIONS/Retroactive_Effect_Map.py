import sys, os, time
sys.path.append(os.path.dirname(os.path.abspath(os.path.dirname(__file__))))

from Torch_TISK_Class import TISK_Model as TISK;
from Torch_TISK_Class import List_Generate;
from SIMULATIONS.Retroactive_Effect import Retroactive_Effect
import numpy as np;

start_time = time.time()

phoneme_List, pronunciation_List = List_Generate("Pronunciation_Data_with_bl^S.txt");

# runs = 11 # no point doing runs -- there is no noise! 
min_fe = 0.00
max_fe = 0.16 # actually above
min_fi = -0.15
max_fi = 0.01 # actually above

# for testing
#runs = 3
#min_fe = 0.00
#max_fe = 0.02 # actually above
#min_fi = -0.015
#max_fi = -0.012 # actually above


at = 0
total = 16 * 16 
#Rawdata generate
for feedback_Excitation in np.arange(min_fe, max_fe, 0.01):
#for feedback_Excitation in np.arange(0.00, 0.02, 0.01):
    for feedback_Inhibition in np.arange(min_fi, max_fi, 0.01):
        at = at + 1
        #    for feedback_Inhibition in np.arange(-0.15, -0.13, 0.01):
        feedback_Excitation = np.round(feedback_Excitation, 2);
        feedback_Inhibition = np.round(feedback_Inhibition, 2);
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
            word_to_Diphone_Activation = feedback_Excitation,
            word_to_SPhone_Activation = feedback_Excitation,
            word_to_Diphone_Inhibition = feedback_Inhibition,
            word_to_SPhone_Inhibition = feedback_Inhibition,
        )
        feedback_TISK.Weight_Initialize();
        
        current_time = time.time()
        elapsed_time = current_time - start_time
        remaining = total - at
        seconds_per_file = elapsed_time / at
        estimated_remaining_time = remaining * seconds_per_file
        
        #message = f'File {at}/{total}: Feedback.FE_{feedback_Excitation:.2f}.FI_{feedback_Inhibition:.2f}_run{run:02d} :: {elapsed_time:.2f} s elapsed, {estimated_remaining_time:.2f} s left, {seconds_per_file:.2f} secs per file'
        message = f'File {at}/{total}: Feedback.FE_{feedback_Excitation:.2f}.FI_{feedback_Inhibition:.2f} :: {elapsed_time:.2f} s elapsed, {estimated_remaining_time:.2f} s left, {seconds_per_file:.2f} secs per file'
        sys.stderr.write(f'\r{message}')
        sys.stderr.flush()
        
        Retroactive_Effect(
            feedback_TISK,
            compound_Activation = 0.22, 
            # prefix="Retro.FE_{0:.2f}.FI_{1:.2f}_run{3:02d}".format(feedback_Excitation, feedback_Inhibition, run)
            #prefix=f"Retro.FE_{feedback_Excitation:.2f}.FI_{feedback_Inhibition:.2f}_run{run:02d}"
            prefix=f"Retro.FE_{feedback_Excitation:.2f}.FI_{feedback_Inhibition:.2f}"
        )

#Integration
##Retroactive Effect
#extract_Data = ["\t".join(["Feedback_Excitation", "Feedback_Inhibition", "Continuum_Step","bus_Size", "rush_Size", "Avg_Size"])];
extract_Data = ["\t".join(["Feedback_Excitation", "Feedback_Inhibition", "Cycle",
                           "/p/|pl^g", "/b/|pl^g", "/p/|bl^S", "/b/|bl^S",
                           "/p/|#l^g", "/b/|#l^g", "/p/|#l^S", "/b/|#l^S"])];

for feedback_Excitation in np.arange(min_fe, max_fe, 0.01):
    for feedback_Inhibition in np.arange(min_fi, max_fi, 0.01):        
        feedback_Excitation = np.round(feedback_Excitation, 2);
        feedback_Inhibition = np.round(feedback_Inhibition, 2);
        with open(f"Results/Retroactive_Effect/Retro.FE_{feedback_Excitation:.2f}.FI_{feedback_Inhibition:.2f}.Retroactive_Effect.txt", "r") as f:
            readLines = f.readlines()[1:];
            for readLine in readLines:
                extract_Data.append("\t".join([str(feedback_Excitation), str(feedback_Inhibition), readLine.strip()]));

with open("Results/Retroactive_Effect/Retro.FE.FI.Map.txt", "w") as f:
    f.write("\n".join(extract_Data));


