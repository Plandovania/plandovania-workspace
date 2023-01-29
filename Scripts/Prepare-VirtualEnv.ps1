param(
	[switch] $Force
)

Set-Location "$PSScriptRoot/../plandovania"

if ((Test-Path "venv" -PathType Container)) {
	if ($Force) {
		Write-Output "Removing old virtual environment..."
		Remove-Item -Force -Recurse "venv"
	} else {
		Write-Information "Virtual environment already exists. Skipping."
		exit
	}
}

# Set up the virtual environment (the prepare_virtual_env.bat script doesn't work when the repo is a submodule)
py -3.11 tools/test_py_version.py

if ($LASTEXITCODE -ne 0) {
	Pause
	exit
}

py -3.11 -m venv venv

if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

if (-not (Test-Path "venv" -PathType Container)) {
	Write-Error "Could not set up the virtual environment"
	exit
}

# Activate the new virtual environment
. ./venv/Scripts/Activate.ps1

# Test the Python version
python -c "import sys; assert sys.version_info[0:2] == (3, 11), 'Python 3.11 required'"
python -c "import sys; assert sys.maxsize > 2**32, '64-bit Python required'"

if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

# Install requirements inside the venv
python -m pip install --upgrade -r "requirements-setuptools.txt" -r "requirements.txt"
python -m pip install pyqt-distutils -e ".[gui]" -c "requirements.txt"

# Switch installed version of "open-dread-rando" to the local version (editable)
python -m pip install -e "../open-dread-rando"

# Run the "build_py" command
python "setup.py" build_py

Write-Output "Setup finished successfully."