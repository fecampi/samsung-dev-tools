
# Samsung Dev Tools

This project makes it easy to connect to Samsung TVs, install TPK files (application packages), and capture logs using **sdb** (Samsung Debug Bridge). It provides an interactive command-line interface to perform these tasks in a simple and organized way.

## Features

- **Connect to TV**: Connects to a Samsung TV via IP, allowing interactions such as TPK installation and log capture.
- **Save TVs**: Allows you to save information about connected TVs to make reconnection easier in future sessions.
- **Install TPK**: Select and install TPK application packages directly on the TV. You can place your TPK files in the `devices/samsung/tpks/` folder and the script will automatically find them.
- **Capture Logs**: Capture and save logs to files, filtering by different categories (general logs, Player logs, Application logs, and specific logs for Tizen and Globo Play).
- **Reuse TVs**: Save and reuse previously connected TVs without needing to enter the IP again.

## Execution Permissions
```sh
chmod +x connect_samsung_tv.sh
```

## Connect to TV
```sh
./connect_samsung_tv.sh
```

## Requirements

- This project uses **sdb dev tools** as its base. You must accept the sdb license terms and move the binary to the `devices/samsung/sdb` folder.
- Samsung TV with developer mode enabled and the IP correctly configured.
- Access to the local network where the TVs are connected.
