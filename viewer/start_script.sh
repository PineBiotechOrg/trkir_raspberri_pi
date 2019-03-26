echo $$ > start_pid.txt
while true; do
./lepton3 &
PID=$!
sleep 600
kill $PID
done
