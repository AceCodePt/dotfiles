#!/bin/zsh

PIPE_A_IN=/tmp/piper_a_in
PIPE_B_IN=/tmp/piper_b_in
ACTIVE_FILE=/tmp/piper_active_id

# 1. READ STATE & TOGGLE
# If file missing or contains A, we switch to B. Else A.
CURRENT=$(cat $ACTIVE_FILE 2>/dev/null)
if [[ "$CURRENT" == "A" ]]; then
    NEXT="B"
    TARGET_PIPE=$PIPE_B_IN
else
    NEXT="A"
    TARGET_PIPE=$PIPE_A_IN
fi

# 2. UPDATE STATE
echo "$NEXT" > $ACTIVE_FILE

# 3. KILL AUDIO (THE SWITCH)
pkill -x aplay 2>/dev/null

# 4. SEND TEXT (WITH ACCESSIBILITY REPLACEMENTS)
# Capture input from either arguments or stdin
if [ $# -gt 0 ]; then
    RAW_INPUT="$*"
else
    read -r RAW_INPUT
fi

# Use sed to replace common punctuation with words.
# We add spaces around the words to ensure the TTS doesn't clump them.
PROCESSED_TEXT=$(echo "$RAW_INPUT" | sed \
    -e 's/\./ period /g' \
    -e 's/,/ comma /g' \
    -e 's/!/ exclamation mark /g' \
    -e 's/?/ question mark /g' \
    -e 's/:/ colon /g' \
    -e 's/;/ semicolon /g' \
    -e 's/-/ dash /g' \
    -e 's/\"/ quote /g' \
    -e 's/(/ open parenthesis /g' \
    -e 's/)/ close parenthesis /g')

# Send the processed text to the idle instance
{
    echo ". $PROCESSED_TEXT"
    echo "" 
} > "$TARGET_PIPE"
