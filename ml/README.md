# ML scripts — environment

python3 -m venv venv
source venv/bin/activate      # macOS/Linux
venv\Scripts\Activate.ps1     # Windows PowerShell

pip install --upgrade pip
pip install -r requirements.txt   # add this file once S3.1 pins real dependencies
