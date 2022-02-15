import os
from dsocli.logger import Logger
from dsocli.appconfig import AppConfig
from dsocli.providers import Providers
from dsocli.parameters import ParameterProvider
from dsocli.stages import Stages
from dsocli.constants import *
from dsocli.exceptions import DSOException
from dsocli.contexts import Contexts
from dsocli.shell_utils import *
from dsocli.settings import *


__default_spec = {
    'path': os.path.join(AppConfig.config_dir, 'parameters'),
    'store': 'shell.json',
}


def get_default_spec():
    return __default_spec.copy()



class ShellParameterProvider(ParameterProvider):

    def __init__(self):
        super().__init__('parameter/shell/v1')

    @property
    def root_path(self):
        return AppConfig.parameter_spec('path')


    def get_path_prefix(self):
        return self.root_path

    @property
    def namespace(self):
        return AppConfig.parameter_spec('namespace')


    @property
    def store_name(self):
        return AppConfig.parameter_spec('store')


    def add(self, key, value):
        Logger.debug(f"Adding shell parameter '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        response = add_shell_parameter(key=key, value=value, store_name=self.store_name, path_prefix=self.get_path_prefix())
        return response


    def list(self, uninherited=False, filter=None):
        Logger.debug(f"Listing shell parameters: namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        parameters = load_context_shell_parameters(store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=uninherited, filter=filter)
        result = {'Parameters': []}
        for key, details in parameters.items():
            item = {
                'Key': key,
            }
            item.update(details)
            result['Parameters'].append(item)

        return result


    def get(self, key, revision=None, uninherited=False, editable=False):
        if revision:
            Logger.warn(f"Parameter provider 'shell/v1' does not support versioning.")
        Logger.debug(f"Getting shell parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        found = locate_shell_parameter_in_context_hierachy(key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=uninherited, raw=editable)
        if not found:
            if uninherited:
                raise DSOException(f"Parameter '{key}' not found in the given context: namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
            else:
                raise DSOException(f"Parameter '{key}' not found nor inherited in the given context: namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        if len(found) > 1:
            raise DSOException(f"Mutiple parameters found with the same key '{key}' in the given context.")
        result = {
                'Key': key, 
            }
        result.update(found[key])
        return result


    def history(self, key):
        Logger.warn(f"Parameter provider 'shell/v1' does not support versioning.")

        Logger.debug(f"Getting shell parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        found = locate_shell_parameter_in_context_hierachy(key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=False)
        if not found:
            raise DSOException(f"Parameter '{key}' not found nor inherited in the given context: stage={Stages.shorten(AppConfig.short_stage)}")
        result = { "Revisions":
            [{
                'RevisionId': '0',
                'Date': get_file_modified_date(found[key]['Path']),
            }]
        }
        result['Revisions'][0].update(found[key])
        return result



    def delete(self, key):
        Logger.debug(f"Locating parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        ### only parameters owned by the config can be deleted, hence uninherited=True
        found = locate_shell_parameter_in_context_hierachy(key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=True)
        if not found:
            raise DSOException(f"Parameter '{key}' not found in the given context: namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        Logger.info(f"Deleting parameter: path={found[key]['Path']}")
        delete_shell_parameter(found[key]['Path'], key=key)
        result = {
                'Key': key,
                'Stage': AppConfig.short_stage,
                'Scope': found[key]['Scope'], 
                'Origin': found[key]['Origin'], 
                'Path': found[key]['Path'],
            }
        return result



def register():
    Providers.register(ShellParameterProvider())
