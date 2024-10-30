#!/usr/bin/env python
# coding: utf-8

# In[1]:


import sys, re


# In[2]:


infile = sys.argv[1]
if len(sys.argv) > 2:
    outfile = sys.argv[2]
else:
    outfile = re.sub('.conllu', '_WordAdded.conllu', infile)
# infile = "../Gbaya/GYA_PRD_NARR_01_T16-C6.conllu"

with open(infile, "r") as f:
    lines = [line.rstrip() for line in f.readlines()]

sent_buffer = []
output = []
total_sent = 0
processed_sent = 0

for line in lines:
    if re.match(r'\d+\t', line):
        sent_buffer.append(line)

    elif re.match(r'\d+-\d+', line):
        sent_buffer.append(line)
    
    elif line.startswith('# phonetic_text = '):
        ori_text = line
        text = re.sub('/', '', ori_text)
        text = re.sub(r'\s+', ' ', text).rstrip()
        words = re.sub('# phonetic_text = ', '', text).split(' ')
        output.append(line)
        
    elif line.startswith('# sent_id'):
        sent_id = line
        output.append(line)
        
    elif line == '':
        total_sent += 1

        # First, add nWord2 with redone values
        # Start at 1
        # Each time the original nWord changes value, nWord2 increments
        nWord_id2 = 0
        nWord_id1_previous = 0
        for i in range(0, len(sent_buffer)):
            if re.match(r'\d+-\d+', sent_buffer[i]):
                continue
            try:
                nWord_id1_current = int(re.search(r'nWord=(\d+)', sent_buffer[i]).group(1))
                if nWord_id1_current != nWord_id1_previous:
                    nWord_id2 += 1
                sent_buffer[i] += '|nWord2=' + str(nWord_id2)
                nWord_id1_previous = nWord_id1_current
            except:
                print(sent_id)
                print('No nWord on this token: ', sent_buffer[i])                  

        
        # Sanity checks
        last_token = sent_buffer[-1]

        # Skip sentences which only contain 'inaudible'
        if len(sent_buffer) == 1 and re.search(r'\tinaudible\t', last_token): 
            output.append(last_token)
            sent_buffer = []
            continue  


        # Check if the nWord on the last token matches the number of words in # text 
        # if it doesn't, leave the sentence as is
        last_token_nWord = re.search(r'nWord2=(\d+)', last_token)    
        word_id = int(last_token_nWord.group(1))

        if word_id == len(words):
            processed_sent += 1
            for tok in sent_buffer:
                if re.match(r'\d+-\d+', tok):
                    continue
                    
                try:        
                    nWord = int(re.search(r'nWord2=(\d+)', tok).group(1))
                    Word = words[nWord - 1]
                    tok = tok + '|Word=' + Word
                except Exception:
                    print(sent_id + '\n' + 'No nWord: ', tok + '\n')
                output.append(re.sub(r'\|nWord2=\d+', '' , tok))  # rm nWord2 before printing
        else:
            print(sent_id + '\n' + '# phonetic_text: ' + ori_text + '\n'\
                  + 'last token nWord: ' + str(word_id) + '\n' \
                  + 'words: ' + ', '.join(words) )
            for s in sent_buffer:
                print(s)
            print()

            output.extend(sent_buffer)            

        output.append('')
        sent_buffer = []

    else:
        output.append(line)
        
    
print('Total sentences:', total_sent)
print('Processed sentences:', processed_sent)

with open(outfile, 'w') as f:
    for o in output:
        f.write(o + '\n')

