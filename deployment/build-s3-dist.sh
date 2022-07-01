#!/bin/bash
# Check to see if input has been provided:
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Please provide the base source bucket name and version (subfolder) where the lambda code will eventually reside."
    echo "For example: ./build-s3-dist.sh solutions v1.0.0"
    exit 1
fi

[ -e dist ] && rm -r dist
echo "== mkdir -p dist"
mkdir -p dist
ls -lh
#TEMPALTE
echo "==cp video-on-demand-on-aws.yaml dist/video-on-demand-on-aws.template"
cp video-on-demand-on-aws.yaml dist/video-on-demand-on-aws.template
echo "==update CODEBUCKET in template with $1"
replace="s/CODEBUCKET/$1/g"
sed -i -e $replace dist/video-on-demand-on-aws.template
echo "==update CODEVERSION in template with $2"
replace="s/CODEVERSION/$2/g"
sed -i -e $replace dist/video-on-demand-on-aws.template
# remove tmp file for MACs
[ -e dist/video-on-demand-on-aws.template-e ] && rm -r dist/video-on-demand-on-aws.template-e

#SOURCE CODE
echo "== zip and copy lambda deployment pacages to dist/"
cd ../source/

rm -rf bin/*
curl -O https://mediaarea.net/download/binary/mediainfo/20.09/MediaInfo_CLI_20.09_Lambda.zip
unzip MediaInfo_CLI_20.09_Lambda.zip
mv LICENSE bin/
chmod +x ./bin/mediainfo
rm -r MediaInfo_CLI_20.09_Lambda.zip

cd ../source/
echo "------------------------------------------------------------------------------"
echo "Lambda Functions"
echo "------------------------------------------------------------------------------"

for folder in */ ; do
    cd "$folder"

    function_name=${PWD##*/}
    zip_path="$build_dist_dir/$function_name.zip"

    echo "Creating deployment package for $function_name at $zip_path"

    if [ -e "package.json" ]; then
        rm -rf node_modules/
        npm i --production

        zip -q -r9 $zip_path .
    elif [ -e "setup.py" ]; then
        # If you're running this command on macOS and Python3 has been installed using Homebrew, you might see this issue:
        #    DistutilsOptionError: must supply either home or prefix/exec-prefix
        # Please follow the workaround suggested on this StackOverflow answer: https://stackoverflow.com/a/4472877
        python3 setup.py build_pkg --zip-path=$zip_path
    fi

    cd ..
done
cd ../deployment/
echo "== s3 files in dist/:"
ls -lh dist/
