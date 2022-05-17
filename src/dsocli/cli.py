from dataclasses import replace
import sys
import os
import platform
import click
import re
import yaml
import glob
from stdiomask import getpass
from .constants import *
from .cli_constants import *
from .exceptions import DSOException
from .appconfigs import AppConfigs, ContextSource, ConfigSource
import dsocli.logger as logger
from .parameters import Parameters
from .secrets import Secrets
from .templates import Templates
from .packages import Packages
from .releases import Releases
from .networks import Networks
from .click_extend import *
from click_params import RangeParamType
from .cli_utils import *
from .file_utils import *
from .pager import Pager
from .editor import Editor
from .version import __version__
from pathlib import Path
from .dict_utils import *
from .settings import *
from .contexts import ContextScope
from .configs import Configs

modify_click_usage_error()

default_ctx = dict(help_option_names=['-h', '--help'])


@click.group(context_settings=default_ctx)
def cli():
    """DSO CLI"""
    pass


@cli.group(context_settings=default_ctx)
def config():
    """
    Manage DSO application configuration.
    """
    pass


@cli.group(context_settings=default_ctx)
def parameter():
    """
    Manage parameters.
    """
    pass


@cli.group(context_settings=default_ctx)
def secret():
    """
    Manage secrets.
    """
    pass



@cli.group(context_settings=default_ctx)
def template():
    """
    Manage templates.
    """
    pass


@cli.group(context_settings=default_ctx)
def package():
    """
    Manage build packages.
    """
    pass


@cli.group(context_settings=default_ctx)
def release():
    """
    Manage deployment releases.
    """
    pass

@cli.group(context_settings=default_ctx)
def network():
    """
    Manage IP networks.
    """
    pass



# @network.group(context_settings=default_ctx)
# def subnet_plan():
#     """
#     Manage subnet plan.
#     """
#     pass

# @cli.group(context_settings=default_ctx)
# def provision():
#     """
#     Provision resources.
#     """
#     pass

# 

# @cli.group(context_settings=default_ctx)
# def deploy():
#     """
#     Deploy releases.
#     """
#     pass



@cli.command('version', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['version'])
def version():
    """
    Display version details.
    """
    click.echo(f"DSO CLI: {__version__}\nPython: {platform.sys.version}")




@command_doc(CLI_COMMANDS_HELP['parameter']['add'])
@parameter.command('add', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['add'])
@click.argument('key', required=False)
@click.argument('value', required=False)
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def add_parameter(key, value, stage, global_scope, namespace_scope, input, format, verbosity, config_override, working_dir):
    
    parameters = []
    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, parameters

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if input:
            validate_none_provided([key, value], ["KEY", "VALUE"], ["'-i' / '--input'"])
            parameters = read_data(input, 'Parameters', ['Key', 'Value'], format)

            ### eat possible enclosing (double) quotes when source is file, stdin has already eaten them!
            if format == 'shell': 
                for param in parameters:
                    param['Value'] = no_enclosing_quotes(param['Value'])

        ### no input file
        else:
            validate_provided(key, "'KEY'")
            if not value:
                Logger.warn("Null was taken as value.")
            # validate_provided(value, "'VALUE'")
            parameters.append({'Key': key, 'Value': value})

    success = []
    failed = []
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        if len(parameters) == 0:
            Logger.warn("No parameter provided to add.")
        else:
            failed = [x['Key'] for x in parameters]
            for param in parameters:
                success.append(Parameters.add(param['Key'], param['Value']))
                failed.remove(param['Key'])

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)
    finally:
        if parameters:
            failure = []
            for key in failed:
                failure.append({'Key': key})
            result = {'Success': success, 'Failure': failure}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)




@command_doc(CLI_COMMANDS_HELP['parameter']['list'])
@parameter.command('list', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['list'])
@click.option('-u','--uninherited', 'uninherited', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['parameter']['uninherited'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def list_parameter(stage, uninherited, filter, global_scope, namespace_scope, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if format == 'shell' and (query or query_all):
            Logger.warn("Query customizaion was ignored, becasue output format is 'shell'. Use '-f'/'--format' to change it.")

        defaultQuery = '{Parameters: Parameters[*].{Key: Key, Value: Value, Stage: Stage, Scope: Scope}}'
        query = validate_query_argument(query, query_all, defaultQuery)
        
        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Parameters.list(uninherited, filter)
        if len(result['Parameters']) == 0:
            Logger.warn("No parameter found.")

        output = format_data(result, query, format, mainkeys=['Key', 'Value'])
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


@command_doc(CLI_COMMANDS_HELP['parameter']['get'])
@parameter.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['get'])
@click.argument('key', required=True)
@click.option('--revision', metavar='<revision-id', required=False, help=CLI_PARAMETERS_HELP['parameter']['revision'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'raw']), default='raw', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def get_parameter(key, stage, global_scope, namespace_scope, revision, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if format == 'raw' and (query or query_all):
            raise DSOException("Query cannot be customised using '-q'/'--query' or '-a'/'--query-all', becasue output format is 'raw'. Use '-f'/'--format' to change it.")

        defaultQuery = '{Value: Value}'
        query = validate_query_argument(query, query_all, defaultQuery)

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Parameters.get(key, revision)
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['parameter']['edit'])
@parameter.command('edit', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['edit'])
@click.argument('key', required=True)
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def edit_parameter(key, stage, global_scope, namespace_scope, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        ### always edit raw (not rendered) values, e.g. in shell/v1 providers
        result = Parameters.get(key, uninherited=True, rendered=False)
        if result:
            value = format_data(result, 'Value', 'raw')
            from tempfile import NamedTemporaryFile
            ### this code was nicer, but throws permission denided exception on Windows!
            # with NamedTemporaryFile(mode='w', encoding='utf-8', delete=True) as tf:
            #     tf.write(value)
            #     tf.flush()
            #     value, changed = Editor.edit(tf.name)
            tf = NamedTemporaryFile(mode='w', encoding='utf-8', delete=False)
            try:
                tf.write(value)
                tf.flush()
                value, changed = Editor.edit(tf.name)
            finally:
                tf.close()
                os.unlink(tf.name)
            if changed:
                Parameters.add(key, value)
            else:
                Logger.warn(CLI_MESSAGES['NoChanegeDetectedAfterEditing'])
        else:
            raise DSOException(CLI_MESSAGES['ParameterNotFound'].format(key, AppConfigs.get_namespace(ContextSource.Target), AppConfigs.get_application(ContextSource.Target), AppConfigs.get_stage(ContextSource.Target, short=True), AppConfigs.scope))


    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['parameter']['history'])
@parameter.command('history', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['history'])
@click.argument('key', required=True)
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def history_parameter(key, stage, global_scope, namespace_scope, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query
        
        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        defaultQuery = '{Revisions: Revisions[*].{RevisionId: RevisionId, Date: Date, Value: Value}}'
        query = validate_query_argument(query, query_all, defaultQuery)

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Parameters.history(key)
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


@command_doc(CLI_COMMANDS_HELP['parameter']['delete'])
@parameter.command('delete', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['delete'])
@click.argument('key', required=False)
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def delete_parameter(key, stage, global_scope, namespace_scope, input, format, verbosity, config_override, working_dir):

    parameters = []

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, parameters

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if input:
            validate_none_provided([key], ["KEY"], ["'-i' / '--input'"])
            parameters = read_data(input, 'Parameters', ['Key'], format)
        ### no input file
        else:
            validate_provided(key, "KEY")
            parameters.append({'Key': key})

    success = []
    failed = []
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        if len(parameters) == 0:
            Logger.warn("No parameter provided to delete.")
        else:
            failed = [x['Key'] for x in parameters]
            for parameter in parameters:
                success.append(Parameters.delete(parameter['Key']))
                failed.remove(parameter['Key'])

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)
    finally:
        if parameters:
            failure = []
            for key in failed:
                failure.append({'Key': key})
            result = {'Success': success, 'Failure': failure}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)




@command_doc(CLI_COMMANDS_HELP['secret']['add'])
@secret.command('add', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['add'])
@click.argument('key', required=False)
@click.argument('value', required=False)
@click.option('--ask-password', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['secret']['ask_password'])
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def add_secret(key, value, stage, global_scope, namespace_scope, ask_password, input, format, verbosity, config_override, working_dir):

    secrets = []
    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, secrets, value

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if input:
            validate_none_provided([key, value], ["KEY", "VALUE"], ["'-i' / '--input'"])
            secrets = read_data(input, 'Secrets', ['Key', 'Value'], format)

            ### eat possible enclosing (double) quotes when source is file, as stdin has already eaten them!
            if format == 'shell': 
                for secret in secrets:
                    secret['Value'] = no_enclosing_quotes(secret['Value'])

        ### no input file
        else:
            ### should I ask password from stdin?
            if ask_password:
                validate_none_provided([value], ["VALUE"], ["'--ask-password'"])
                value = getpass(" Enter secret value: ")
                if not value == getpass("Verify secret value: "):
                    raise DSOException(CLI_MESSAGES['EnteredSecretValuesNotMatched'].format(format))
            if not value:
                Logger.warn("Null was taken as value.")
            secrets.append({'Key': key, 'Value': value})

    success = []
    failed = []
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        if len(secrets) == 0:
            Logger.warn("No secret provided to add.")
        else:
            failed = [x['Key'] for x in secrets]
            for secret in secrets:
                success.append(Secrets.add(secret['Key'], secret['Value']))
                failed.remove(secret['Key'])

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)
    finally:
        if secrets:
            failure = []
            for key in failed:
                failure.append({'Key': key})
            result = {'Success': success, 'Failure': failure}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)




@command_doc(CLI_COMMANDS_HELP['secret']['list'])
@secret.command('list', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['list'])
@click.option('-d', '--decrypt', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['secret']['decrypt'])
@click.option('-u','--uninherited', 'uninherited', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['secret']['uninherited'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def list_secret(stage, global_scope, namespace_scope, uninherited, decrypt, filter, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if format == 'shell' and (query or query_all):
            Logger.warn("Query customizaion was ignored, becasue output format is 'shell'. Use '-f'/'--format' to change it.")

        defaultQuery = '{Secrets: Secrets[*].{Key: Key, Value: Value, Scope: Scope, Origin: Origin}}'
        query = validate_query_argument(query, query_all, defaultQuery)

        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Secrets.list(uninherited, decrypt, filter)
        if len(result['Secrets']) == 0:
            Logger.warn("No secret found.")

        output = format_data(result, query, format, mainkeys=['Key', 'Value'])
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


@command_doc(CLI_COMMANDS_HELP['secret']['get'])
@secret.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['get'])
@click.argument('key', required=True)
@click.option('--revision', metavar='<revision-id', required=False, help=CLI_PARAMETERS_HELP['parameter']['revision'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'raw']), default='raw', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def get_secret(stage, global_scope, namespace_scope, key, revision, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query
        
        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if format == 'raw' and (query or query_all):
            raise DSOException("Query cannot be customised using '-q'/'--query' or '-a'/'--query-all', becasue output format is 'raw'. Use '-f'/'--format' to change it.")

        defaultQuery = '{Value: Value}'
        query = validate_query_argument(query, query_all, defaultQuery)


    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Secrets.get(key, revision, decrypt=True)

        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['secret']['edit'])
@secret.command('edit', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['edit'])
@click.argument('key', required=True)
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def edit_secret(key, stage, global_scope, namespace_scope, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        ### always edit raw values (rendered/decrypted), e.g. in shell/v1 providers
        result = Secrets.get(key, uninherited=True, decrypt=False)
        if result:
            value = format_data(result, 'Value', 'raw')
            from tempfile import NamedTemporaryFile
            ### this code was nicer, but throws permission denided exception on Windows!
            # with NamedTemporaryFile(mode='w', encoding='utf-8', delete=True) as tf:
            #     tf.write(value)
            #     tf.flush()
            #     value, changed = Editor.edit(tf.name)
            tf = NamedTemporaryFile(mode='w', encoding='utf-8', delete=False)
            try:
                tf.write(value)
                tf.flush()
                value, changed = Editor.edit(tf.name)
            finally:
                tf.close()
                os.unlink(tf.name)

            if changed:
                Secrets.add(key, value)
            else:
                Logger.warn(CLI_MESSAGES['NoChanegeDetectedAfterEditing'])
        else:
            raise DSOException(CLI_MESSAGES['SecretNotFound'].format(key, AppConfigs.get_namespace(ContextSource.Target), AppConfigs.get_application(ContextSource.Target), AppConfigs.get_stage(ContextSource.Target, short=True), AppConfigs.scope))


    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['secret']['history'])
@secret.command('history', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['history'])
@click.argument('key', required=False)
@click.option('-d', '--decrypt', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['secret']['decrypt'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def history_secret(key, stage, global_scope, namespace_scope, decrypt, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        defaultQuery = '{Revisions: Revisions[*].{RevisionId: RevisionId, Date: Date, Value: Value}}'
        query = validate_query_argument(query, query_all, defaultQuery)


    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Secrets.history(key, decrypt)

        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


@command_doc(CLI_COMMANDS_HELP['secret']['delete'])
@secret.command('delete', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['delete'])
@click.argument('key', required=False)
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def delete_secret(key, stage, global_scope, namespace_scope, input, format, verbosity, config_override, working_dir):

    secrets = []
    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, secrets

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if input:
            validate_none_provided([key], ["KEY"], ["'-i' / '--input'"])
            secrets = read_data(input, 'Secrets', ['Key'], format)
        ### no input file
        else:
            validate_provided(key, "KEY")
            secrets.append({'Key': key})

    success = []
    failed = []
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        if len(secrets) == 0:
            Logger.warn("No secret provided to delete.")
        else:
            failed = [x['Key'] for x in secrets]
            for secret in secrets:
                success.append(Secrets.delete(secret['Key']))
                failed.remove(secret['Key'])

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)
    finally:
        if secrets:
            failure = []
            for key in failed:
                failure.append({'Key': key})
            result = {'Success': success, 'Failure': failure}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)



@command_doc(CLI_COMMANDS_HELP['template']['add'])
@template.command('add', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['add'])
# @click.option('--contents', 'contents_path', metavar='<path>', required=False, type=click.Path(exists=False, file_okay=True, dir_okay=True), callback=ConfigSource_from_string, help=CLI_PARAMETERS_HELP['template']['contents_path'])
@click.argument('contents_path', required=False, metavar='PATH', callback=ConfigSource_from_string)
@click.argument('key', required=False)
@click.option('--recursive', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['template']['recursive'])
@click.option('-r', '--render-path', metavar='<path>', required=False, help=CLI_PARAMETERS_HELP['template']['render_path'])
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
@click.option('--recursive', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['template']['recursive'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def add_template(contents_path, recursive, key, render_path, stage, global_scope, namespace_scope, input, format, verbosity, config_override, working_dir):

    templates = []
    scope = ContextScope.App

    def process_key_from_path(path):

        # if not key:
        #     if os.path.samefile(path, contents_path):
        #         return os.path.basename(path)
        #     else:
        #         return path[len(contents_path)+1:]

        result = key
        ### if ** exist in key, replace it with path dirname
        if os.path.dirname(path)[len(contents_path):]:
            result = result.replace('**', os.path.dirname(path)[len(contents_path)+1:])
        else:
            result = result.replace('**/', '')
            result = result.replace('**', '')
        ### if * exist in key, replace it with path basename
        result = result.replace('*', os.path.basename(path))
        ### fix possiblly created // to /
        result = result.replace(f'{os.sep}{os.sep}', os.sep)
        ### fix possibe trailing /
        result = re.sub(f'{os.sep}$', '', result)

        return result


    def process_render_path_from_key(key):

        # if not render_path or render_path in ['.', f'.{os.sep}']:
        #     return os.path.join(f'.{os.sep}', key)

        result = render_path
        ### if ** exist in render_path, replace it with key dirname
        if os.path.dirname(key):
            result = result.replace('**', os.path.dirname(key))
        else:
            result = result.replace('**/', '')
            result = result.replace('**', '')
        ### if * exist in key, replace it with path basename
        result = result.replace('*', os.path.basename(key))
        ### fix possiblly created // to /
        result = result.replace(f'{os.sep}{os.sep}', os.sep)
        ### fix possible trailing /
        result = re.sub(f'{os.sep}$', '', result)

        # if os.path.isabs(result):
        #     Logger.warn(CLI_MESSAGES['RenderPathNotReleative'].format(result))

        # if os.path.isdir(result):
        #     print(render_path)
        #     # raise DSOException(CLI_MESSAGES['InvalidRenderPathExistingDir'].format(result))
        #     result = os.path.join(result, key)

        ### fix possiblly created // to /
        result = result.replace(f'{os.sep}{os.sep}', os.sep)

        return result

        # if result.startswith(f".{os.sep}"):
        #     return result
        # else:
        #     return os.path.join(f".{os.sep}", result)

    def validate_command_usage():
        nonlocal working_dir, scope, contents_path, key, render_path, templates

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if input:
            # validate_none_provided([key], ["KEY"], ["'-i' / '--input'"])
            validate_none_provided([contents_path], ["PATH"], ["'-i' / '--input'"])
            # validate_none_provided([render_path], ["'-r' / '--render-path'"], ["'-i' / '--input'"])
            
            templates = read_data(input, 'Templates', ['Key', 'Contents', 'RenderPath'], format)

        ### no input file
        else:
            validate_provided(contents_path, "PATH") 
            # validate_provided(key, "'KEY")
            if not key:
                key = '**/*'
        
            if os.path.isdir(contents_path):
                ### remove possible trailing /
                contents_path = re.sub(f'{os.sep}$', '', contents_path)
                if recursive:
                    globe =  f'{os.sep}**'
                else:
                    globe = f'{os.sep}*'
                final_path = contents_path + globe
            else:
                final_path = contents_path

            items = glob.glob(final_path, recursive=recursive)

            ### use the current dir as the base for render path
            if not render_path:
                # render_path = f'{AppConfigs.config_dir}{os.sep}output{os.sep}**{os.sep}*'
                render_path = f'**{os.sep}*'
            else:
                if not '*' in render_path:
                    render_path = f'{render_path}{os.sep}**{os.sep}*'

            ### remove starting / if any
            render_path = re.sub(f'^{os.sep}', '', render_path)
            if not render_path.startswith(f'.{os.sep}'):
                render_path = f'.{os.sep}' + render_path

            ### processing templates from path
            for item in items:
                if not Path(item).is_file(): continue
                if is_binary_file(item):
                    Logger.warn(f"Binary file '{item}' ignored.")
                    continue
                p = str(item)
                k = process_key_from_path(p)
                r = process_render_path_from_key(k)
                if os.path.abspath(p) == os.path.abspath(r):
                    Logger.warn(f"Render path is the same as the source path, which will casue the source file to be overwritten when rendering the template: {r}")
                templates.append({'Key': k, 'Contents': open(p, encoding='utf-8', mode='r').read(), 'RenderPath': r})

    success = []
    failed = []
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        if len(templates) == 0:
            Logger.warn("No template provided to add.")
        else:
            failed = [x['Key'] for x in templates]
            for template in templates:
                success.append(Templates.add(template['Key'], template['Contents'], template['RenderPath']))
                failed.remove(template['Key'])

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)
    finally:
        if templates:
            failure = []
            for key in failed:
                failure.append({'Key': key})
            result = {'Success': success, 'Failure': failure}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)



@command_doc(CLI_COMMANDS_HELP['template']['list'])
@template.command('list', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['list'])
@click.option('-u','--uninherited', 'uninherited', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['template']['uninherited'])
@click.option('--include-contents', 'include_contents', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['template']['include_contents'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def list_template(stage, uninherited, include_contents, filter, global_scope, namespace_scope, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if format == 'shell' and (query or query_all):
            Logger.warn("Query customizaion was ignored, becasue output format is 'shell'. Use '-f'/'--format' to change it.")

        if include_contents and not format in ['json', 'yaml']:
            raise DSOException("Contents can be included only when output format is 'json' or 'yaml'. Use '-f'/'--format' to change it.")


        if include_contents:
            defaultQuery = '{Templates: Templates[*].{Key: Key, Stage: Stage, Scope: Scope, RenderPath: RenderPath, Contents: Contents}}'
        else:
            defaultQuery = '{Templates: Templates[*].{Key: Key, Stage: Stage, Scope: Scope, RenderPath: RenderPath}}'
        query = validate_query_argument(query, query_all, defaultQuery)


        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))


    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Templates.list(uninherited, include_contents, filter)
        if len(result['Templates']) == 0:
            Logger.warn("No template found.")
        output = format_data(result, query, format, mainkeys=['Key', 'RenderPath'])
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)




@command_doc(CLI_COMMANDS_HELP['template']['get'])
@template.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['get'])
@click.argument('key', required=True)
@click.option('--revision', metavar='<revision-id', required=False, help=CLI_PARAMETERS_HELP['parameter']['revision'])
# @click.option('-p', '--path', 'include_contents', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['template']['include_contents'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'raw']), default='raw', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def get_template(key, revision, stage, global_scope, namespace_scope, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query
        
        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if format == 'raw' and (query or query_all):
            raise DSOException("Query cannot be customised using '-q'/'--query' or '-a'/'--query-all', becasue output format is 'raw'. Use '-f'/'--format' to change it.")

        defaultQuery = '{Contents: Contents}'
        query = validate_query_argument(query, query_all, defaultQuery)

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Templates.get(key, revision)
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['template']['get'])
@template.command('edit', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['edit'])
@click.argument('key', required=False)
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def edit_template(key, stage, global_scope, namespace_scope, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, config_override

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Templates.list(uninherited=True, include_contents=True, filter=f"^{key}$")
        if result['Templates']:
            contents = format_data(result, '{Contents: Templates[0].Contents}', 'raw')
            renderPath = format_data(result, '{RenderPath: Templates[0].RenderPath}', 'raw')
            from tempfile import NamedTemporaryFile
            ### this code was nicer, but throws permission denided exception on Windows!
            # with NamedTemporaryFile(mode='w', encoding='utf-8', delete=True) as tf:
            #     tf.write(contents)
            #     tf.flush()
            #     contents, changed = Editor.edit(tf.name)
            tf = NamedTemporaryFile(mode='w', encoding='utf-8', delete=False)
            try:
                tf.write(contents)
                tf.flush()
                contents, changed = Editor.edit(tf.name)
            finally:
                tf.close()
                os.unlink(tf.name)

            if changed:
                Templates.add(key, contents, renderPath)
            else:
                Logger.warn(CLI_MESSAGES['NoChanegeDetectedAfterEditing'])
        else:
            raise DSOException(CLI_MESSAGES['TemplateNotFound'].format(key, AppConfigs.get_namespace(ContextSource.Target), AppConfigs.get_application(ContextSource.Target), AppConfigs.get_stage(ContextSource.Target, short=True), AppConfigs.scope))

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['template']['history'])
@template.command('history', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['history'])
@click.argument('key', required=False)
@click.option('-p', '--path', 'include_contents', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['template']['include_contents'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def history_template(stage, key, include_contents, global_scope, namespace_scope, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if include_contents:
            defaultQuery = '{Revisions: Revisions[*].{RevisionId: RevisionId, Date: Date, Contents: Contents}}'
        else:
            defaultQuery = '{Revisions: Revisions[*].{RevisionId: RevisionId, Date: Date}}'
        query = validate_query_argument(query, query_all, defaultQuery)


    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = Templates.history(key, include_contents)
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['template']['delete'])
@template.command('delete', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['delete'])
@click.argument('key', required=False)
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def delete_template(key, input, format, stage, global_scope, namespace_scope, verbosity, config_override, working_dir):

    templates = []

    scope = ContextScope.App


    def validate_command_usage():
        nonlocal working_dir, scope, templates

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if input:
            validate_none_provided([key], ["KEY"], ["'-i' / '--input'"])
            templates = read_data(input, 'Templates', ['Key'], format)
        ### no input file
        else:
            validate_provided(key, "KEY")
            templates.append({'Key': key})

    success = []
    failed = []
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        if len(templates) == 0:
            Logger.warn("No template provided to delete.")
        else:
            failed = [x['Key'] for x in templates]
            for template in templates:
                success.append(Templates.delete(template['Key']))
                failed.remove(template['Key'])

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)
    finally:
        if templates:
            failure = []
            for key in failed:
                failure.append({'Key': key})
            result = {'Success': success, 'Failure': failure}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)




@command_doc(CLI_COMMANDS_HELP['template']['render'])
@template.command('render', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['render'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def render_template(stage, filter, global_scope, namespace_scope, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, config_override
        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)
        response = Templates.render(filter)
        if response:
            result = {'Success': response, 'Failure': []}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)





@command_doc(CLI_COMMANDS_HELP['package']['list'])
@package.command('list', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['package']['list'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def list_package(stage, filter, query, query_all, format, verbosity, config_override, working_dir):
    
    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()


        defaultQuery = '{Packages: Packages[*].{Key: Key, Date: Date}}'
        query = validate_query_argument(query, query_all, defaultQuery)

        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ContextScope.App)

        result = Packages.list(filter)
        if len(result['Packages']) == 0:
            Logger.warn("No package found.")

        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['package']['get'])
@package.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['package']['get'])
@click.argument('key', required=False)
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def get_package(stage, verbosity, config_override, working_dir, key, query, query_all, format):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query, key

        if not working_dir: working_dir = os.getcwd()


        defaultQuery = '{FilePath: FilePath}'
        query = validate_query_argument(query, query_all, defaultQuery)

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ContextScope.App)

        result = Packages.get(key=key)
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


@command_doc(CLI_COMMANDS_HELP['package']['build'])
@package.command('build', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['package']['build'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'raw']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def build_package(stage, verbosity, config_override, working_dir, filter, query, query_all, format):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()


        defaultQuery = '{Key: Key}'
        query = validate_query_argument(query, query_all, defaultQuery)

        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ContextScope.App)

        result = Packages.build()
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['package']['delete'])
@package.command('delete', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['package']['delete'])
@click.argument('key', required=False)
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def delete_package(stage, verbosity, config_override, working_dir, key, input, format):

    packages = []

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, packages

        if not working_dir: working_dir = os.getcwd()


        if input:
            validate_none_provided([key], ["KEY"], ["'-i' / '--input'"])
            packages = read_data(input, 'Packages', ['Key'], format)
        ### no input file
        else:
            packages.append({'Key': key})


    success = []
    failed = []
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ContextScope.App)

        if len(packages) == 0:
            Logger.warn("No packages provided to delete.")
        else:
            failed = [x['Key'] for x in packages]
            for packages in packages:
                success.append(Packages.delete(packages['Key']))
                failed.remove(packages['Key'])

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)
    finally:
        if packages:
            failure = []
            for key in failed:
                failure.append({'Key': key})
            result = {'Success': success, 'Failure': failure}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)





@command_doc(CLI_COMMANDS_HELP['release']['list'])
@release.command('list', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['release']['list'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def list_release(stage, verbosity, config_override, working_dir, filter, query, query_all, format):
    
    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()


        defaultQuery = '{Releases: Releases[*].{Key: Key, Date: Date}}'
        query = validate_query_argument(query, query_all, defaultQuery)

        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ContextScope.App)

        result = Releases.list(filter)
        if len(result['Releases']) == 0:
            Logger.warn("No release found.")

        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['release']['get'])
@release.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['release']['get'])
@click.argument('key', required=True)
@click.option('--key', 'key_option', metavar='<key>', required=False, help=CLI_PARAMETERS_HELP['release']['key'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def get_release(stage, verbosity, config_override, working_dir, key, query, query_all, format):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()


        defaultQuery = '{FilePath: FilePath}'
        query = validate_query_argument(query, query_all, defaultQuery)

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ContextScope.App)

        result = Releases.get(key=key)
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


@command_doc(CLI_COMMANDS_HELP['release']['create'])
@release.command('create', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['release']['create'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'raw']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def create_release(stage, verbosity, config_override, working_dir, filter, query, query_all, format):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()


        defaultQuery = '{Key: Key}'
        query = validate_query_argument(query, query_all, defaultQuery)

        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ContextScope.App)

        result = Releases.create()
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['release']['delete'])
@release.command('delete', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['release']['delete'])
@click.argument('key', required=False)
@click.option('--key', 'key_option', metavar='<key>', required=False, help=CLI_PARAMETERS_HELP['release']['key'])
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'shell']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def delete_release(stage, verbosity, config_override, working_dir, key, input, format):


    scope = ContextScope.App
    releases = []

    def validate_command_usage():
        nonlocal working_dir, scope, releases

        if not working_dir: working_dir = os.getcwd()


        if input:
            validate_none_provided([key], ["KEY"], ["'-i' / '--input'"])
            releases = read_data(input, 'Releases', ['Key'], format)
        ### no input file
        else:
            releases.append({'Key': key})


    success = []
    failed = []
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ContextScope.App)

        if len(releases) == 0:
            Logger.warn("No releases provided to delete.")
        else:
            failed = [x['Key'] for x in releases]
            for releases in releases:
                success.append(Releases.delete(releases['Key']))
                failed.remove(releases['Key'])

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)
    finally:
        if releases:
            failure = []
            for key in failed:
                failure.append({'Key': key})
            result = {'Success': success, 'Failure': failure}
            output = format_data(result, '', RESPONSE_FORMAT)
            Pager.page(output)




@command_doc(CLI_COMMANDS_HELP['config']['init'])
@config.command('init', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['config']['init'])
@click.option('--setup', is_flag=True, required=False, help=CLI_PARAMETERS_HELP['config']['setup'])
@click.option('--override-inherited', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['override_inherited'])
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['config']['input'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def config_init(setup, override_inherited, input, global_scope, namespace_scope, verbosity, config_override, working_dir):

    init_config = None

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, init_config

        if not working_dir: working_dir = os.getcwd()
        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if input:
            try:
                init_config = yaml.load(input, yaml.SafeLoader)
            except:
                raise DSOException(CLI_MESSAGES['InvalidFileFormat'].format('yaml'))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        # AppConfigs.load(working_dir if working_dir else os.getcwd(),
        #                 'global' if global_scope else 'namespace' if namespace_scope else 'application',
        #                 config_override)
        AppConfigs.init(working_dir, custom_init_config=init_config, config_overrides_string=config_override, override_inherited=override_inherited)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


@command_doc(CLI_COMMANDS_HELP['config']['list'])
@config.command('list', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['config']['list'])
@click.option('-u','--uninherited', 'uninherited', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['uninherited'])
@click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
@click.option('--rendered', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['rendered'])
@click.option('--source', required=False, type=click.Choice(['local', 'remote', 'all']), default='all', show_default=True, callback=config_source_from_string, help=CLI_PARAMETERS_HELP['config']['source'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def config_list(stage, rendered, source, uninherited, filter, query, query_all, format, global_scope, namespace_scope, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if format == 'shell' and (query or query_all):
            Logger.warn("Query customizaion was ignored, becasue output format is 'shell'. Use '-f'/'--format' to change it.")

        defaultQuery = '{Configuration: Configuration[*].{Key: Key, Value: Value}}'
        query = validate_query_argument(query, query_all, defaultQuery)
        
        if filter:
            try:
                re.compile(filter)
            except Exception as e:
                raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ignore_errors=True, scope=scope)
        
        result = AppConfigs.list(uninherited=uninherited, filter=filter, rendered=rendered, source=source)

        if len(result['Configuration']) == 0:
            Logger.warn("No configuration settings found.")

        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



@command_doc(CLI_COMMANDS_HELP['config']['get'])
@config.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['config']['get'])
@click.argument('key', required=True)
@click.option('--revision', metavar='<revision-id', required=False, help=CLI_PARAMETERS_HELP['parameter']['revision'])
@click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
@click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'raw']), default='json', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def config_get(key, stage, global_scope, namespace_scope, revision, query, query_all, format, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        defaultQuery = '{Value: Value}'
        query = validate_query_argument(query, query_all, defaultQuery)

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        result = AppConfigs.get(key, revision)
        output = format_data(result, query, format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)





@command_doc(CLI_COMMANDS_HELP['config']['set'])
@config.command('set', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['config']['set'])
@click.argument('key', required=False)
@click.argument('value', required=False)
# @click.option('--value', 'value_option', metavar='<value>', required=False, help=CLI_PARAMETERS_HELP['config']['value'])
# @click.option('--global', 'global_', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['global'])
@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['config']['input'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def config_set(key, value, stage, input, global_scope, namespace_scope, verbosity, config_override, working_dir):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        if input:
            validate_none_provided([key, value], ["KEY", "VALUE"], ["'-i' / '--input'"])
            try:
                value = yaml.load(input, yaml.SafeLoader)
            # except yaml.YAMLError as e:
            except:
                raise DSOException(CLI_MESSAGES['InvalidFileFormat'].format('yaml'))
        else:
            validate_provided(key, "'KEY'")
            if not value:
                Logger.warn("Null was taken as value.")
            # validate_provided(value, "'VALUE'")
    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()

        AppConfigs.load(working_dir, config_override, stage, ignore_errors=True, scope=scope)

        AppConfigs.set(key, value)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


@command_doc(CLI_COMMANDS_HELP['config']['unset'])
@config.command('unset', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['config']['unset'])
@click.argument('key', required=False)
# @click.option('--global', 'global_', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['global'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def config_unset(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, key_option):

    configScope = None

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, config_override

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()

        AppConfigs.load(working_dir, config_override, stage, ignore_errors=True, scope=scope)

        AppConfigs.unset(key, configScope)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)



def config_service_get(service, stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format):
    
    filter = None
    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, scope, query, filter

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

        defaultQuery = '{Configuration: Configuration[*].{Key: Key, Value: Value, Stage: Stage}}'
        query = validate_query_argument(query, query_all, defaultQuery)
        
        ### use key as filter, no key provided means get all
        filter = f"^{key}$" if key else '*'
        filter = filter.replace('*','.*')
        try:
            re.compile(filter)
        except Exception as e:
            raise DSOException(CLI_MESSAGES['InvalidFilter'].format(repr(e)))


    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage, ignore_errors=True, scope=scope)

        # result = AppConfigs.get(key, configScope)
        result = Configs.list(service=service, uninherited=True, filter=filter)

        if len(result['Configuration']) == 0:
            Logger.warn("No configuration settings found.")

        output = format_data(result, query, format)
        Pager.page(output)


    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)


# @command_doc(CLI_COMMANDS_HELP['parameter']['config']['get'])
# @parameter_config.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['config']['get'])
# @click.argument('key', required=False)
# # # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# # @click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
# @click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
# @click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_parameter_get(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format):

#     config_service_get('parameter', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format)


# @command_doc(CLI_COMMANDS_HELP['secret']['config']['get'])
# @secret_config.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['config']['get'])
# @click.argument('key', required=False)
# # # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# # @click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
# @click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
# @click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_secret_get(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format):

#     config_service_get('secret', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format)


# @command_doc(CLI_COMMANDS_HELP['template']['config']['get'])
# @template_config.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['config']['get'])
# @click.argument('key', required=False)
# # # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# # @click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
# @click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
# @click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_template_get(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format):

#     config_service_get('template', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format)


# @command_doc(CLI_COMMANDS_HELP['package']['config']['get'])
# @package_config.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['package']['config']['get'])
# @click.argument('key', required=False)
# # # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# # @click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
# @click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
# @click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_package_get(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format):

#     config_service_get('package', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format)


# @command_doc(CLI_COMMANDS_HELP['release']['config']['get'])
# @release_config.command('get', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['release']['config']['get'])
# @click.argument('key', required=False)
# # # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# # @click.option('--filter', required=False, metavar='<regex>', help=CLI_PARAMETERS_HELP['common']['filter'])
# @click.option('-a', '--query-all', required=False, is_flag=True, default=False, show_default=True, help=CLI_PARAMETERS_HELP['common']['query_all'])
# @click.option('-q', '--query', metavar='<jmespath>', required=False, help=CLI_PARAMETERS_HELP['common']['query'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_release_get(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format):

#     config_service_get('release', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, query, query_all, format)


# def config_service_set(service, stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format): 
#     settings = []

#     scope = ContextScope.App

#     def validate_command_usage():
#         nonlocal working_dir, scope, value, settings

#         if not working_dir: working_dir = os.getcwd()

#         validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
#         validate_not_all_provided([scope, namespace_scope], ["'--scope'", "'-n' / '--namespace-scope'"])
#         validate_not_all_provided([scope, global_scope], ["'--scope'", "'-g' / '--global-scope'"])
#         scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.from_str(scope or 'App')

#         if inputApp_none_provided([key], ["KEY"], ["'-i' / '--input'"])
# #             settings = read_data(input, 'Configuration', ['Key', 'Value'], format)

#             ### eat possible enclosing (double) quotes when source is file, stdin has already eaten them!
#             if format == 'shell': 
#                 for setting in settings:
#                     if re.match(r'^".*"$', setting['Value']):
#                         setting['Value'] = re.sub(r'^"|"$', '', setting['Value'])
#                     elif re.match(r"^'.*'$", setting['Value']):
#                         setting['Value'] = re.sub(r"^'|'$", '', setting['Value'])

#         ### no input file
#         else:
# #             value = validate_only_one_provided([value, value_option], ["VALUE", "'--value'"])
#             settings.append({'Key': key, 'Value': value})

#     success = []
#     failed = []
#     try:
#         Logger.set_verbosity(verbosity)
#         validate_command_usage()
#         # Contexts.load(working_dir=working_dir)
#         AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)
#         # ctx = ContextService()
#         # ctx.load(working_dir=working_dir, context_name=context_name, namespace=namespace, application=application, stage=stage=scope)
#         # cfg = ConfigService()
#         # cfg.load(working_dir=working_dir, config_overrides_string=config_override, context_service=ctx)

#         if len(settings) == 0:
#             Logger.warn("No configuration setting provided to set.")
#         else:
#             failed = [x['Key'] for x in settings]
#             for setting in settings:
#                 success.append(Configs.set(key=setting['Key'], value=setting['Value'], service=service))
#                 failed.remove(setting['Key'])

#     except DSOException as e:
#         Logger.error(e.message)
#         if verbosity >= logger.EXCEPTION:
#             import traceback
#             traceback.print_exc() ### FIXME to print to logger instead of stdout
#         sys.exit(1)
#     except Exception as e:
#         msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
#         Logger.fatal(msg)
#         if verbosity >= logger.EXCEPTION:
#             import traceback
#             traceback.print_exc() ### FIXME to print to logger instead of stdout
#         sys.exit(2)
#     finally:
#         if settings:
#             failure = []
#             for key in failed:
#                 failure.append({'Key': key})
#             result = {'Success': success, 'Failure': failure}
#             output = format_data(result, '', RESPONSE_FORMAT)
#             Pager.page(output)



# @command_doc(CLI_COMMANDS_HELP['parameter']['config']['set'])
# @parameter_config.command('set', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['config']['set'])
# @click.argument('key', required=False)
# # @click.argument('value', required=False)
# @click.option('--value', 'value_option', metavar='<value>', required=False, help=CLI_PARAMETERS_HELP['config']['value'])
# @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# #@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['config']['input'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_parameter_set(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format):

#     config_service_set('parameter', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format)


# @command_doc(CLI_COMMANDS_HELP['secret']['config']['set'])
# @secret_config.command('set', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['config']['set'])
# @click.argument('key', required=False)
# # @click.argument('value', required=False)
# @click.option('--value', 'value_option', metavar='<value>', required=False, help=CLI_PARAMETERS_HELP['config']['value'])
# @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# #@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['config']['input'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_secret_set(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format):

#     config_service_set('secret', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format)


# @command_doc(CLI_COMMANDS_HELP['template']['config']['set'])
# @template_config.command('set', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['config']['set'])
# @click.argument('key', required=False)
# # @click.argument('value', required=False)
# @click.option('--value', 'value_option', metavar='<value>', required=False, help=CLI_PARAMETERS_HELP['config']['value'])
# @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# #@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['config']['input'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_template_set(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format):

#     config_service_set('template', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format)


# @command_doc(CLI_COMMANDS_HELP['package']['config']['set'])
# @package_config.command('set', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['package']['config']['set'])
# @click.argument('key', required=False)
# # @click.argument('value', required=False)
# @click.option('--value', 'value_option', metavar='<value>', required=False, help=CLI_PARAMETERS_HELP['config']['value'])
# @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# #@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['config']['input'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_package_set(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format):

#     config_service_set('package', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format)


# @command_doc(CLI_COMMANDS_HELP['release']['config']['set'])
# @release_config.command('set', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['release']['config']['set'])
# @click.argument('key', required=False)
# # @click.argument('value', required=False)
# @click.option('--value', 'value_option', metavar='<value>', required=False, help=CLI_PARAMETERS_HELP['config']['value'])
# @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# #@click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['config']['input'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_release_set(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format):

#     config_service_set('release', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, value, value_option, input, format)



# def config_service_unset(service, stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format):

#     settings = []

#     scope = ContextScope.App

#     def validate_command_usage():
#         nonlocal working_dir, scope, settings

#         if not working_dir: working_dir = os.getcwd()

#         validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
#         validate_not_all_provided([scope, namespace_scope], ["'--scope'", "'-n' / '--namespace-scope'"])
#         validate_not_all_provided([scope, global_scope], ["'--scope'", "'-g' / '--global-scope'"])
#         scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.from_str(scope or 'App')

#         if inputApp_none_provided([key], ["KEY"], ["'-i' / '--input'"])
#             settings = read_data(input, 'Configuration', ['Key'], format)

#         ### no input file
#         else:
# #             settings.append({'Key': key})

#     success = []
#     failed = []
#     try:
#         Logger.set_verbosity(verbosity)
#         validate_command_usage()
#         AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

#         if len(settings) == 0:
#             Logger.warn("No configuration setting provided to delete.")
#         else:
#             failed = [x['Key'] for x in settings]
#             for setting in settings:
#                 success.append(Configs.unset(key=setting['Key'], service=service))
#                 failed.remove(setting['Key'])

#     except DSOException as e:
#         Logger.error(e.message)
#         if verbosity >= logger.EXCEPTION:
#             import traceback
#             traceback.print_exc() ### FIXME to print to logger instead of stdout
#         sys.exit(1)
#     except Exception as e:
#         msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
#         Logger.fatal(msg)
#         if verbosity >= logger.EXCEPTION:
#             import traceback
#             traceback.print_exc() ### FIXME to print to logger instead of stdout
#         sys.exit(2)
#     finally:
#         if settings:
#             failure = []
#             for key in failed:
#                 failure.append({'Key': key})
#             result = {'Success': success, 'Failure': failure}
#             output = format_data(result, '', RESPONSE_FORMAT)
#             Pager.page(output)


# @command_doc(CLI_COMMANDS_HELP['parameter']['config']['unset'])
# @parameter_config.command('unset', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['parameter']['config']['unset'])
# @click.argument('key', required=False)
# # @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# # @click.option('--global', 'global_', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['global'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_parameter_unset(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format):

#     config_service_unset('parameter', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format)


# @command_doc(CLI_COMMANDS_HELP['secret']['config']['unset'])
# @secret_config.command('unset', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['secret']['config']['unset'])
# @click.argument('key', required=False)
# # @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# # @click.option('--global', 'global_', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['global'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_secret_unset(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format):

#     config_service_unset('secret', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format)


# @command_doc(CLI_COMMANDS_HELP['template']['config']['unset'])
# @template_config.command('unset', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['template']['config']['unset'])
# @click.argument('key', required=False)
# # @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# # @click.option('--global', 'global_', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['global'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_template_unset(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format):

#     config_service_unset('template', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format)


# @command_doc(CLI_COMMANDS_HELP['package']['config']['unset'])
# @package_config.command('unset', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['package']['config']['unset'])
# @click.argument('key', required=False)
# # @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# # @click.option('--global', 'global_', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['global'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_package_unset(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format):

#     config_service_unset('package', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format)


# @command_doc(CLI_COMMANDS_HELP['release']['config']['unset'])
# @release_config.command('unset', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['release']['config']['unset'])
# @click.argument('key', required=False)
# # @click.option('-i', '--input', metavar='<path>', required=False, type=click.File(encoding='utf-8', mode='r'), help=CLI_PARAMETERS_HELP['common']['input'])
# @click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'csv', 'tsv', 'shell']), default='shell', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
# # @click.option('--global', 'global_', is_flag=True, default=False, help=CLI_PARAMETERS_HELP['config']['global'])
# # # @click.option('--namespace', metavar='<namespace>', required=False, help=CLI_PARAMETERS_HELP['common']['namespace'])
# # @click.option('--application', metavar='<application>', required=False, help=CLI_PARAMETERS_HELP['common']['application'])
# @click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
# # @click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
# @click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
# @click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
# @click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
# @click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
# def config_release_unset(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format):

#     config_service_unset('release', stage, global_scope, namespace_scope, verbosity, config_override, working_dir, key, input, format)




@command_doc(CLI_COMMANDS_HELP['network']['subnet'])
@network.command('subnet', context_settings=default_ctx, short_help=CLI_COMMANDS_SHORT_HELP['network']['subnet'])
@click.option('-m', '--mode', required=False, type=click.Choice(['app', 'full', 'summary']), default='app', show_default=True, help=CLI_PARAMETERS_HELP['network']['subnet_layout_mode'])
@click.option('-f', '--format', required=False, type=click.Choice(['json', 'yaml', 'shell']), default='yaml', show_default=True, help=CLI_PARAMETERS_HELP['common']['format'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-s', '--stage', metavar='<name>[/<number>]', help=CLI_PARAMETERS_HELP['common']['stage'])
@click.option('-g', '--global-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['global_scope'])
@click.option('-n', '--namespace-scope', required=False, is_flag=True, help=CLI_PARAMETERS_HELP['common']['namespace_scope'])
@click.option('--config', 'config_override', metavar='<key>=<value>,...', required=False, default='', show_default=False, help=CLI_PARAMETERS_HELP['common']['config'])
@click.option('-v', '--verbosity', metavar='<number>', required=False, type=RangeParamType(click.INT, minimum=0, maximum=8), default='5', show_default=True, help=CLI_PARAMETERS_HELP['common']['verbosity'])
@click.option('-w','--working-dir', metavar='<path>', type=click.Path(exists=True, file_okay=False), required=False, help=CLI_PARAMETERS_HELP['common']['working_dir'])
def network_subnet(stage, global_scope, namespace_scope, verbosity, config_override, working_dir, mode, format):

    scope = ContextScope.App

    def validate_command_usage():
        nonlocal working_dir, config_override

        if not working_dir: working_dir = os.getcwd()

        validate_not_all_provided([global_scope, namespace_scope], ["-g' / '--global-scope'", "'-n' / '--namespace-scope'"])
        scope = ContextScope.Global if global_scope else ContextScope.Namespace if namespace_scope else ContextScope.App

    try:
        Logger.set_verbosity(verbosity)
        validate_command_usage()
        AppConfigs.load(working_dir, config_override, stage=stage, scope=scope)

        with open(AppConfigs.network('subnetPlan'), 'r') as f:
            subnet_plan = yaml.safe_load(f)

        if mode == 'app':
            result = Networks.layout_subnet_plan(subnet_plan, filters={'plan': AppConfigs.network('plan'), 'selector': AppConfigs.network('selector')}, summary=False)
        else:
            result = Networks.layout_subnet_plan(subnet_plan, summary=(mode == 'summary'))

        output = format_data(result, '', format)
        Pager.page(output)

    except DSOException as e:
        Logger.error(e.message)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(1)
    except Exception as e:
        msg = getattr(e, 'message', getattr(e, 'msg', str(e)))
        Logger.fatal(msg)
        if verbosity >= logger.EXCEPTION:
            import traceback
            traceback.print_exc() ### FIXME to print to logger instead of stdout
        sys.exit(2)

