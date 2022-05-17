
from .constants import *
from .providers import KeyValueStoreProvider, Providers
from .logger import Logger
from .appconfigs import ContextSource


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

    def list(self, uninherited=False, filter=None):
        from .appconfigs import AppConfigs
        provider = Providers.ConfigProvider()
        Logger.debug(f"Listing configurations: namespace={AppConfigs.get_namespace(ContextSource.Target)}, application={AppConfigs.get_application(ContextSource.Target)}, stage={AppConfigs.get_stage(ContextSource.Target)}, scope={AppConfigs.scope}")
        response = provider.list(uninherited=uninherited, filter=filter)
        return response


    def set(self, key, value):
        from .appconfigs import AppConfigs
        # self.validate_key(key)
        provider = Providers.ConfigProvider()
        Logger.debug(f"Setting configuration '{key}': namespace={AppConfigs.get_namespace(ContextSource.Target)}, application={AppConfigs.get_application(ContextSource.Target)}, stage={AppConfigs.get_stage(ContextSource.Target)}, scope={AppConfigs.scope}")
        return provider.set(key=key, value=value)


    def get(self, key, revision=None, uninherited=False, rendered=True):
        from .appconfigs import AppConfigs
        provider = Providers.ConfigProvider()
        Logger.debug(f"Getting configuration '{key}': namespace={AppConfigs.get_namespace(ContextSource.Target)}, application={AppConfigs.get_application(ContextSource.Target)}, stage={AppConfigs.get_stage(ContextSource.Target)}, scope={AppConfigs.scope}")
        return provider.get(key=key, revision=revision, uninherited=uninherited, rendered=rendered)


    # def history(self, key):
    #   from .appconfigs import AppConfigs
    #     self.config = config
    #     provider = Providers.ConfigProvider()
    #     Logger.debug(f"Fetching history of configuration '{key}': namespace={AppConfigs.get_namespace(ContextSource.Target)}, application={AppConfigs.get_application(ContextSource.Target)}, stage={AppConfigs.get_stage(ContextSource.Target)}, scope={AppConfigs.scope}")
    #     return provider.history(service=service, key)


    def unset(self, key, service):
        from .appconfigs import AppConfigs
        self.service = service
        provider = Providers.ConfigProvider()
        Logger.debug(f"Unsetting configuration '{key}': namespace={AppConfigs.get_namespace(ContextSource.Target)}, application={AppConfigs.get_application(ContextSource.Target)}, stage={AppConfigs.get_stage(ContextSource.Target)}, scope={AppConfigs.scope}")
        return provider.unset(key=key, service=service)


Configs = ConfigService()
