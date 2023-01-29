Set-Location "$PSScriptRoot/../plandovania"

# Remove old releases (create_release script gets wonky if the same exact archive already exists)
Remove-Item -Force "./dist/*.7z"

# Ensure virtual environment exists, and activate it
. "$PSScriptRoot/Prepare-VirtualEnv.ps1"
. ./venv/Scripts/Activate.ps1

# Switch to the non-editable local version of open-dread-rando
python -m pip install "../open-dread-rando"

# Run the "create_release" script
python tools/create_release.py

# Switch back to the editable version of ODR
python -m pip install -e "../open-dread-rando"