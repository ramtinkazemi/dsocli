import os
from dsocli.logger import Logger
from dsocli.appconfig import AppConfig
from dsocli.providers import Providers
from dsocli.configs import ConfigProvider
from dsocli.stages import Stages
from dsocli.constants import *
from dsocli.exceptions import DSOException
from dsocli.contexts import Contexts
from dsocli.local_utils import *
from dsocli.settings import *


__default_spec = {
    'path': os.path.join(AppConfig.config_dir, 'config'),
    # 'namespace': 'default',
    'store': 'local.json',
}


def get_default_spec():
    return __default_spec.copy()



class LocalConfigProvider(ConfigProvider):

    def __init__(self):
        super().__init__('config/local/v1')

    @property
    def root_path(self):
        return self.config.config_spec('path')


    def get_path_prefix(self):
        # return self.root_path + os.sep
        return self.root_path

    @property
    def namespace(self):
        return self.config.config_spec('namespace')


    @property
    def store_name(self):
        return self.config.config_spec('store')


    def add(self, config, key, value):
        self.config = config
        Logger.debug(f"Adding local config '{key}': namespace={config.namespace}, application={config.application}, stage={config.stage}")
        response = add_local_parameter(config=config, key=key, value=value, store_name=self.store_name, path_prefix=self.get_path_prefix())
        return response


    def list(self, config, uninherited=False, filter=None):
        self.config = config
        Logger.debug(f"Listing local configs: namespace={config.namespace}, application={config.application}, stage={config.stage}")
        configs = load_context_local_parameters(config=config, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=uninherited, filter=filter)
        result = {'Configuration': []}
        for key, details in configs.items():
            item = {
                'Key': key,
            }
            item.update(details)
            result['Configuration'].append(item)

        return result



    def get(self, config, key, revision=None):
        self.config = config
        if revision:
            Logger.warn(f"Config provider 'local/v1' does not support versioning.")
        Logger.debug(f"Getting config '{key}': namesape={config.namespace}, application={config.application}, stage={config.stage}")
        found = locate_parameter_in_context_hierachy(config=config, key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=False)
        if not found:
            raise DSOException(f"Config '{key}' not found nor inherited in the given context: stage={Stages.shorten(config.short_stage)}")
        result = {
                'Key': key, 
            }
        result.update(found[key])
        return result



    def history(self, config, key):
        self.config = config
        Logger.warn(f"Config provider 'local/v1' does not support versioning.")

        Logger.debug(f"Getting config '{key}': namesape={config.namespace}, application={config.application}, stage={config.stage}")
        found = locate_parameter_in_context_hierachy(config=config, key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=False)
        if not found:
            raise DSOException(f"Config '{key}' not found nor inherited in the given context: stage={Stages.shorten(config.short_stage)}")
        result = { "Revisions":
            [{
                'RevisionId': '0',
                'Date': get_file_modified_date(found[key]['Path']),
            }]
        }
        result['Revisions'][0].update(found[key])
        return result



    def delete(self, config, key):
        self.config = config
        Logger.debug(f"Locating config '{key}': namesape={config.namespace}, application={config.application}, stage={config.stage}")
        ### only configs owned by the config can be deleted, hence uninherited=True
        found = locate_parameter_in_context_hierachy(config=config, key=key, store_name=self.store_name, path_prefix=self.get_path_prefix(), uninherited=True)
        if not found:
            raise DSOException(f"Config '{key}' not found in the given context: namesape={config.namespace}, application={config.application}, stage={config.short_stage}")
        Logger.info(f"Deleting config: path={found[key]['Path']}")
        delete_local_parameter(found[key]['Path'], key=key)
        result = {
                'Key': key,
                'Stage': config.short_stage,
                'Scope': found[key]['Scope'], 
                'Origin': found[key]['Origin'], 
                'Path': found[key]['Path'],
            }
        return result



def register():
    Providers.register(LocalConfigProvider())
