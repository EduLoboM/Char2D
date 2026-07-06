# How to Contribute & Run

Thank you for your interest in contributing to **Char2D**! Whether you are writing engine code, designing mechanics, or improving our documentation, your help is highly appreciated.

---

## Rules of Contribution

To ensure a smooth collaboration, please follow these guidelines when contributing to the project.

### Code Standards for Beef Lang
- **Naming Conventions:** Use **snake_case** for Type, Method, Property, and Variable names.
- **Safety First:** Make proper use of Beef's memory safety features. Minimize usage of **unsafe** blocks unless absolutely necessary for performance.
- **Documentation:** Always document public APIs and document complex logic blocks.

### Asset & Resource Integration
- **Pixel Art:** Align all visual assets to a **64x64 pixel grid**. Export files in **.png** format with transparent backgrounds.
- **Audio & Soundtracks:** Background music and sound effects must be compressed as **.ogg** files. Ensure loop metadata tags are included for BGM.
- **Asset Registry:** When adding new asset files, make sure to update the **[Asset Registry](./artifacts/index.md)** document.

### Git Workflow & Pull Requests
- **Branch Naming:** Prefix branches with their type, for example:
  - `Feature/Your-Feature-Name`
  - `Bugfix/Issue-Description`
  - `Docs/Update-Contribution-Guidelines`
- **Commit Messages:** Keep commit messages concise, clear, and descriptive (e.g., `Feat(Engine): Implement event system parser`).
- **PR Submissions:** Open a Pull Request targeting the `main` branch. Provide a summary of the changes and reference any related open issues and workflows with screenshots or videos.

---

## Running the Project Locally

Here is how you can set up and run the different components of the Char2D workspace.

### Running the Documentation Site
The documentation site is built using **[Docusaurus](https://docusaurus.io/)**. Follow these steps to run it locally:

1. **Navigate to the docs directory:**
   ```bash
   cd docs
   ```
2. **Install dependencies:**
   ```bash
   npm install
   ```
3. **Start the development server:**
   ```bash
   npm start
   ```
4. **Access the site:**
   Open your browser and navigate to **[http://localhost:3000/Char2D/](http://localhost:3000/Char2D/)**. Any changes made to the Markdown files will hot-reload automatically.

### Running the Game Engine using Beef IDE
To run or build the Char2D game engine/demo:
1. Ensure you have the **[Beef IDE](https://www.beeflang.org/)** installed on your machine.
2. Open the Beef IDE and load the workspace file (**Workspace.beefproj** or folder) from the repository root.
3. Select your target configuration (e.g., **Debug** or **Release**) and press **F5** to compile and run the engine.
