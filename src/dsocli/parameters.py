import re
from .logger import Logger
from .providers import KeyValueStoreProvider, Providers
from .stages import Stages
from .constants import *
from .exceptions import *
from .appconfig import AppConfig, ContextSource


key_regex_pattern = r"^[a-zA-Z]([.a-zA-Z0-9_-]*[a-zA-Z0-9])?$"

class ParameterProvider(KeyValueStoreProvider):
    def list(self, uninherited=False, filter=None):
        raise NotImplementedError()
    def add(self, key, value):
        raise NotImplementedError()
    def get(self, key, revision=None):
        raise NotImplementedError()
    def history(self, key):
        raise NotImplementedError()
    def delete(self, key):
        raise NotImplementedError()


class ParameterService():

    def validate_key(self, key):
        Logger.info(f"Validating parameter key '{key}'...")
        if not key:
            raise DSOException(MESSAGES['KeyNull'])
        if key == 'dso' or key.startswith('dso.'):
            raise DSOException(MESSAGES['DSOReserverdKey'].format(key))
        if not re.match(key_regex_pattern, key):
            raise DSOException(MESSAGES['InvalidKeyPattern'].format(key, key_regex_pattern))
        if '..' in key:
            raise DSOException(MESSAGES['InvalidKeyStr'].format(key, '..'))
            
    def list(self, uninherited=False, filter=None):
        provider = Providers.ParameterProvider()
        Logger.info(f"Listing parameters: namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.list(uninherited, filter)

    def add(self, key, value):
        self.validate_key(key)
        provider = Providers.ParameterProvider()
        Logger.info(f"Adding parameter '{key}': namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.add(key, value)

    def get(self, key, revision=None):
        # self.validate_key(key)
        provider = Providers.ParameterProvider()
        Logger.info(f"Getting parameter '{key}': namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.get(key, revision)

    def history(self, key):
        # self.validate_key(key)
        provider = Providers.ParameterProvider()
        Logger.info(f"Getting the history of parameter '{key}': namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.history(key)

    def delete(self, key):
        # self.validate_key(key)
        provider = Providers.ParameterProvider()
        Logger.info(f"Deleting parameter '{key}': namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.delete(key)

Parameters = ParameterService()