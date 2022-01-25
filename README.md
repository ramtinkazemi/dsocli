# DSO Tool CLI
This tool assists DevSecOps engineers to perform the following tasks:
- Configuration management
    - Paramaters
    - Secrets
    - Templates
- Package management
- Release management
- Provision resources
- Deploy releases
- Security testing (SAST/DAST)


## Overview

### Applications

### Providers

### Contexts

## Installation

## Configure applications

### Hierarchy structure

## Managing Configurations

### Managing Parameters

#### Adding parameters

The following command may be used to add a parameter to a context, or update a parameter If it is already existing in the context. This will override the parameter in the given context if it is inherited from the parent contexts. Multiple parameters may also be added at once using the ```--input``` option.

```
dso parameter add [KEY] [VALUE] [OPTIONS]
```

```KEY```: The identifier of the parameter to be added. It may also be provided using the ```--key``` option. Depending on the parameter provider, it may have different formats. For ```aws/ssm/v1``` parameter provider, for instance, it must conform to ```^([a-zA-Z][a-zA-Z0-9_.-]*)$``` regex expression. 

```VALUE```: The value for the parameter. If the parameter is already existing in the context, the value will be updated to the new one. It may also be provided using the --value option.

OPTIONS:

```-k, --key <key>```              

The key of the parameter. See ```KEY``` argument for more details.

```-v, --value <value>```

The value for the parameter. See ```VALUE``` argument for more details.

```-s, --stage <name>[/<number>]```

Target a specific stage using the stage identifier, which is combination of a name and an optional number, where name must conform to ```^([a-zA-Z][a-zA-Z0-9]+)$``` regex expression. If no ```/<number>``` is specified, the default environment (```/0```) in the given stage will be targeted.

```-i, --input <path>```

Path to a (local) file defining the parameters. Use ```-``` to read from the shell pipe or stdin. By default, the content of the input file must be of the shell format. Use ```--format``` however to change it if the input file is in other formats such as json or yaml.

```-f, --format [shell|json|yaml|text|csv]```

Specify the data format of the input file. The default is shell. This option can be used only when the ```--input``` option is provided.

```-b, --verbosity <number>```

Specify the logging verbosity, where 0 is for logging critical fatal errors only, 1 also logs error messages, 2 also logs warnings, 3 also logs information messages, 4 also logs debug messages, and finally 5 logs everything. The default log level is 2 (warnings).

```--config <key>=<value>,...```

Comma separated list of key/value pairs to temporarily override the current DSO application configurations. It takes effect only while executing the command and does not have any lasting effect on the DSO application configuration or subsequent command executions.

For example, you may want to change the context from the current application to the global scope to add a parameter to all projects. This can be achieved by using ```--config project=default```. Another example is to temporarily use a different parameter provider, let’s say ```local/v1``` without editing the current DSO application configuration (using  dso config command). To achieve this one can use ```--config parameter.provider.id=local/v1```.

```-w, --working-dir <path>```

Path to a (local) directory where the DSO application configuration resides. The current working directory will be used by default. 

This is useful when the DSO CLI command is executing from another directory than the application root, and allows you to execute the DSO CLI command from any directory without changing the working directory to the application root.

```-h, --help```

Print a quick inline documentation of the command, its arguments, and options.

#### Deleting parameters

The following command may be used to delete a parameter from a context. Note that the inherited parameters cannot be deleted. In other words, the context must be the owner of the parameter or a not found error will be returned. Multiple parameters may also be deleted at once using the ```--input``` option.

```
dso parameter delete [KEY] [OPTIONS]
```

```KEY```: The identifier of the parameter to be deleted. It may also be provided using the ```--key``` option. 

OPTIONS:

```-k, --key <key>```

The key of the parameter. See ```KEY``` argument for more details.

```-s, --stage <name>[/<number>]```

Target a specific stage using the stage identifier, which is combination of a name and an optional number, where name must conform to ```^([a-zA-Z][a-zA-Z0-9]+)$``` regex expression. If no ```/<number>``` is specified, the default environment (```/0```) in the given stage will be targeted.

```-i, --input <path>```

Path to a (local) file defining the parameters. Use ```-``` to read from the shell pipe or stdin. By default, the content of the input file must be of the shell format. Use ```--format``` however to change it if the input file is in other formats such as json or yaml.

```-f, --format [shell|json|yaml|text|csv]```

Specify the data format of the input file. The default is shell. This option can be used only when the ```--input``` option is provided.

```-b, --verbosity <number>```

Specify the logging verbosity, where 0 is for logging critical fatal errors only, 1 also logs error messages, 2 also logs warnings, 3 also logs information messages, 4 also logs debug messages, and finally 5 logs everything. The default log level is 2 (warnings).

```--config <key>=<value>,...```

Comma separated list of key/value pairs to temporarily override the current DSO application configurations. It takes effect only while executing the command and does not have any lasting effect on the DSO application configuration or subsequent command executions.

For example, you may want to change the context from the current application to the global scope to add a parameter to all projects. This can be achieved by using ```--config project=default```. Another example is to temporarily use a different parameter provider, let’s say ```local/v1``` without editing the current DSO application configuration (using  dso config command). To achieve this one can use ```--config parameter.provider.id=local/v1```.

```-w, --working-dir <path>```

Path to a (local) directory where the DSO application configuration resides. The current working directory will be used by default. 

This is useful when the DSO CLI command is executing from another directory than the application root, and allows you to execute the DSO CLI command from any directory without changing the working directory to the application root.

```-h, --help```

Print a quick inline documentation of the command, its arguments, and options.

#### Getting the value of a parameter

In order to get the current value of a parameter in a context, use the following command. The parameter may be inherited from the parent contexts or owned by the given context.

```
dso parameter get [KEY] [OPTIONS]
```

```KEY```: The identifier of the parameter. It may also be provided using the ```--key``` option. 

OPTIONS:

```-k, --key <key>```

The key of the parameter. See ```KEY``` argument for more details.

```-s, --stage <name>[/<number>]```

Target a specific stage using the stage identifier, which is combination of a name and an optional number, where name must conform to ```^([a-zA-Z][a-zA-Z0-9]+)$``` regex expression. If no ```/<number>``` is specified, the default environment (```/0```) in the given stage will be targeted.

```-b, --verbosity <number>```

Specify the logging verbosity, where 0 is for logging critical fatal errors only, 1 also logs error messages, 2 also logs warnings, 3 also logs information messages, 4 also logs debug messages, and finally 5 logs everything. The default log level is 2 (warnings).

```--config <key>=<value>,...```

Comma separated list of key/value pairs to temporarily override the current DSO application configurations. It takes effect only while executing the command and does not have any lasting effect on the DSO application configuration or subsequent command executions.

For example, you may want to change the context from the current application to the global scope to add a parameter to all projects. This can be achieved by using ```--config project=default```. Another example is to temporarily use a different parameter provider, let’s say ```local/v1``` without editing the current DSO application configuration (using  dso config command). To achieve this one can use ```--config parameter.provider.id=local/v1```.

```-w, --working-dir <path>```

Path to a (local) directory where the DSO application configuration resides. The current working directory will be used by default. 

This is useful when the DSO CLI command is executing from another directory than the application root, and allows you to execute the DSO CLI command from any directory without changing the working directory to the application root.

```-h, --help```

Print a quick inline documentation of the command, its arguments, and options.

#### Listing parameters

The following command may be used to list all the parameters that are inherited to or owned/overridden by a context. To limit the list to only parameters that are owned/overridden by the context, use the ```--uninherited``` option. By default, only the parameter keys will be listed. To include also the values, you need to provide the ```--query-values``` option. You may also use the ```--query``` option to customise the output using the JMESPath query language.

```
dso parameter list [OPTIONS]
```

```KEY```: The identifier of the parameter. It may also be provided using the ```--key``` option. 

OPTIONS:

```-k, --key <key>```

The key of the parameter. See ```KEY``` argument for more details.

```-s, --stage <name>[/<number>]```

Target a specific stage using the stage identifier, which is combination of a name and an optional number, where name must conform to ```^([a-zA-Z][a-zA-Z0-9]+)$``` regex expression. If no ```/<number>``` is specified, the default environment (```/0```) in the given stage will be targeted.

```-u, --uninherited```

Select non-inherited parameters only, that are owned or explicitly overridden by the context. 

```-v, --query-values```

Include parameter values in the output.

```-a, --query-all```

Include all the fields returned by the parameter provider in the output.

```-q, --query <jmespath>```

Use the JMESPath query language to customise the output. For example, the ```aws/ssm/v1``` parameter provider returns also the path where parameters reside in the Parameter Store in the Path field. One may use a JMESPath query to include the path along side the parameter keys as follows ```--query 'Parameters[*].{Key: Key, Path: Path}'```. In order to see all the fields available in the output returned by the used parameter provider, you can use the ```--query-all``` option.

Note that the ```--query``` option can be used only if the output format is set to yaml or json using the ```--format``` option. 

```-f, --format [shell|json|yaml|text|csv]```

Specify the data format of the input file. The default is shell. This option can be used only when the ```--input``` option is provided.

```-b, --verbosity <number>```

Specify the logging verbosity, where 0 is for logging critical fatal errors only, 1 also logs error messages, 2 also logs warnings, 3 also logs information messages, 4 also logs debug messages, and finally 5 logs everything. The default log level is 2 (warnings).

```--config <key>=<value>,...```

Comma separated list of key/value pairs to temporarily override the current DSO application configurations. It takes effect only while executing the command and does not have any lasting effect on the DSO application configuration or subsequent command executions.

For example, you may want to change the context from the current application to the global scope to add a parameter to all projects. This can be achieved by using ```--config project=default```. Another example is to temporarily use a different parameter provider, let’s say ```local/v1``` without editing the current DSO application configuration (using  dso config command). To achieve this one can use ```--config parameter.provider.id=local/v1```.

```-w, --working-dir <path>```

Path to a (local) directory where the DSO application configuration resides. The current working directory will be used by default if the option is not provided.

This is useful when the DSO CLI command is executing from another directory than the application root, and allows you to execute the DSO CLI command from any directory without changing the working directory to the application root.

```-h, --help```

Print a quick inline documentation of the command, its arguments, and options.

### Managing Secrets

#### Adding secrets

The following command may be used to add a secret to a context, or update a secret If it is already existing in the context. This will override the secret in the given context if it is inherited from the parent contexts. The value of the secret will be read from the standard input. Multiple secrets may also be added at once using the ```--input``` option.

```
dso secret add [KEY][OPTIONS]
```

```KEY```: The identifier of the secret to be added. It may also be provided using the ```--key``` option. Depending on the secret provider, it may have different formats. For ```aws/ssm/v1``` parameter provider, for instance, it must conform to ^([a-zA-Z][a-zA-Z0-9_.-]*)$ regex expression. 

OPTIONS:

```-k, --key <key>```

The key of the secret. See ```KEY``` argument for more details.

```-s, --stage <name>[/<number>]```

Target a specific stage using the stage identifier, which is combination of a name and an optional number, where name must conform to ```^([a-zA-Z][a-zA-Z0-9]+)$``` regex expression. If no ```/<number>``` is specified, the default environment (```/0```) in the given stage will be targeted.

```-i, --input <path>```

Path to a (local) file defining the secrets. Use ```-``` to read from the shell pipe or stdin. By default, the content of the input file must be of the shell format. Use ```--format``` however to change it if the input file is in other formats such as json or yaml.

```-f, --format [shell|json|yaml|text|csv]```

Specify the data format of the input file. The default is shell. This option can be used only when the ```--input``` option is provided.

```-b, --verbosity <number>```

Specify the logging verbosity, where 0 is for logging critical fatal errors only, 1 also logs error messages, 2 also logs warnings, 3 also logs information messages, 4 also logs debug messages, and finally 5 logs everything. The default log level is 2 (warnings).

```--config <key>=<value>,...```

Comma separated list of key/value pairs to temporarily override the current DSO application configurations. It takes effect only while executing the command and does not have any lasting effect on the DSO application configuration or subsequent command executions.

For example, you may want to change the context from the current application to the global scope to add a secret to all projects. This can be achieved by using ```--config project=default```. Another example is to temporarily use a different secret provider, let’s say ```local/v1``` without editing the current DSO application configuration (using  dso config command). To achieve this one can use ```--config secret.provider.id=local/v1```.

```-w, --working-dir <path>```

Path to a (local) directory where the DSO application configuration resides. The current working directory will be used by default. 

This is useful when the DSO CLI command is executing from another directory than the application root, and allows you to execute the DSO CLI command from any directory without changing the working directory to the application root.

```-h, --help```

Print a quick inline documentation of the command, its arguments, and options.

Deleting secrets

The following command may be used to delete a secret from a context. Note that the inherited secrets cannot be deleted. In other words, the context must be the owner of the secret or a not found error will be returned. Multiple secrets may also be deleted at once using the ```--input``` option.

```
dso secret delete [KEY] [OPTIONS]
```

```KEY```: The identifier of the secret to be deleted. It may also be provided using the ```--key``` option. 

OPTIONS:

```-k, --key <key>```

The key of the secret. See ```KEY``` argument for more details.

```-s, --stage <name>[/<number>]```

Target a specific stage using the stage identifier, which is combination of a name and an optional number, where name must conform to ```^([a-zA-Z][a-zA-Z0-9]+)$``` regex expression. If no ```/<number>``` is specified, the default environment (```/0```) in the given stage will be targeted.

```-i, --input <path>```

Path to a (local) file defining the secrets. Use ```-``` to read from the shell pipe or stdin. By default, the content of the input file must be of the shell format. Use ```--format``` however to change it if the input file is in other formats such as json or yaml.

```-f, --format [shell|json|yaml|text|csv]```

Specify the data format of the input file. The default is shell. This option can be used only when the ```--input``` option is provided.

```-b, --verbosity <number>```

Specify the logging verbosity, where 0 is for logging critical fatal errors only, 1 also logs error messages, 2 also logs warnings, 3 also logs information messages, 4 also logs debug messages, and finally 5 logs everything. The default log level is 2 (warnings).

```--config <key>=<value>,...```

Comma separated list of key/value pairs to temporarily override the current DSO application configurations. It takes effect only while executing the command and does not have any lasting effect on the DSO application configuration or subsequent command executions.

For example, you may want to change the context from the current application to the global scope to add a secret to all projects. This can be achieved by using ```--config project=default```. Another example is to temporarily use a different secret provider, let’s say ```local/v1``` without editing the current DSO application configuration (using  dso config command). To achieve this one can use ```--config secret.provider.id=local/v1```.

```-w, --working-dir <path>```

Path to a (local) directory where the DSO application configuration resides. The current working directory will be used by default. 

This is useful when the DSO CLI command is executing from another directory than the application root, and allows you to execute the DSO CLI command from any directory without changing the working directory to the application root.

```-h, --help```

Print a quick inline documentation of the command, its arguments, and options.

#### Getting the value of a secret

In order to get the current value of a secret in a context, use the following command. The secret may be inherited from the parent contexts or owned by the given context. The value will be automatically decrypted and is returned as plain text.

```
dso secret get [KEY] [OPTIONS]
```

```KEY```: The identifier of the secret. It may also be provided using the ```--key``` option. 

OPTIONS:

```-k, --key <key>```

The key of the secret. See ```KEY``` argument for more details.

```-s, --stage <name>[/<number>]```

Target a specific stage using the stage identifier, which is combination of a name and an optional number, where name must conform to ```^([a-zA-Z][a-zA-Z0-9]+)$``` regex expression. If no ```/<number>``` is specified, the default environment (```/0```) in the given stage will be targeted.

```-b, --verbosity <number>```

Specify the logging verbosity, where 0 is for logging critical fatal errors only, 1 also logs error messages, 2 also logs warnings, 3 also logs information messages, 4 also logs debug messages, and finally 5 logs everything. The default log level is 2 (warnings).

```--config <key>=<value>,...```

Comma separated list of key/value pairs to temporarily override the current DSO application configurations. It takes effect only while executing the command and does not have any lasting effect on the DSO application configuration or subsequent command executions.

For example, you may want to change the context from the current application to the global scope to add a secret to all projects. This can be achieved by using ```--config project=default```. Another example is to temporarily use a different secret provider, let’s say ```local/v1``` without editing the current DSO application configuration (using  dso config command). To achieve this one can use ```--config secret.provider.id=local/v1```.

```-w, --working-dir <path>```

Path to a (local) directory where the DSO application configuration resides. The current working directory will be used by default. 

This is useful when the DSO CLI command is executing from another directory than the application root, and allows you to execute the DSO CLI command from any directory without changing the working directory to the application root.

```-h, --help```

Print a quick inline documentation of the command, its arguments, and options.

#### Listing secrets

The following command may be used to list all the secrets that are inherited to or owned/overridden by a context. To limit the list to only secrets that are owned/overridden by the context, use the ```--uninherited``` option. By default, only the secret keys will be listed. To include also the values, you need to provide the ```--query-values``` option. You may also use the ```--query``` option to customise the output using the JMESPath query language.

dso secret list [OPTIONS]

```KEY```: The identifier of the secret. It may also be provided using the ```--key``` option. 

OPTIONS:

```-k, --key <key>```

The key of the secret. See ```KEY``` argument for more details.

```-s, --stage <name>[/<number>]```

Target a specific stage using the stage identifier, which is combination of a name and an optional number, where name must conform to ```^([a-zA-Z][a-zA-Z0-9]+)$``` regex expression. If no ```/<number>``` is specified, the default environment (```/0```) in the given stage will be targeted.

```-u, --uninherited```

Select non-inherited secrets only, that are owned or explicitly overridden by the context. 

```-d, --decrypt```

Decrypt secret values. If this option is not provided, the encrypted values will be returned.

```-v, --query-values```

Include parameter values in the output.

```-a, --query-all```

Include all the fields returned by the secret provider in the output.

```-q, --query <jmespath>```

Use the JMESPath query language to customise the output. For example, the aws/ssm/v1 secret provider returns also the path where parameters reside in the Parameter Store in the Path field. One may use a JMESPath query to include the path along side the parameter keys as follows ```--query 'Secret[*].{Key: Key, Path: Path}'```. In order to see all the fields available in the output returned by the used parameter provider, you can use the ```--query-all``` option.

Note that the ```--query``` option can be used only if the output format is set to yaml or json using the ```--format``` option. 

```-f, --format [shell|json|yaml|text|csv]```

Specify the data format of the input file. The default is shell. This option can be used only when the ```--input``` option is provided.

```-b, --verbosity <number>```

Specify the logging verbosity, where 0 is for logging critical fatal errors only, 1 also logs error messages, 2 also logs warnings, 3 also logs information messages, 4 also logs debug messages, and finally 5 logs everything. The default log level is 2 (warnings).

```--config <key>=<value>,...```

Comma separated list of key/value pairs to temporarily override the current DSO application configurations. It takes effect only while executing the command and does not have any lasting effect on the DSO application configuration or subsequent command executions.

For example, you may want to change the context from the current application to the global scope to add a secret to all projects. This can be achieved by using ```--config project=default```. Another example is to temporarily use a different secret provider, let’s say ```local/v1``` without editing the current DSO application configuration (using  dso config command). To achieve this one can use ```--config parameter.provider.id=local/v1```.

```-w, --working-dir <path>```

Path to a (local) directory where the DSO application configuration resides. The current working directory will be used by default if the option is not provided.

This is useful when the DSO CLI command is executing from another directory than the application root, and allows you to execute the DSO CLI command from any directory without changing the working directory to the application root.

```-h, --help```

Print a quick inline documentation of the command, its arguments, and options.

Managing templates

Adding templates

Listing templates

Deleting templates

Rendering templates

