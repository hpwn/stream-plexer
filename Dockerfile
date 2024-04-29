FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openvpn \
    wget \
    curl \
    firefox \
    pulseaudio \
    xvfb \
    python3 \
    python3-pip

# Install Selenium and pyvirtualdisplay for browser automation
RUN pip3 install selenium pyvirtualdisplay

# Add the PIA VPN configuration files and credentials
ADD pia /etc/openvpn/pia
ADD login.conf /etc/openvpn/pia/

# Add the Python script
ADD run_browser.py /usr/local/bin/run_browser.py

# Set up the virtual display and pulseaudio server
RUN echo "load-module module-null-sink sink_name=DummyOutput sink_properties=device.description='Dummy_Output'" >> /etc/pulse/default.pa
RUN echo "load-module module-native-protocol-unix" >> /etc/pulse/default.pa

# Set environment variables for Selenium
ENV DISPLAY=:99

# Set the entrypoint
ENTRYPOINT ["sh", "-c", "pulseaudio --start && xvfb-run --server-args='-screen 0 1024x768x24' python3 /usr/local/bin/run_browser.py"]
