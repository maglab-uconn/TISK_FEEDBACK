import random
import csv

# Function to read words from a file
def read_words_from_file(filename):
    with open(filename, 'r') as file:
        words = file.read().splitlines()
    return words

# Function to filter words by specified lengths and sort them
def filter_and_sort_words(words, lengths):
    filtered_words = [word for word in words if len(word) in lengths]
    filtered_words.sort(key=lambda w: (len(w), w))
    return filtered_words

# Vowels and consonants
vowels = ['a', 'i', '^', 'u']
consonants = [chr(i) for i in range(97, 123) if chr(i) not in vowels]

# Function to replace a letter, ensuring the new word isn't in the original list
def replace_letter(word, idx, letter_pool, words):
    original_letter = word[idx]
    new_word = word
    attempts = 0
    
    while new_word in words or new_word[idx] == original_letter:
        new_letter = random.choice(letter_pool)
        new_word = word[:idx] + new_letter + word[idx+1:]
        attempts += 1
        if attempts > 50:
            return word
    return new_word

# Main function to create lists of modified words, ensuring uniqueness and desired length
def create_modified_words(words):
    modified_words_lists = {}

    for word in words:
        modified_words = [word]  # Start with the original word
        word_letters = list(word)
        
        for idx, letter in enumerate(word_letters):
            if letter in vowels:
                new_word = replace_letter(word, idx, vowels, words + modified_words)
            else:
                new_word = replace_letter(word, idx, consonants, words + modified_words)
            
            if new_word not in words and new_word not in modified_words:
                modified_words.append(new_word)
        
        modified_words_lists[word] = modified_words
    
    return modified_words_lists

# Write the results to a CSV file
def write_results_to_csv(modified_words_lists, output_filename):
    with open(output_filename, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(["Length", "Word", "Nonwords"])
        for word, modified_words in modified_words_lists.items():
            row = [len(word), word] + modified_words[1:]  # Exclude the original word from the nonwords list
            csvwriter.writerow(row)

# Path to your file
filename = "words.txt"

# Desired lengths
desired_lengths = [3, 4]

# Read words from the file
words = read_words_from_file(filename)

# Filter and sort words by specified lengths
words = filter_and_sort_words(words, desired_lengths)

# Generate the modified words
modified_words_lists = create_modified_words(words)

# Output filename for the CSV
output_filename = "modified_words.csv"

# Write the results to a CSV
write_results_to_csv(modified_words_lists, output_filename)

print(f"Results have been written to {output_filename}.")
