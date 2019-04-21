clear ;
pause(2);
atPath = getenv('FLIR_Atlas_MATLAB');
atLive = strcat(atPath, 'Flir.Atlas.Live.dll');
asmInfo = NET.addAssembly(atLive);

test = Flir.Atlas.Live.Discovery.Discovery;
% search for cameras for 2 seconds
disc = test.Start(3);

camera = 1;
%It is FlirFileFormat init a ThermalCamera
ImStream = Flir.Atlas.Live.Device.ThermalCamera(true);
ImStream.AutoReconnect = false;
ImStream.Connect(disc.Item(camera));
pause(2);

if ~ImStream.IsConnected
    ImStream.Disconnect();
    ImStream.Dispose();
    pause(2);

    ImStream = Flir.Atlas.Live.Device.ThermalCamera(true);
    ImStream.AutoReconnect = true;
    ImStream.Connect(disc.Item(camera));
    pause(2);

    if ~ImStream.IsConnected
        fprintf('connection %s', mat2str(ImStream.IsConnected));

        ImStream.Disconnect();
        ImStream.Dispose();
        pause(1);

        return
    end
end
editString_start = datestr(now, 'mm_dd_yy_HH_MM_AM');
editString_start = strrep(editString_start, ' ', '');
editString_start = sprintf('%s_%d', editString_start, camera);

fprintf('DIR CREATED %s', editString_start);

if exist(editString_start, 'dir')
    rmdir(editString_start, 's');
end

mkdir(sprintf('%s', editString_start));

n_frames = 60000;

connection_timing = 0;
while true
       if connection_timing >= 100
           break
       end
    while ImStream.IsConnected
        connection_timing = 0;
        editString = datestr(now, 'mm_dd_yy_HH_MM_AM');
        editString = strrep(editString, ' ', '');
        mkdir(sprintf('%s/%s', editString_start, editString));
        mkdir(sprintf('%s/%s/%s', editString_start, editString, 'JPEG'));
        mkdir(sprintf('%s/%s/%s', editString_start, editString, 'Stats'));

        fid = fopen(sprintf('%s/%s/Stats/thermal.txt', editString_start, editString),'at');

        i = 0;
        while i < n_frames && ImStream.IsConnected
            pause(0.1);
            fprintf(fid, '%s\t%s\t%d\t%d\t%d\n', editString, char(ImStream.ThermalImage.DateTime.ToString()), i, ImStream.ThermalImage.Statistics.Min.Value, ImStream.ThermalImage.Statistics.Max.Value);
            fid_temp = fopen('./images/temp.txt','w');
            fprintf(fid_temp, '%d', ImStream.ThermalImage.Statistics.Max.Value + 470);
            fclose(fid_temp);

            img = ImStream.ThermalImage.ImageProcessing.GetPixelsArray;
            img = double(img);
            img=img - min(img(:)); % shift data such that the smallest element of A is 0
            img=img / max(img(:)); % normalize the shifted data to 1
            imwrite(img,  sprintf('%s/%s/JPEG/%d.jpg', editString_start, editString, i));
            imwrite(img,  './images/2.jpg');
            i = i + 1;
        end

        fclose(fid);
    end
    connection_timing = connection_timing + 2;
    pause(2)
end

ImStream.Disconnect();
ImStream.Dispose();