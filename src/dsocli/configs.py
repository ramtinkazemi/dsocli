
import os
import re
from .constants import *
from .providers import KeyValueStoreProvider, Providers
from .logger import Logger
from .exceptions import DSOException
from .stages import Stages
from .appconfig import AppConfig, ContextSource


class ConfigProvider(KeyValueStoreProvider):
    def list(self, service, uninherited, filter):
        raise NotImplementedError()
    def set(self, key, value, service):
        raise NotImplementedError()
    def get(self, key, revision, service):
        raise NotImplementedError()
    def history(self, key, service):
        raise NotImplementedError()
    def unset(self, key, service):
        raise NotImplementedError()


class ConfigService():

    def list(self, service, uninherited=False, filter=None):
        self.service = service
        provider = Providers.ConfigProvider()
        Logger.debug(f"Listing configurations: namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        response = provider.list(service=service, uninherited=uninherited, filter=filter)
        return response


    def set(self, key, value, service):
        self.service = service
        if not key: key = os.path.basename(filepath)
        # self.validate_key(key)
        provider = Providers.ConfigProvider()
        Logger.debug(f"Setting configuration '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        return provider.set(key=key, value=value, service=service)


    def get(self, key, service):
        self.service = service
        provider = Providers.ConfigProvider()
        Logger.debug(f"Getting configuration '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        return provider.get(key=key, service=service)


    # def history(self, key):
    #     self.config = config
    #     provider = Providers.ConfigProvider()
    #     Logger.debug(f"Getting the history of configuration '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
    #     return provider.history(service=service, key)


    def uset(self, key, service):
        self.service = service
        provider = Providers.ConfigProvider()
        Logger.debug(f"Unsetting configuration '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        return provider.unset(key=key, service=service)


Configs = ConfigService()