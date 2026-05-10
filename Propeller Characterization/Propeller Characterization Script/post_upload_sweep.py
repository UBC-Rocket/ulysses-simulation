from SCons.Script import Import
import subprocess
import sys
import os

Import("env")

env.Execute("$PYTHONEXE -m pip install pyserial")

def after_upload(source, target, env):
    script_path = os.path.join(env.subst("$PROJECT_DIR"), "sweep_logger.py")
    subprocess.run([sys.executable, script_path])

env.AddPostAction("upload", after_upload)