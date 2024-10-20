# Useful Scripts

This repository contains a collection of useful scripts for automation and common tasks. The scripts are written in **Python**, **Bash**.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Scripts description](./scripts.md)
3. [Python Environment Setup](#python-environment-setup)
4. [How to Run Python Scripts](#how-to-run-python-scripts)
6. [Contributing](#contributing)

---

## Getting Started

To get started with this project, you'll need to clone the repository and set up your environment for running the scripts. This guide will walk you through setting up the **Python** environment using **Poetry**.

If you want to contribue to this project, check the [Python Environment Setup](#python-environment-setup) section.

if you just want to run the scripts from your local client just run the following commands:

**Bash scripts**
`bash -c "$(curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/<script_path>.sh)"`

**Python scripts**
`curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/<script_path>.py | python3`
NOTE: Check the python package requirements for each script, or use `poetry` to install all packages

### Prerequisites

Before proceeding, make sure you have the following installed on your system:

- Python 3.9+ (verify with `python --version`)
- Poetry (install instructions below)

### Installing Poetry

If you don't have Poetry installed, you can install it via the following command:

```bash
curl -sSL https://install.python-poetry.org | python3 -
```

For more detailed installation options, refer to [Poetry's official documentation](https://python-poetry.org/docs/#installation).

---

## Python Environment Setup

Once you have Poetry installed, follow these steps to set up the Python environment:

1. **Clone the repository**:

    ```bash
    git clone https://github.com/your-username/useful-scripts.git
    cd useful-scripts/python
    ```

2. **Install project dependencies**:
    Inside the `python` directory, run the following command:

    ```bash
    poetry install
    ```

   This will create a virtual environment and install all the dependencies listed in the `pyproject.toml` file.

3. **Activate the virtual environment** (optional):

    ```bash
    poetry shell
    ```

   This will activate the environment for your current shell session.

---

## How to Run Python Scripts

After the environment is set up, you can run any Python script in the `python` folder.

Example:

```bash
python hello.py
```

If you're inside a Poetry shell (`poetry shell`), the environment is already activated. If not, Poetry will automatically handle the environment for you.

---

## How to Run Bash/Shell Scripts

To run **Bash** or **Sh** scripts, simply navigate to the appropriate directory (`bash` or `sh`) and run the script using the respective shell.

Example (running a Bash script):

```bash
bash script-name.sh
```

Example (running a Shell script):

```bash
sh script-name.sh
```

---

## Contributing

Contributions are welcome! Please follow these steps to contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a Pull Request.

### Key sections

- **Project Structure**: Shows how the project is organized, with directories for Python, Bash, and Shell scripts.
- **Getting Started**: Provides instructions for cloning the repo and setting up the environment using **Poetry**.
- **Python Environment Setup**: Step-by-step guide to install dependencies and run Python scripts.
- **Bash/Shell Script Instructions**: Basic instructions for running Bash/Shell scripts.
- **Contributing and License**: Standard sections for open source contributions.

---

Let me know if you'd like any further customization or additions to the README!

**Suggestions**:  
**a.** Add more advanced examples for Python scripts or Bash scripts to the repository.  
**b.** Configure CI/CD pipelines for running Python scripts (e.g., GitHub Actions).
