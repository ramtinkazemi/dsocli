
import os
from .constants import *
from .providers import Providers
from .logger import Logger
from .exceptions import DSOException
from .stages import Stages
from .appconfigs import AppConfigs, ContextSource


class ArtifactStoreService():

    def list(self, service, filter=None):
        provider = Providers.ArtifactStoreProvider()
        Logger.info(f"Listing artifacts: namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        response = provider.list(filter=filter, service=service)
        result = {
            'Artifacts': response['Files']
        }
        return result

    def add(self, filepath, service, key=None):
        if not key: key = os.path.basename(filepath)
        # self.validate_key(key)
        provider = Providers.ArtifactStoreProvider()
        Logger.info(f"Adding artifact '{key}': namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        return provider.add(filepath=filepath, key=key, service=service)


    def get(self, key, service):
        provider = Providers.ArtifactStoreProvider()
        Logger.info(f"Getting artifact '{key}': namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        return provider.get(key=key, service=service)


    # def history(self, key):
    #     self.AppConfig = AppConfig
    #     provider = Providers.ArtifactStoreProvider()
    #     Logger.info(f"Fetching history of artifact '{key}': namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
    #     return provider.history(key)


    def delete(self, key, service):
        provider = Providers.ArtifactStoreProvider()
        Logger.info(f"Deleting artifact '{key}': namespace={AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        return provider.delete(key=key, service=service)



ArtifactStore = ArtifactStoreService()
