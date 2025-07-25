#!/bin/bash
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
