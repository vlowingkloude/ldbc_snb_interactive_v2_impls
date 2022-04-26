#!/bin/bash

set -e
set -o pipefail

cd "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd ..

VALIDATE_PROPERTIES_FILE=${1:-driver/validate.properties}

java -cp target/umbra-0.3.7-SNAPSHOT.jar org.ldbcouncil.driver.Client -P ${VALIDATE_PROPERTIES_FILE}
