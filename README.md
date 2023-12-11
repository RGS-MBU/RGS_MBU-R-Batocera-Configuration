# RGS_MBU-R-Batocera-Configuration

This Repo contains all the configuration files you need to update your RGS-MBU_R from v37 to v38.

This is part 1 to get the custom systems like famicom, sfc, actionmax etc. For Batocera v38 if you manually update. You also need the roms and bios files, those are not in this github repo ofc.

Guide:

1. Update Batocera via MAIN MENU > UPDATES & DOWNLOADS > UPDATE TYPE > “Stable” and Start Update.
2. After the update reboot your system, all the custom systems are gone now eg: famicom, sfc, pspmini etc..
3. Download this Repo:


![image](https://github.com/RGS-MBU/RGS_MBU-R-Batocera-Configuration/assets/134323670/a4454792-7d8f-4486-b3bc-2e680435a02f)

4. Save to Desktop and upzip.
5. Open WinSCP to your Batocera on the network (https://winscp.net/eng/index.php)
* if your network does not support DNS lookup the IP adres on your router's DHCP table or use a IP scanner. aka "advanced ip scanner" use to IP adres to connect with WinSCP.


![image](https://github.com/RGS-MBU/RGS_MBU-R-Batocera-Configuration/assets/134323670/73bf52c6-e9b8-4f31-9e88-9cb5d8cdd428)

6. go to the root directory and drag and drop the files you unziped. Drag and drop the folders: "usr" and "userdata" to the root.

![image](https://github.com/RGS-MBU/RGS_MBU-R-Batocera-Configuration/assets/134323670/228579a4-85c2-4863-8331-dbe65b44c5f2)

7. If asked to overwrite check "yes to all"

8. When its done, Connect to the terminal and send this command:

batocera-save-overlay

![image](https://github.com/RGS-MBU/RGS_MBU-R-Batocera-Configuration/assets/134323670/deb58a93-e81b-4697-b07a-4b58762f57b0)

Reboot Batocera!
