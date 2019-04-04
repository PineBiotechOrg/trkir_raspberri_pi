echo $$ > start_pid.txt
while true; do
./lepton3 &
PID=$!
sleep 200
kill $PID
done
