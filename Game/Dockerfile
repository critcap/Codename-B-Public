FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y wget unzip fontconfig

# Download and install Godot Engine 4.3
ADD https://github.com/godotengine/godot-builds/releases/download/4.3-dev5/Godot_v4.3-dev5_linux.x86_64.zip /tmp/godot.zip
RUN unzip /tmp/godot.zip -d /tmp/ && \
    mv /tmp/Godot* /usr/local/bin/godot && \
    chmod +x /usr/local/bin/godot && \
    rm /tmp/godot.zip

# Download and install Godot export templates
ADD https://github.com/godotengine/godot-builds/releases/download/4.3-dev5/Godot_v4.3-dev5_export_templates.tpz /root/.local/share/godot/templates/4.3.dev5/
RUN mkdir -p /root/.local/share/godot/templates/4.3.dev5/ && \
    unzip /root/.local/share/godot/templates/4.3.dev5/Godot_v4.3-dev5_export_templates.tpz -d /root/.local/share/godot/templates/4.3.dev5/ && \
    rm /root/.local/share/godot/templates/4.3.dev5/Godot_v4.3-dev5_export_templates.tpz && \
    mkdir -p /root/.local/share/godot/export_templates/4.3.dev5/ && \
    mv /root/.local/share/godot/templates/4.3.dev5/templates/* /root/.local/share/godot/export_templates/4.3.dev5/

# Copy your game project files into the container
COPY . /home/godot/project

# Set the working directory to your project files
WORKDIR /home/godot/project

# Run the export command for your desired platform (e.g., HTML5)
#RUN godot --headless --export-debug Main --quit

CMD ["tail", "-f", "/dev/null"]

