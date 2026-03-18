# rblxGame Project Documentation

## Overview
This README provides comprehensive documentation for the `rblxGame` project. It outlines the project structure, systems involved, and instructions for setting up the project.

## Project Structure

```
/rblxGame
├── /src          # Source code for the game
│   ├── /game     # Game logic and mechanics
│   ├── /assets   # Game assets (images, sounds, etc.)
│   └��─ /ui       # User interface components
├── /tests        # Unit and integration tests
├── README.md     # Project documentation
└── .gitignore    # Files to ignore in git
```

## Systems Overview
- **Game Logic:**
  - Contains all the mechanics that drive the gameplay, including character control, enemy AI, and game rules.
- **Asset Management:**
  - Handles loading and managing game assets, ensuring they are optimized for performance.
- **User Interface:**
  - Manages UI components such as menus, buttons, and HUD elements to improve user interaction.

## Setup Instructions
To set up the `rblxGame` project, follow these steps:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Andrei-TC/rblxGame.git
   cd rblxGame
   ```

2. **Install dependencies:**
   - Make sure you have Roblox Studio installed.
   - Run the setup script to install all necessary dependencies. You can find the script in the `/src` folder.
   ```bash
   ./setup.sh
   ```

3. **Run the game:**
   - Open Roblox Studio and load the main game file located in `/src/game/main.rbxl`.

4. **Test the game:**
   - Execute the tests located in the `/tests` folder to ensure everything is working correctly.
   ```bash
   ./test.sh
   ```

## Contributing
If you would like to contribute to this project, please create a new branch for your feature or fix, and submit a pull request.
