##################################################################################
# Copyright 2020 u-blox AG, Thalwil, Switzerland
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##################################################################################

u-blox GSMMUX (multiplexer) utility

It can be used to create multiple virtual channels over a single serial interface by means of CMUX protocol (see 3GPP TS 27.010). Each virtual channel can then be used for specific purpose (e.g. for AT command or data).

Supported OS: Android, Linux

Build for Linux: 
    To build source, follow below steps:
        $ cd gsm0710muxd
        $ make
	
	The above command would generate the binary 'gsm0710muxd' which can be run on Linux as shown below to create multiple /dev/pts/* channels:
		$ ./gsm0710muxd <command-line arguments>
        

Build for Android:
	
	* MUST Follow Android RIL Multiplexer App Note (UBX-15027820) for proper configuration settings of GSMMUX for Android.
	
	u-blox RIL (Radio Interface Layer) uses this utility to create multiple virtual channels (e.g. /dev/pts/*) over single serial interface (e.g. /dev/ttyUSB0) to use them as AT or data channels as desired. 
	
	In order to configure RIL to use this GSMMUX utility, follow below steps:
    1- Copy the multiplexer source code folder "gsm0710muxd" to the "ANDROID_SOURCE/hardware/" folder:
		$ cp –pvRf mux_sc_<version>/hardware/gsm0710muxd <android_root>/hardware
    2- Next add the following line to the "build/target/product/core_ublox.mk" file:
        PRODUCT_PACKAGES += gsm0710muxd
    3- Add the following permissions to the ueventd.rc/ueventd.<device_name>.rc file inside <ANDROID_SOURCE>/device/<manufacturer>/<device_name> folder:
		# Permissions for virtual devices created by MUX 
		/dev/pts*	    0660	radio	radio
		# Permissions for the USB serial device
		/dev/ttyUSB*	0660	radio	radio
	4- Add all required SEPolicy for MUX daemon as instructed in Android RIL SELinux policy application note (UBX-18031562) to give the MUX daemons access to the required data, system and device files. 

    5- In repository.txt, set "Mode" to "pts" in 'Group TTY' tag:
		Group TTY
			Mode                               pts       
	6- In repository.txt, set "SerialPort", "MUXBaudRate" and other configurable settings in 'Group MUXPortSettings' tag.
        Group MUXPortSettings
			SerialPort                         /dev/ttyUSB0
			MUXFlowControl                     1             // 1:Enabled, 0: Disabled
			MUXBaudRate                        115200
			MUXNumOfVirtualPorts               3             // Max 5 supported
			MUXFrameSize                       1509          // Any value from 7 - 1509
			MUXExitPowerOff                    0             // 0:Disabled,1:Enabled Send CPWROFF During MUX exit
			MUXVerbosity                       5             // 0 (Silent) - 7 (Debug), 8 (Wireshark Debug)
			
	7- Uncomment [GSMMUX] section in init.ublox.rc file to enable 'gsmmuxd' and 'mux_stop' services:
		# For Android 9.x and later versions
		service gsmmuxd /vendor/bin/gsm0710muxd -s /dev/ttyUSB0 -n3 –v6 -mbasic
			class main
			user radio
			group radio cache inet misc
			disabled
			oneshot

		# Use this service for stopping gsmmuxd
		service mux_stop /vendor/bin/stop_muxd 15
			class main
			disabled
			oneshot

	8- Build AOSP and flash images. On boot, u-blox RIL will automatically start 'gsm0710muxd' service and configure itself to use newly created virtual channels for AT/data traffic.
	
	Alternatively, in order to use GSMMUX utility without RIL as standalone executable, ignore above steps# 5,6,7 and use below command to directly run 'gsm0710muxd' executable:
		$ /vendor/bin/gsm0710muxd -s /dev/ttyUSB0 -n 3 –v 6
		 
<command-line arguments>:
	The 'gsm0710muxd' executable can be run with the following command-line arguments:
	
	Usage: ./gsm0710muxd [options]
	Options:
		-c: Send CPWROFF during MUX close. 0 (Disabled) - 1 (Enabled) [no]
		-F: Hardware Flow Control Setting. 0 (Disabled) - 1 (Enabled) [0]
		-d: Fork, get a daemon [yes]
		-v: Set verbose logging level. 0 (Silent) - 7 (Debug), 8 (Wireshark Debug) [6]
		-C: Use this parameter to disable MUX exit on CTRL-C. CTRL-C exit is enabled by default. [ENABLED]
		-s <serial port name>: Serial port device to connect to [/dev/ttyUSB0]
		-t <timeout>: reset modem after this number of seconds of silence [0]
		-P <pin-code>: PIN code to unlock SIM [-1]
		-p <number>: use ping and reset modem after this number of unanswered pings [0]
		-b <baudrate>: mode baudrate [115200]
		-m <modem>: Mode (basic, advanced) [basic]
		-f <framsize>: Frame size [1509]
		-n <number of ports>: Number of virtual ports to create, must be in range 1-31 [2]
		-N Maximum number of re-transmissions. Allowed range is 0-5. Default [3]
		-A Acknowledgement timer in units of ten milliseconds. The allowed range is 1-255. Default [253]
		-T Response timer for the multiplexer control channel in units of ten milliseconds. The allowed range is 2-255. Default [254]
		-W Wake up response timer. The allowed range is 0-255. Default [0]
		-L <output log to file>: Output log to specified file. [no]
		-h: Show this help message and show current settings.

