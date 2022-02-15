
import os
import re
from .constants import *
from .providers import ProviderBase, Providers
from .artifacts import ArtifactStore
from .logger import Logger
from .exceptions import DSOException
from .stages import Stages
from .appconfig import AppConfig, ContextSource
from .configs import Configs

key_regex_pattern = r"^[a-zA-Z]([./a-zA-Z0-9_-]*[a-zA-Z0-9])?$"

class ReleaseProvider(ProviderBase):
    def list(self, filter=None):
        raise NotImplementedError()
    def build(self, key):
        raise NotImplementedError()
    def get(self, key, revision=None):
        raise NotImplementedError()
    # def history(self, key):
    #     raise NotImplementedError()
    def delete(self, key):
        raise NotImplementedError()


class ReleaseService():
    

    service_name = 'release'


    # def validate_key(self, key):
    #     Logger.info(f"Validating release key '{key}'...")
    #     if not key:
    #         raise DSOException(MESSAGES['KeyNull'])
    #     if key == 'dso' or key.startswith('dso.'):
    #         raise DSOException(MESSAGES['DSOReserverdKey'].format(key))
    #     if not re.match(key_regex_pattern, key):
    #         raise DSOException(MESSAGES['InvalidKeyPattern'].format(key, key_regex_pattern))
    #     ### the regex does not check adjacent special chars
    #     if '..' in key:
    #         raise DSOException(MESSAGES['InvalidKeyStr'].format(key, '..'))

    #     if '//' in key:
    #         raise DSOException(MESSAGES['InvalidKeyStr'].format(key, '//'))


    @property
    def version_major(self):
        try:
            return int(Configs.get(key='version.major', service=self.service_name)['Value'])
        except DSOException:
            init_version_major = 0
            self.version_major = init_version_major
            return init_version_major

    @version_major.setter
    def version_major(self, value):
        Configs.set(key='version.major', value=str(value), service=self.service_name)


    @property
    def version_minor(self):
        try:
            return int(Configs.get(key='version.minor', service=self.service_name)['Value'])
        except DSOException:
            init_version_minor = 0
            self.version_minor = init_version_minor
            return init_version_minor

    @version_minor.setter
    def version_minor(self, value):
        Configs.set(key='version.minor', value=str(value), service=self.service_name)


    @property
    def version_patch(self):
        try:
            return int(Configs.get(key='version.patch', service=self.service_name)['Value'])
        except DSOException:
            init_version_patch = 0
            self.version_patch = init_version_patch
            return init_version_patch

    @version_patch.setter
    def version_patch(self, value):
        Configs.set(key='version.patch', value=str(value), service=self.service_name)


    @property
    def version_release(self):
        try:
            return int(Configs.get(key='version.release', service=self.service_name)['Value'])
        except DSOException:
            init_version_release = 0
            self.version_release = init_version_release
            return init_version_release


    @version_release.setter
    def version_release(self, value):
        Configs.set(key='version.release', value=str(value), service=self.service_name)


    def list(self, filter=None):
        provider = Providers.ReleaseProvider()
        Logger.info(f"Listing releases: namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        response = ArtifactStore.list(service=self.service_name, filter=filter)
        result = {'Releases': response['Artifacts']}
        return result


    def create(self):
        provider = Providers.ReleaseProvider()
        Logger.info(f"Creating release: namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        artifact = provider.create()
        major = self.version_major
        minor = self.version_minor
        patch = self.version_patch
        release = self.version_release
        artifactKey = f"{major}.{minor}.{patch}.{release}"
        self.version_release = release + 1
        Logger.info(f"Adding release '{artifactKey}' to artifact store...")
        # changed = Logger.decrease_verbosity()
        # try:
        #     response = ArtifactStore.add(filepath=artifact, key=artifactKey ,service=self.service_name)
        # finally:
        #     if changed: Logger.increase_verbosity()
        response = ArtifactStore.add(filepath=artifact, key=artifactKey ,service=self.service_name)
        return response


    def get(self, key):
        Logger.info(f"Getting release '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        response = ArtifactStore.get(key=key, service=self.service_name)
        return response


    # def history(self, key):
    #     self.config = config
    #     provider = Providers.ReleaseProvider()
    #     Logger.info(f"Getting the history of release '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
    #     return provider.history(key)


    def delete(self, key):
        Logger.info(f"Deleting release '{key}': namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        response = ArtifactStore.delete(key=key, service=self.service_name)
        return response


Releases = ReleaseService()