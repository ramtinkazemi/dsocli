#!/bin/bash
set -e
branch=$(git symbolic-ref --short HEAD)
echo "Git Branch: ${branch}"
if [ ${branch} == "master" ]; then
    env=prod
    url=https://pypi.org/pypi/dsocli/json
    PyPiIndex=pypi
else
    env=dev
    # url=https://test.pypi.org/pypi/dsocli/json
    # PyPiIndex=testpypi
    url=https://pypi.org/pypi/dsocli/json
    PyPiIndex=pypi
fi

echo -e "Compiling PIP dependencies..."
pip-compile --upgrade --output-file requirements.txt requirements/$env.in > /dev/null

currentVersion=$(curl $url 2>/dev/null | jq '.releases| keys[]' -r | sort -V -r | head -1)
echo "Current Version: ${currentVersion}"
cp ~/.pypirc-dsocli ~/.pypirc
printf "Building and publishing the new release to ${PyPiIndex}..."
python -m setup.py publish
newVersion=$(jq '.version' -r src/dsocli/package.json)
echo -e "\nNew Version: ${newVersion}"

tag="v${newVersion}"
# if [ ${env} != 'prod' ]; then
#     tag="${tag}.${env}"
# fi

commit="$1"
if [ ! "${commit}" ]; then
    commit="${tag}"
fi

git add . && git commit -m "${commit}" && git tag "${tag}"
git push origin ${branch} --tags

### install it locally
### testpypi does not resolve depnedencies
if [ "${PyPiIndex}" = "testpypi" ]; then
    pip install -r requirements.txt
fi
pip uninstall dsocli -y

set +e
printf "Waiting for the new release '${newVersion}' to be available on ${PyPiIndex}..."
while true
do
    if [ "${env}" = "prod" ]; then
        pip install dsocli=="${newVersion}" &>/dev/null
    else
        # pip install dsocli=="${newVersion}" --no-cache-dir --index-url https://test.pypi.org/simple/ --no-deps &>/dev/null
        pip install --pre dsocli=="${newVersion}" &>/dev/null
    fi
    ### sleep one second and try again
    if [ $? -ne 0 ]; then
        sleep 1
        printf '.'
    else
        echo -e "\nVersion '${newVersion}' is now installed locally."
        break
    fi
done

