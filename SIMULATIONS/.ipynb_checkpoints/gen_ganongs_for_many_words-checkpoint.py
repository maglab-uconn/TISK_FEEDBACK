import random
import csv

# Function to read words from a file and return unique characters found
def read_words_and_characters_from_file(filename):
    words = []
    unique_characters = set()
    with open(filename, 'r') as file:
        for line in file:
            word = line.strip()
            words.append(word)
            unique_characters.update(word)
    return words, unique_characters

# Function to filter words by minimum length and sort them
def filter_and_sort_words(words, min_length):
    filtered_words = [word for word in words if len(word) >= min_length]
    filtered_words.sort(key=lambda w: (len(w), w))
    return filtered_words

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

# Main function to create lists of modified words, ensuring uniqueness
def create_modified_words(words, vowels, consonants):
    modified_words_lists = {}

    for word in words:
        modified_words = [word]  # Start with the original word
        word_letters = list(word)
        
        for idx, letter in enumerate(word_letters):
            if letter in vowels:
                new_word = replace_letter(word, idx, list(vowels), words + modified_words)
            else:
                new_word = replace_letter(word, idx, list(consonants), words + modified_words)
            
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

# Vowels (as a set initially for unique character processing)
vowels = {'a', 'i', '^', 'u'}

# Path to your file
filename = "Pronunciation_Data.txt"

# Read words and characters from the file
words, unique_characters = read_words_and_characters_from_file(filename)

# Determine consonants based on unique characters found in the file, converting to list for random.choice
consonants = list(unique_characters - vowels)
vowels = list(vowels)  # Convert vowels to list as well

# Filter and sort words by minimum length (3 or greater)
min_length = 3
words = filter_and_sort_words(words, min_length)

# Generate the modified words
modified_words_lists = create_modified_words(words, vowels, consonants)

# Output filename for the CSV
output_filename = "ganong_modified_words.csv"

# Write the results to a CSV
write_results_to_csv(modified_words_lists, output_filename)

print(f"Results have been written to {output_filename}.")
