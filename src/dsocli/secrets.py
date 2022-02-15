import re
from .logger import Logger
from .providers import KeyValueStoreProvider, Providers
from .stages import Stages
from .constants import *
from .exceptions import *
from .appconfig import AppConfig, ContextSource



key_regex_pattern = r"^[a-zA-Z]([.a-zA-Z0-9_-]*[a-zA-ZA-Z0-9])?$"

class SecretProvider(KeyValueStoreProvider):
    def list(self, uninherited=False, decrypt=False, filter=None):
        raise NotImplementedError()
    def add(self, key, value):
        raise NotImplementedError()
    def get(self, key, decrypt=False, revision=None):
        raise NotImplementedError()
    def history(self, key, decrypt=False):
        raise NotImplementedError()
    def delete(self, key):
        raise NotImplementedError()


class SecretService():

    def validate_key(self, key):
        Logger.info(f"Validating secret key '{key}'...")
        if not key:
            raise DSOException(MESSAGES['KeyNull'])
        if key == 'dso' or key.startswith('dso.'):
            raise DSOException(MESSAGES['DSOReserverdKey'].format(key))
        if not re.match(key_regex_pattern, key):
            raise DSOException(MESSAGES['InvalidKeyPattern'].format(key, key_regex_pattern))
        if '..' in key:
            raise DSOException(MESSAGES['InvalidKeyStr'].format(key, '..'))

    def list(self, uninherited=False, decrypt=False, filter=None):
        provider = Providers.SecretProvider()
        Logger.info(f"Listing secrets: namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.list(uninherited, decrypt, filter)

    def add(self, key, value):
        self.validate_key(key)
        provider = Providers.SecretProvider()
        Logger.info(f"Adding secret '{key}': namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.add(key, value)

    def get(self, key, decrypt=False, revision=None, uninherited=False, editable=False):
        # self.validate_key(key)
        provider = Providers.SecretProvider()
        Logger.info(f"Getting secret '{key}': namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.get(key, decrypt, revision, uninherited, editable)

    def history(self, key, decrypt=False):
        # self.validate_key(key)
        provider = Providers.SecretProvider()
        Logger.info(f"Getting the history of secret '{key}': namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.history(key, decrypt)

    def delete(self, key):
        # self.validate_key(key)
        provider = Providers.SecretProvider()
        Logger.info(f"Deleting secret '{key}': namespace={AppConfig.get_namespace(ContextSource.Target)}, project={AppConfig.get_project(ContextSource.Target)}, application={AppConfig.get_application(ContextSource.Target)}, stage={AppConfig.get_stage(ContextSource.Target, short=True)}, scope={AppConfig.scope}")
        return provider.delete(key)

Secrets = SecretService()
