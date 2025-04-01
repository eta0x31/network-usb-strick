#!/bin/bash

# # TODO: get and save the current time
# umount /mnt/secondary-usb-mount
# dd if=/primary-usb-container.bin of=/secondary-usb-container.bin bs=4M status=progress
# mount -a

# # TODO: rsync the changes over, but only delete files in /mnt/network-share/ that are older then the saved started time for the dd command.
# # The idea is the dd command run some time and the data is therefore old and maybe a new file was uploaded to the /mnt/network-share/ folder, 
# # This one should not be deleted!
# # rsync -av --exclude='.*' /mnt/primary-usb-mount /mnt/network-share/

#!/bin/bash


start_time="2025-03-28 23:39:00"

echo "start_time: $start_time"

for file in /mnt/network-share/*; do
    
        birth_date_raw=$(stat --format="%w" "$file")
        birth_date=$(date -d "$birth_date_raw" "+%Y-%m-%d %H:%M:%S")

        echo "b: $birth_date, s: $start_time, f: $file"

        if [[ $birth_date > $start_time ]] ; then
            continue
        fi

        echo "Delete: $file"
done

# find /mnt/network-share/ -type f -exec bash -c '
#     for file; do

#         birth=$(stat --format="%w" "$file")
        
#         echo "b: $birth, s: $start_time, f: $file"

#         if [[ "$birth" < "$start_time" && "$birth" != "" ]]; then
#             echo "Delete: $file, B: $birth"
#             #rm -v "$file"
#         fi
#     done
# ' bash {} +