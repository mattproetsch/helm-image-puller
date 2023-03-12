#!/bin/bash

set -e

CHART=$1
if [ "$CHART" == "" ]; then
    echo "You need to specify which chart to pull images from"
    exit 1
fi
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
HELM="$(readlink -f "$SCRIPT_DIR"/helm-3.6.3/helm)"
if [ ! -x "$HELM" ]; then
  echo "No helm at $HELM"
  exit 1
fi
CHART_VERSION=$($HELM show chart $CHART | grep '^version:' | awk '{print $2}')
CHART_NAME=$($HELM show chart $CHART | grep '^name:' | awk '{print $2}')

mkdir -p _charts

$HELM pull $CHART
mv $CHART_NAME-$CHART_VERSION.tgz _charts
pushd _charts
tar xzf $CHART_NAME-$CHART_VERSION.tgz
mv $CHART_NAME $CHART_VERSION
mkdir $CHART_NAME
mv $CHART_VERSION $CHART_NAME
cd $CHART_NAME/$CHART_VERSION

IMAGES=$(grep -A 3 image: values.yaml | tr -d '\n' | awk 'BEGIN { FS="--"}; { for (i=0;i<NF; i++) { print $i } }' | sed -Ee 's/.*registry: //g' -e 's/\s+repository: /\//g' -e 's/\s+tag: /:/g' | grep '^docker.io')

popd
mkdir -p _images/$CHART_NAME/$CHART_VERSION
pushd _images/$CHART_NAME/$CHART_VERSION

for im in $IMAGES; do
    echo "Pulling $im..."
    podman pull $im
	echo "Saving $im..."
	podman save -o $(echo $im | tr '/:.' '___').tar $im
done

popd
tar czf $CHART_NAME-$CHART_VERSION-images.tar.gz _images/$CHART_NAME/$CHART_VERSION

rm -rf _charts _images

echo "Saved images as $CHART_NAME-$CHART_VERSION-images.tar.gz"
