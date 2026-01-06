#!/bin/zsh

# --- CONFIGURATION ---
PIPE_A_IN=/tmp/piper_a_in
PIPE_A_OUT=/tmp/piper_a_out
PIPE_B_IN=/tmp/piper_b_in
PIPE_B_OUT=/tmp/piper_b_out

ACTIVE_FILE=/tmp/piper_active_id
PIDFILE=/tmp/piper_server.pid
MODEL="/usr/share/piper-voices/en/en_US/lessac/low/en_US-lessac-low.onnx"

cleanup() {
    echo "\nShutting down Piper Cluster..."
    pkill -P $$ 
    kill $(jobs -p) 2>/dev/null
    rm -f $PIPE_A_IN $PIPE_A_OUT $PIPE_B_IN $PIPE_B_OUT $ACTIVE_FILE $PIDFILE
    exit 0
}

trap cleanup INT TERM EXIT

echo $$ > $PIDFILE
rm -f $PIPE_A_IN $PIPE_A_OUT $PIPE_B_IN $PIPE_B_OUT

# Create Pipes
mkfifo $PIPE_A_IN $PIPE_A_OUT
mkfifo $PIPE_B_IN $PIPE_B_OUT

# Initialize Active State to A
echo "A" > $ACTIVE_FILE

echo "Starting Piper Instances..."

# --- START PIPER A ---
sleep infinity > $PIPE_A_IN &  # Dummy Writer
exec 3<> $PIPE_A_OUT           # Keep Output Open
piper-tts --model "$MODEL" --length_scale 0.75 --output-raw < $PIPE_A_IN >&3 &

# --- START PIPER B ---
sleep infinity > $PIPE_B_IN &  # Dummy Writer
exec 4<> $PIPE_B_OUT           # Keep Output Open
piper-tts --model "$MODEL" --length_scale 0.75 --output-raw < $PIPE_B_IN >&4 &

echo "Double-Barrel Piper Ready."

# --- AUDIO HANDLER FUNCTION ---
# This runs in parallel for both A and B
# --- AUDIO HANDLER FUNCTION ---
handle_audio() {
    local ID=$1
    local PIPE=$2
    
    while true; do
        # 1. Read the global Active ID
        CURRENT_ACTIVE=$(cat $ACTIVE_FILE 2>/dev/null)
        
        # 2. Decide: Play or Drain?
        if [[ "$CURRENT_ACTIVE" == "$ID" ]]; then
            # --- ACTIVE MODE ---
            # Play to speakers. 
            # This blocks until audio finishes OR speak.sh kills aplay.
            aplay -r 28000 -f S16_LE -t raw -D default < $PIPE 2>/dev/null
        else
            # --- DRAIN MODE ---
            # We are the "inactive" channel. 
            # We must suck data out of the pipe so Piper doesn't clog up, 
            # BUT we must stop frequently to check if we became active.
            
            # 'timeout 0.1 cat' reads everything available for 0.1 seconds, then quits.
            # This ensures we effectively flush the pipe but never get stuck for long.
            timeout 0.001 cat $PIPE > /dev/null 2>&1
        fi
    done
}

# Start the two handlers in background
handle_audio "A" $PIPE_A_OUT &
handle_audio "B" $PIPE_B_OUT &

# Keep script alive
wait
