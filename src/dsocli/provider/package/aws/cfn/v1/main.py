from dsocli.exceptions import DSOException
from dsocli.logger import Logger
from dsocli.providers import Providers
from dsocli.artifacts import ArtifactStore
from dsocli.packages import PackageProvider
from dsocli.stages import Stages
from dsocli.constants import *
from dsocli.contexts import Contexts
from dsocli.aws_s3_utils import *
from dsocli.settings import *
from dsocli.appconfig import AppConfig

__default_spec = {
    'foo': 'bar',
}


def get_default_spec():
    return __default_spec.copy()


class AwsCfnPackageProvider(PackageProvider):

    def __init__(self):
        super().__init__('package/aws/cfn/v1')

    def build(self):
        Logger.debug(f"Building CFN package: namespace:{AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        return 'package1.zip'


def register():
    Providers.register(AwsCfnPackageProvider())
