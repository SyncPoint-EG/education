import re

with open('lib/features/map/data/datasources/levels_data.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# We will use regex to find AssessmentActivityEntity blocks.
# The block starts with "AssessmentActivityEntity(" and ends with "),"
# Since there could be nested parenthesis, we have to be careful.
# But looking at the format, it's typically:
#       AssessmentActivityEntity(
#         prompt: '...',
#         type: AssessmentGameType.feeling,
#         ...
#       ),
# A non-greedy match should work if there are no nested `),` at the same indentation.
# Let's use a regex that matches the start, looks for AssessmentGameType.feeling inside, and ends with `),`
# We can also just iterate line by line, maintaining a buffer of the current block.

lines = content.split('\n')
new_lines = []
in_block = False
block_buffer = []
is_feeling_block = False

for line in lines:
    stripped = line.strip()
    if stripped.startswith('AssessmentActivityEntity('):
        in_block = True
        block_buffer = [line]
        is_feeling_block = False
    elif in_block:
        block_buffer.append(line)
        if 'type: AssessmentGameType.feeling' in line:
            is_feeling_block = True
        
        # Check if this line is the end of the block.
        # It usually ends with `      ),`
        if stripped == '),' and line.startswith('      )'):
            in_block = False
            if not is_feeling_block:
                new_lines.extend(block_buffer)
            else:
                # We skip adding the block_buffer
                pass
    else:
        new_lines.append(line)

with open('lib/features/map/data/datasources/levels_data.dart', 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines))
