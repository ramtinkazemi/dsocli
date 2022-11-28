from .constants import *
from .logger import Logger



class RemoteConfigService():

    def list(self, filter=None, uninherited=False):
        from .providers import Providers
        provider = Providers.RemoteConfigProvider()
        response = provider.list(filter=filter, uninherited=uninherited)
        return response


    def set(self, key, value):
        # self.validate_key(key)
        from .providers import Providers
        provider = Providers.RemoteConfigProvider()
        return provider.set(key=key, value=value)


    def get(self, key, revision=None, uninherited=False, rendered=True):
        from .providers import Providers
        provider = Providers.RemoteConfigProvider()
        return provider.get(key=key, revision=revision, uninherited=uninherited, rendered=rendered)


    def history(self, key):
        from .providers import Providers
        provider = Providers.RemoteConfigProvider()
        return provider.history(key)


    def unset(self, key):
        from .providers import Providers
        provider = Providers.RemoteConfigProvider()
        return provider.unset(key=key)


RemoteConfig = RemoteConfigService()
