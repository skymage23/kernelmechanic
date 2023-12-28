# kernelmechanic
A Zephyr-based bootloader for the Steam Deck and Steam Deck OLED with network-boot-over-wifi and hypervisor functionality.

# Set up the build environment.
##Requirements:
* A Linux-based OS
    * The following may work on macOS, but I cannot test that at this time. If you would like to try it and report back, please do. Just remember to download the macOS version of the Zephyr SDK instead of the Linux version.
* Python3
* Pip3

##Instructions
1. Install "venv":
    ```
   pip3 install venv
   ```
2. run
   ```
   mkdir ~/steamdeckhacks
   python3 -m venv ~/steamdeckhacks
   cd ~/steamdeckhacks
   source .venv/bin/activate
   ```
3. You are now inside the "venv" environment. Here, we install the Zephyr repository managment tool, West.
   ```
   pip install west
   ```
4. Initialize the local checkout and then pull in all dependencies:
   ```
   west init -m https://github.com/skymage23/kernelmechanic.git
   west update
   ```
5. Your cloning of the repository is complete, but you must still install and set up the Zephyr SDK.
   ```
   wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.4/zephyr-sdk-0.16.4_linux-x86_64.tar.xz
   tar -xvf zephyr-sdk-0.16.4_linux-x86_64.tar.xz
   cd zephyr-sdk-0.16.4
   setup.sh
   ```
   According to [The Zephyr Project's documentation](https://docs.zephyrproject.org/latest/develop/getting_started/index.html), you only have to run the ```setup.sh``` script once and then again should you move the SDK directory elsewhere.
