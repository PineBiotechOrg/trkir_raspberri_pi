import os

os.system("""matlab.exe -nosplash -nodesktop -r "cd D:/test_auto; run('D:/test_auto/auto_recording_2.m');exit;" """)
os.system("""matlab.exe -nosplash -nodesktop -r "cd D:/test_auto; run('D:/test_auto/auto_recording_1.m');exit;" """)
