import random
import csv

def read_words_and_characters_from_file(filename):
    words = []
    unique_characters = set()
    with open(filename, 'r') as file:
        for line in file:
            word = line.strip()
            words.append(word)
            unique_characters.update(word)
    return words, unique_characters

def filter_and_sort_words(words, min_length):
    filtered_words = [word for word in words if len(word) >= min_length]
    filtered_words.sort(key=lambda w: (len(w), w))
    return filtered_words

def replace_letter(word, idx, letter_pool, words, existing_chars, max_attempts=20):
    attempts = 0
    while attempts < max_attempts:
        new_letter = random.choice(letter_pool)
        if new_letter not in existing_chars:
            new_word = word[:idx] + new_letter + word[idx+1:]
            if new_word not in words:
                return new_word
        attempts += 1
    return None  # Return None if a suitable replacement isn't found

def create_modified_words(words, vowels, consonants):
    modified_words_lists = {}
    
    for word in words:
        modified_words = [word]  # Start with the original word
        word_letters = set(word)  # Unique characters in the word
        fail_flag = False
        
        for idx, letter in enumerate(word):
            if fail_flag:
                break
            letter_pool = vowels if letter in vowels else consonants
            new_word = replace_letter(word, idx, letter_pool, words, word_letters)
            
            if new_word:
                modified_words.append(new_word)
            else:
                fail_flag = True  # Failed to find a suitable replacement

        if not fail_flag:
            modified_words_lists[word] = modified_words[1:]  # Exclude the original word
    
    return modified_words_lists

def write_results_to_csv(modified_words_lists, output_filename):
    with open(output_filename, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(["Length", "Word", "Nonwords"])
        for word, modified_words in modified_words_lists.items():
            row = [len(word), word] + modified_words
            csvwriter.writerow(row)

vowels = {'a', 'i', '^', 'u'}

filename = "Pronunciation_Data.txt"

words, unique_characters = read_words_and_characters_from_file(filename)

consonants = list(unique_characters - vowels)
vowels = list(vowels)  # Convert vowels to list

min_length = 3
words = filter_and_sort_words(words, min_length)

modified_words_lists = create_modified_words(words, vowels, consonants)

output_filename = "ganong_modified_words.csv"

write_results_to_csv(modified_words_lists, output_filename)

print(f"Results have been written to {output_filename}.")
