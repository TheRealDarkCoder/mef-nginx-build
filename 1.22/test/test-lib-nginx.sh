#!/bin/bash
#
# Functions for tests for the nginx image in OpenShift.
#
# IMAGE_NAME specifies a name of the candidate image used for testing.
# The image has to be available before this script is executed.
#

THISDIR=$(dirname ${BASH_SOURCE[0]})

source "${THISDIR}/test-lib.sh"
source "${THISDIR}/test-lib-openshift.sh"

function test_nginx_integration() {
  ct_os_test_s2i_app "${IMAGE_NAME}" \
                     "https://github.com/sclorg/nginx-container.git" \
                     "examples/${VERSION}/test-app" \
                     "Test NGINX passed"
}

# Check the imagestream
function test_nginx_imagestream() {
  ct_os_test_image_stream_s2i "${THISDIR}/imagestreams/nginx-${OS%[0-9]*}.json" "${IMAGE_NAME}" \
                              "https://github.com/sclorg/nginx-container.git" \
                              "examples/${VERSION}/test-app" \
                              "Test NGINX passed"
}

function test_nginx_local_example() {
  # test local app
  ct_os_test_s2i_app ${IMAGE_NAME} "${THISDIR}/test-app" . 'Test NGINX passed'
}

function test_nginx_remote_example() {
  # TODO: branch should be changed to master, once code in example app
  # stabilizes on with referencing latest version
  BRANCH_TO_TEST="master"
  # test remote example app
  ct_os_test_s2i_app "${IMAGE_NAME}" \
                     "https://github.com/sclorg/nginx-ex.git" \
                     . \
                     'Welcome to your static nginx application on OpenShift'
}

function test_nginx_template_from_example_app() {
  BRANCH_TO_TEST="master"
  # test template from the example app
  ct_os_test_template_app "${IMAGE_NAME}" \
                          "https://raw.githubusercontent.com/phracek/nginx-ex/${BRANCH_TO_TEST}/openshift/templates/nginx.json" \
                          nginx \
                          'Welcome to your static nginx application on OpenShift' \
                          8080 http 200 "-p SOURCE_REPOSITORY_REF=master -p NGINX_VERSION=${VERSION} -p NAME=nginx-testing"

}

function test_latest_imagestreams() {
  local result=1
  # Switch to root directory of a container
  echo "Testing the latest version in imagestreams"
  pushd "${THISDIR}/../.." >/dev/null || return 1
  ct_check_latest_imagestreams
  result=$?
  popd >/dev/null || return 1
  return $result
}
# vim: set tabstop=2:shiftwidth=2:expandtab:
