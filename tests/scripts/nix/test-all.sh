set -e

default_namespace=test-ns
default_application=test-app
default_stage=test-stage
default_working_dir=.

printf "\n\nUSAGE: $0 <namespace [${default_namespace}]> <application [${default_application}]> <stage [${default_stage}]> <working_dir [${default_working_dir}]>\n\n"

if [ $1 ]; then
    namespace=$1
else
    namespace=${default_namespace}
fi

if [ $2 ]; then
    application=$2
else
    application=${default_application}
fi

if [ $3 ]; then
    stage=$3
else
    stage=${default_stage}
fi

if [ $4 ]; then
    working_dir=$4
else
    working_dir=${default_working_dir}
fi


./tests/scripts/nix/test-config.sh $namespace $application $stage "$working_dir" 

provider=aws/ssm/v1
./tests/scripts/nix/test-parameters.sh $namespace $application $stage "$working_dir" $provider 
./tests/scripts/nix/test-secrets.sh $namespace $application $stage "$working_dir" $provider 
./tests/scripts/nix/test-templates.sh $namespace $application $stage "$working_dir" $provider 

provider=local/v1
./tests/scripts/nix/test-parameters.sh $namespace $application $stage "$working_dir" $provider
./tests/scripts/nix/test-secrets.sh $namespace $application $stage "$working_dir" $provider 
./tests/scripts/nix/test-templates.sh $namespace $application $stage "$working_dir" $provider 

provider=shell/v1

export global_parameter='global parameter'
export global_stage_parameter='global stage parameter'
export namespace_parameter='namespace parameter'
export namespace_stage_parameter='namespace stage parameter'
export app_parameter='app parameter'
export app_stage_parameter='app stage parameter'
export global_overriden_parameter='global overriden parameter'
export global_stage_overriden_parameter='global stage overriden parameter'
export namespace_overriden_parameter='namespace overriden parameter'
export namespace_stage_overriden_parameter='namespace stage overriden parameter'
export app_overriden_parameter='app overriden parameter'
export app_stage_overriden_parameter='app stage overriden parameter'
export app_stage2_overriden_parameter='app stage2 overriden parameter'

./tests/scripts/nix/test-parameters.sh $namespace $application $stage "$working_dir" $provider

export global_secret='global secret'
export global_stage_secret='global stage secret'
export namespace_secret='namespace secret'
export namespace_stage_secret='namespace stage secret'
export app_secret='app secret'
export app_stage_secret='app stage secret'
export global_overriden_secret='global overriden secret'
export global_stage_overriden_secret='global stage overriden secret'
export namespace_overriden_secret='namespace overriden secret'
export namespace_stage_overriden_secret='namespace stage overriden secret'
export app_overriden_secret='app overriden secret'
export app_stage_overriden_secret='app stage overriden secret'
export app_stage2_overriden_secret='app stage2 overriden secret'

./tests/scripts/nix/test-secrets.sh $namespace $application $stage "$working_dir" $provider 

provider=local/v1
./tests/scripts/nix/test-templates.sh $namespace $application $stage "$working_dir" $provider
