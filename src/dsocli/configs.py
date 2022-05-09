
from .constants import *
from .providers import KeyValueStoreProvider, Providers
from .logger import Logger


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
        from .appconfigs import AppConfigs
        self.service = service
        provider = Providers.ConfigProvider()
        Logger.debug(f"Listing configurations: namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        response = provider.list(service=service, uninherited=uninherited, filter=filter)
        return response


    def set(self, key, value, service):
        from .appconfigs import AppConfigs
        self.service = service
        # self.validate_key(key)
        provider = Providers.ConfigProvider()
        Logger.debug(f"Setting configuration '{key}': namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        return provider.set(key=key, value=value, service=service)


    def get(self, key, service):
        from .appconfigs import AppConfigs
        self.service = service
        provider = Providers.ConfigProvider()
        Logger.debug(f"Getting configuration '{key}': namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        return provider.get(key=key, service=service)


    # def history(self, key):
    #   from .appconfigs import AppConfigs
    #     self.config = config
    #     provider = Providers.ConfigProvider()
    #     Logger.debug(f"Fetching history of configuration '{key}': namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
    #     return provider.history(service=service, key)


    def unset(self, key, service):
        from .appconfigs import AppConfigs
        self.service = service
        provider = Providers.ConfigProvider()
        Logger.debug(f"Unsetting configuration '{key}': namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        return provider.unset(key=key, service=service)


Configs = ConfigService()
