echo $$ > start_pid.txt
while true; do
./lepton3 &
PID=$!
sleep 150
kill $PID
done
