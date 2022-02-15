import os
import re
from .contexts import Context, Contexts
from .logger import Logger
from .stages import Stages
from dsocli.file_utils import *
from dsocli.exceptions import DSOException
from dsocli.dict_utils import *
from dsocli.local_utils import *
from dsocli.appconfig import AppConfig



def add_shell_parameter(key, value, store_name, path_prefix=''):
    add_local_parameter(key=key, value='N/A', store_name=store_name, path_prefix=path_prefix)

def delete_shell_parameter(path, key):
    delete_local_parameter(path=path, key=key)


