import os
from dsocli.logger import Logger
from dsocli.appconfig import AppConfig
from dsocli.providers import Providers
from dsocli.parameters import ParameterProvider
from dsocli.stages import Stages
from dsocli.constants import *
from dsocli.exceptions import DSOException
from dsocli.contexts import Contexts
from dsocli.local_utils import *
from dsocli.settings import *


__default_spec = {
    'path': os.path.join(AppConfig.config_dir, 'parameters'),
    # 'namespace': 'default',
    'store': 'local.json',
}


def get_default_spec():
    return __default_spec.copy()



class LocalParameterProvider(ParameterProvider):

    def __init__(self):
        super().__init__('parameter/local/v1')

    @property
    def root_path(self):
        return AppConfig.parameter_spec('path')


    def get_path_prefix(self):
        # return self.root_path + os.sep
        return self.root_path

    @property
    def namespace(self):
        return AppConfig.parameter_spec('namespace')


    @property
    def store_name(self):
        return AppConfig.parameter_spec('store')


    def add(self, key, value):
        Logger.debug(f"Adding local parameter '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        response = add_local_parameter(key=key, value=value, store_name=self.store_name, path_prefix=self.get_path_prefix())
        return response


    def list(self, uninherited=False, filter=None):
        Logger.debug(f"Listing local parameters: namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        parameters = load_context_local_parameters(store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=uninherited, filter=filter)
        result = {'Parameters': []}
        for key, details in parameters.items():
            item = {
                'Key': key,
            }
            item.update(details)
            result['Parameters'].append(item)

        return result



    def get(self, key, revision=None):
        if revision:
            Logger.warn(f"Parameter provider 'local/v1' does not support versioning.")
        Logger.debug(f"Getting parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        found = locate_parameter_in_context_hierachy(key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=False)
        if not found:
            raise DSOException(f"Parameter '{key}' not found nor inherited in the given config: stage={Stages.shorten(AppConfig.short_stage)}")
        result = {
                'Key': key, 
            }
        result.update(found[key])
        return result



    def history(self, key):
        Logger.warn(f"Parameter provider 'local/v1' does not support versioning.")

        Logger.debug(f"Getting parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        found = locate_parameter_in_context_hierachy(key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=False)
        if not found:
            raise DSOException(f"Parameter '{key}' not found nor inherited in the given config: stage={Stages.shorten(AppConfig.short_stage)}")
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
        found = locate_parameter_in_context_hierachy(key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=True)
        if not found:
            raise DSOException(f"Parameter '{key}' not found in the given config: namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        Logger.info(f"Deleting parameter: path={found[key]['Path']}")
        delete_local_parameter(found[key]['Path'], key=key)
        result = {
                'Key': key,
                'Stage': AppConfig.short_stage,
                'Scope': found[key]['Scope'], 
                'Origin': found[key]['Origin'], 
                'Path': found[key]['Path'],
            }
        return result



def register():
    Providers.register(LocalParameterProvider())
