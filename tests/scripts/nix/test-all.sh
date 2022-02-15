set -e

default_namespace=test-ns
default_project=test-project
default_application=test-application
default_stage=test-stage
default_working_dir=.

printf "\n\nUSAGE: $0 <namespace [${default_namespace}]> <project [${default_project}]> <application [${default_application}]> <stage [${default_stage}]> <working_dir [${default_working_dir}]>\n\n"

if [ $1 ]; then
    namespace=$1
else
    namespace=${default_namespace}
fi

if [ $2 ]; then
    project=$2
else
    project=${default_project}
fi

if [ $3 ]; then
    application=$3
else
    application=${default_application}
fi

if [ $4 ]; then
    stage=$4
else
    stage=${default_stage}
fi

if [ $5 ]; then
    working_dir=$5
else
    working_dir=${default_working_dir}
fi


./tests/scripts/nix/test-config.sh $namespace $project $application $stage "$working_dir" 

provider=aws/ssm/v1
./tests/scripts/nix/test-parameters.sh $namespace $project $application $stage "$working_dir" $provider 
./tests/scripts/nix/test-secrets.sh $namespace $project $application $stage "$working_dir" $provider 
./tests/scripts/nix/test-templates.sh $namespace $project $application $stage "$working_dir" $provider 

provider=local/v1
./tests/scripts/nix/test-parameters.sh $namespace $project $application $stage "$working_dir" $provider

export global_secret='global.secret'
export global_stage_secret='global.stage_secret'
export project_secret='project.secret'
export project_stage_secret='project.stage_secret'
export app_secret='app.secret'
export app_stage_secret='app.stage_secret'
export overriden_secret='overriden_secret'

provider=shell/v1
./tests/scripts/nix/test-secrets.sh $namespace $project $application $stage "$working_dir" $provider 

provider=local/v1
./tests/scripts/nix/test-templates.sh $namespace $project $application $stage "$working_dir" $provider 
