import boto3
from dsocli.exceptions import DSOException
from dsocli.logger import Logger
from dsocli.providers import Providers
from dsocli.parameters import ParameterProvider
from dsocli.stages import Stages
from dsocli.constants import *
from dsocli.dict_utils import set_dict_value
from dsocli.contexts import Contexts
from dsocli.aws_ssm_utils import *
from dsocli.appconfig import AppConfig


__default_spec = {
    'pathPrefix': '/dso/v1/parameter/',
}

def get_default_spec():
    return __default_spec.copy()


class AwsSsmParameterProvider(ParameterProvider):

    def __init__(self):
        super().__init__('parameter/aws/ssm/v1')


    def get_path_prefix(self):
        return AppConfig.parameter_spec('pathPrefix')


    def list(self, uninherited=False, filter=None):
        Logger.debug(f"Listing SSM parameters: namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        parameters = load_context_ssm_parameters(parameter_type='String', path_prefix=self.get_path_prefix(), uninherited=uninherited, filter=filter)
        result = {'Parameters': []}
        for key, details in parameters.items():
            item = {
                'Key': key,
                'RevisionId': str(details['Version']),
            }
            item.update(details)
            result['Parameters'].append(item)

        return result

    def edit(self, key):
        Logger.debug(f"Editing SSM parameter: namespace={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        parameters = load_context_ssm_parameters(parameter_type='String', path_prefix=self.get_path_prefix(), uninherited=True, filter=f"^{key}$")
        if len(parameters) > 1:
            raise DSOException(f"Mutiple parameters found with the same key in the given context.")
        result = {}
        if parameters:
            result['Key'] = list(parameters.keys())[0]
            result.update(list(parameters.values())[0])

        return result

    def get(self, key, revision=None, uninherited=False, editable=False):
        Logger.debug(f"Locating SSM parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        found = locate_ssm_parameter_in_context_hierachy(key=key, path_prefix=self.get_path_prefix(), uninherited=uninherited)
        if not found:
            if uninherited:
                raise DSOException(f"Parameter '{key}' not found in the given context: namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
            else:
                raise DSOException(f"Parameter '{key}' not found nor inherited in the given context: namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        else:
            if not found['Type'] == 'String':
                raise DSOException(f"Parameter '{key}' not found in the given context: namespace:{AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        Logger.debug(f"Getting SSM parameter: path={found['Name']}")
        response = get_ssm_parameter_history(found['Name'])
        parameters = sorted(response['Parameters'], key=lambda x: int(x['Version']), reverse=True)
        if revision is None:
            ### get the latest revision
            result = {
                    'RevisionId': str(parameters[0]['Version']),
                    'Date': parameters[0]['LastModifiedDate'].strftime('%Y/%m/%d-%H:%M:%S'),
                    'Key': key, 
                    'Value': parameters[0]['Value'],
                    'Scope': found['Scope'],
                    'Origin': found['Origin'],
                    'Path': found['Name'],
                    'User': parameters[0]['LastModifiedUser'],
                    }
                
        else:
            ### get specific revision
            parameters = [x for x in parameters if str(x['Version']) == revision]
            if not parameters:
                raise DSOException(f"Revision '{revision}' not found for parameter '{key}' in the given context: namespace:{AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
            result = {
                    'RevisionId':str(parameters[0]['Version']),
                    'Date': parameters[0]['LastModifiedDate'].strftime('%Y/%m/%d-%H:%M:%S'),
                    'Key': key, 
                    'Value': parameters[0]['Value'],
                    'Scope': found['Scope'],
                    'Origin': found['Origin'],
                    'Path': found['Name'],
                    'User': parameters[0]['LastModifiedUser'],
                    }

        return result


    def add(self, key, value):
        Logger.debug(f"Checking SSM parameter overwrites '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        assert_ssm_parameter_no_namespace_overwrites(key=key, path_prefix=self.get_path_prefix())
        Logger.debug(f"Locating SSM parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        found = locate_ssm_parameter_in_context_hierachy(key=key, path_prefix=self.get_path_prefix(), uninherited=True)
        if found and not found['Type'] == 'String':
            raise DSOException(f"Failed to add parameter '{key}' becasue becasue the key is not available in the given context: namespace:{AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        path = get_ssm_path(context=AppConfig.context, key=key, path_prefix=self.get_path_prefix())
        Logger.debug(f"Adding SSM parameter: path={path}")
        response = add_ssm_paramater(path, value)
        result = {
                'RevisionId': str(response['Version']),
                'Key': key, 
                'Value': value,
                'Stage': AppConfig.short_stage,
                'Scope': AppConfig.context.scope_translation,
                'Origin': {
                    'Namespace': AppConfig.namespace,
                    'Project': AppConfig.project,
                    'Application': AppConfig.application,
                    'Stage': AppConfig.stage,
                },
                'Path': path,
            }
        result.update(response)
        return result





    def history(self, key):
        Logger.debug(f"Locating SSM parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        found = locate_ssm_parameter_in_context_hierachy(key=key, path_prefix=self.get_path_prefix())
        if not found:
            raise DSOException(f"Parameter '{key}' not found in the given context: namespace:{AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        else:
            if not found['Type'] == 'String':
                raise DSOException(f"Parameter '{key}' not found in the given context: namespace:{AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        Logger.debug(f"Getting SSM parameter: path={found['Name']}")
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



    def delete(self, key):
        Logger.debug(f"Locating SSM parameter '{key}': namesape={AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.stage}")
        ### only parameters owned by the context can be deleted, hence uninherited=True
        found = locate_ssm_parameter_in_context_hierachy(key=key, path_prefix=self.get_path_prefix(), uninherited=True)
        if not found:
            raise DSOException(f"Parameter '{key}' not found in the given context: namespace:{AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        else:
            # if len(found) > 1:
            #     Logger.warn(f"More than one parameter found at '{found['Name']}'. The first one taken, and the rest were discarded.")
            if not found['Type'] == 'String':
                raise DSOException(f"Parameter '{key}' not found in the given context: namespace:{AppConfig.namespace}, project={AppConfig.project}, application={AppConfig.application}, stage={AppConfig.short_stage}")
        Logger.debug(f"Deleting SSM parameter: path={found['Name']}")
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
    Providers.register(AwsSsmParameterProvider())
