import os
import secrets

def reset_files():
    current_folder = os.getcwd()
    path_to_tv = current_folder + '/modelsim/tv'
    for filename in os.listdir(path_to_tv):
        if filename != 'dictionary.txt':
            with open('./modelsim/tv/' + filename, 'w') as file:
                file.write('')

def main():

    reset_files()

    secretsGenerator = secrets.SystemRandom()

    waltKey = bytes(f'{secretsGenerator.randrange(1, 226):08b}', 'ascii')
    with open('./modelsim/tv/privatekey_w.txt', 'wb') as file:
        file.write(waltKey)


    jesseKey = bytes(f'{secretsGenerator.randrange(1, 226):08b}', 'ascii')
    with open('./modelsim/tv/privatekey_j.txt', 'wb') as file:
        file.write(jesseKey)

    with open('./modelsim/tv/dictionary.txt', 'r') as file:
        all_the_lines = file.readlines()
        line_to_read = secretsGenerator.randrange(1, len(all_the_lines))
        plaintext = all_the_lines[line_to_read - 1]

    with open('./modelsim/tv/plaintext_w.txt', 'w') as file:
        file.write(plaintext)

if __name__ == '__main__':
    main()
