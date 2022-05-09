import boto3
from dsocli.exceptions import DSOException
from dsocli.logger import Logger
from dsocli.providers import Providers
from dsocli.configs import ConfigProvider
from dsocli.stages import Stages
from dsocli.constants import *
from dsocli.dict_utils import set_dict_value
from dsocli.contexts import Contexts
from dsocli.aws_ssm_utils import *
from dsocli.appconfigs import AppConfigs


__default_spec = {
    'pathPrefix': '/dso/config/',
}

def get_default_spec():
    return __default_spec.copy()


class AwsSsmConfigProvider(ConfigProvider):

    def __init__(self):
        super().__init__('config/aws/ssm/v1')


    ### adds service name to the artifactStore prefix
    def get_path_prefix(self, service):
        configPathPrefix = AppConfigs.config_spec('pathPrefix')
        if not configPathPrefix.endswith('/'): configPathPrefix += '/'
        return configPathPrefix + service


    def list(self, service, uninherited=False, filter=None):
        self.service = service
        Logger.debug(f"Listing configuration on SSM: service={service}")
        configuration = load_context_ssm_parameters(parameter_type='String', path_prefix=self.get_path_prefix(service), uninherited=uninherited, filter=filter)
        result = {'Configuration': []}
        for key, details in configuration.items():
            item = {
                'Key': key,
                'RevisionId': str(details['Version']),
            }
            item.update(details)
            result['Configuration'].append(item)

        return result


    def set(self, key, value, service):
        self.service = service
        Logger.debug(f"Checking configuration overwrites '{key}' on SSM: service={service}")
        assert_ssm_parameter_no_namespace_overwrites(key=key, path_prefix=self.get_path_prefix(service))
        Logger.debug(f"Locating configuration setting '{key}' on SSM: service={service}")
        found = locate_ssm_parameter_in_context_hierachy(key=key, path_prefix=self.get_path_prefix(service), uninherited=True)
        if found and not found['Type'] == 'String':
            raise DSOException(f"Failed to add parameter '{key}' becasue becasue the key is not available in the given context: namespace:{AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        path = get_ssm_path(context=AppConfigs.context, key=key, path_prefix=self.get_path_prefix(service))
        Logger.debug(f"Adding configuration setting: path={path}")
        response = add_ssm_paramater(path, value)
        result = {
                'RevisionId': str(response['Version']),
                'Key': key, 
                'Value': value,
                'Stage': AppConfigs.short_stage,
                'Scope': AppConfigs.context.scope_translation,
                'Origin': {
                    'Namespace': AppConfigs.namespace,
                    'Application': AppConfigs.application,
                    'Stage': AppConfigs.stage,
                },
                'Path': path,
            }
        result.update(response)
        return result



    def get(self, key, service, revision=None):
        self.service = service
        Logger.debug(f"Locating configuration setting '{key}' on SSM: service={service}")
        found = locate_ssm_parameter_in_context_hierachy(key=key, path_prefix=self.get_path_prefix(service))
        if not found:
            raise DSOException(f"Config '{key}' not found nor inherited in the given context: namespace:{AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        else:
            if not found['Type'] == 'String':
                raise DSOException(f"Configuration setting '{key}' not found in the given context: namespace:{AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        Logger.debug(f"Getting configuration setting from SSM: path={found['Name']}")
        response = get_ssm_parameter_history(found['Name'])
        configuration = sorted(response['Parameters'], key=lambda x: int(x['Version']), reverse=True)
        if revision is None:
            ### get the latest revision
            result = {
                    'RevisionId': str(configuration[0]['Version']),
                    'Date': configuration[0]['LastModifiedDate'].strftime('%Y/%m/%d-%H:%M:%S'),
                    'Key': key, 
                    'Value': configuration[0]['Value'],
                    'Scope': found['Scope'],
                    'Origin': found['Origin'],
                    'Path': found['Name'],
                    'User': configuration[0]['LastModifiedUser'],
                    }
                
        else:
            ### get specific revision
            configuration = [x for x in configuration if str(x['Version']) == revision]
            if not configuration:
                raise DSOException(f"Revision '{revision}' not found for parameter '{key}' in the given context: namespace:{AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
            result = {
                    'RevisionId':str(configuration[0]['Version']),
                    'Date': configuration[0]['LastModifiedDate'].strftime('%Y/%m/%d-%H:%M:%S'),
                    'Key': key, 
                    'Value': configuration[0]['Value'],
                    'Scope': found['Scope'],
                    'Origin': found['Origin'],
                    'Path': found['Name'],
                    'User': configuration[0]['LastModifiedUser'],
                    }

        return result


    def history(self, key, service):
        self.service = service
        Logger.debug(f"Locating configuration setting '{key}' on SSM: service={service}")
        found = locate_ssm_parameter_in_context_hierachy(key=key, path_prefix=self.get_path_prefix(service))
        if not found:
            raise DSOException(f"Config '{key}' not found in the given context: namespace:{AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        else:
            if not found['Type'] == 'String':
                raise DSOException(f"Config '{key}' not found in the given context: namespace:{AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        Logger.debug(f"Getting configuration from SSM: path={found['Name']}")
        response = get_ssm_parameter_history(found['Name'])
        parameters = sorted(response['Parameters'], key=lambda x: int(x['Version']), reverse=True)
        result = { "Revisions":
            [{
                'RevisionId': str(parameter['Version']),
                'Date': parameter['LastModifiedDate'].strftime('%Y/%m/%d-%H:%M:%S'),
                'Key': key,
                'Value': parameter['Value'],
                # 'Scope': found['Scope'],
                # 'Origin': found['Origin'],
                'User': parameter['LastModifiedUser'],
                # 'Path': found['Name'],
            } for parameter in parameters]
        }

        return result



    def unset(self, key, service):
        self.service = service
        Logger.debug(f"Locating configuration setting '{key}' on SSM: service={service}")
        ### only configuration owned by the context can be deleted, hence uninherited=True
        found = locate_ssm_parameter_in_context_hierachy(key=key, path_prefix=self.get_path_prefix(service), uninherited=True)
        if not found:
            raise DSOException(f"Configuration '{key}' not found in the given context: namespace:{AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        else:
            # if len(found) > 1:
            #     Logger.warn(f"More than one parameter found at '{found['Name']}'. The first one taken, and the rest were discarded.")
            if not found['Type'] == 'String':
                raise DSOException(f"Configuraton '{key}' not found in the given context: namespace:{AppConfigs.namespace}, application={AppConfigs.application}, stage={AppConfigs.short_stage}")
        Logger.debug(f"Deleting configuration from SSM: path={found['Name']}")
        delete_ssm_parameter(found['Name'])
        result = {
                'Key': key,
                'Stage': found['Stage'],
                'Scope': found['Scope'],
                'Origin': found['Origin'],
                'Path': found['Name'],
                }
        return result


def register():
    Providers.register(AwsSsmConfigProvider())
