FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openvpn \
    wget \
    curl \
    pulseaudio \
    xvfb \
    python3 \
    python3-pip \
    python3-venv \
    libgtk-3-0 \
    libdbus-glib-1-2 \
    libxt6

# Set up virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install Selenium and pyvirtualdisplay for browser automation
RUN pip install selenium pyvirtualdisplay

# Add the PIA VPN configuration files and credentials
ADD pia /etc/openvpn/pia

# Set up the virtual display and pulseaudio server
RUN echo "load-module module-null-sink sink_name=DummyOutput sink_properties=device.description='Dummy_Output'" >> /etc/pulse/default.pa
RUN echo "load-module module-native-protocol-unix" >> /etc/pulse/default.pa

# Download and install Firefox
RUN wget -q -O - "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US" | tar xj -C /opt
ENV PATH="/opt/firefox:$PATH"

# Install geckodriver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.34.0/geckodriver-v0.34.0-linux64.tar.gz \
    && tar -xzf geckodriver-v0.34.0-linux64.tar.gz -C /usr/local/bin \
    && rm geckodriver-v0.34.0-linux64.tar.gz \
    && chmod +x /usr/local/bin/geckodriver

# Ensure Firefox and geckodriver are properly installed and findable
RUN firefox --version

# Add non-root user for running the application
RUN useradd -m myuser -s /bin/bash
USER myuser

# Set environment variables for Selenium
ENV DISPLAY=:99

# Add the Python script
ADD run_browser.py /usr/local/bin/run_browser.py

# Set the entrypoint
ENTRYPOINT ["sh", "-c", "pulseaudio --start && xvfb-run --server-args='-screen 0 1024x768x24' python3 /usr/local/bin/run_browser.py"]
