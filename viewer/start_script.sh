echo $$ > start_pid.txt
while true; do
./lepton3 &
PID=$!
sleep 60
kill $PID
sleep 1
done
