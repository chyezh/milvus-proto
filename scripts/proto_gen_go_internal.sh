#!/usr/bin/env bash

# Licensed to the LF AI & Data foundation under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# internal proto is moved from milvus at commit: aceb972963ad8ef56583c64dd6662328f3bbc1d9

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
ROOT_DIR="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

PROTO_DIR=$ROOT_DIR/proto/internal
PROTO_OUT_DIR=$ROOT_DIR/go-api/internalpb
API_PROTO_DIR=$ROOT_DIR/proto/api
GOOGLE_PROTO_DIR=$ROOT_DIR/cmake-build/protobuf/protobuf-src/src/
PROTOC_BIN=$ROOT_DIR/cmake-build/protobuf/protobuf-build/protoc

INSTALL_PATH="$1"

PROGRAM=$(basename "$0")
GOPATH=$(go env GOPATH)

if [ -z $GOPATH ]; then
    printf "Error: the environment variable GOPATH is not set, please set it before running %s\n" $PROGRAM > /dev/stderr
    exit 1
fi

export PATH=${INSTALL_PATH}:${GOPATH}/bin:$PATH

echo "using protoc-gen-go: $(which protoc-gen-go)"
echo "using protoc-gen-go-grpc: $(which protoc-gen-go-grpc)"

# official go code ship with the crate, so we need to generate it manually.
pushd ${PROTO_DIR}

mkdir -p ${PROTO_OUT_DIR}/etcdpb
mkdir -p ${PROTO_OUT_DIR}/indexcgopb
mkdir -p ${PROTO_OUT_DIR}/cgopb
mkdir -p ${PROTO_OUT_DIR}/internalpb
mkdir -p ${PROTO_OUT_DIR}/rootcoordpb
mkdir -p ${PROTO_OUT_DIR}/segcorepb
mkdir -p ${PROTO_OUT_DIR}/clusteringpb
mkdir -p ${PROTO_OUT_DIR}/proxypb
mkdir -p ${PROTO_OUT_DIR}/indexpb
mkdir -p ${PROTO_OUT_DIR}/datapb
mkdir -p ${PROTO_OUT_DIR}/querypb
mkdir -p ${PROTO_OUT_DIR}/planpb
mkdir -p ${PROTO_OUT_DIR}/streamingpb
mkdir -p ${PROTO_OUT_DIR}/messagespb
mkdir -p ${PROTO_OUT_DIR}/workerpb

protoc_opt="${PROTOC_BIN} --proto_path=${API_PROTO_DIR} --proto_path=${GOOGLE_PROTO_DIR} --proto_path=."

${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/etcdpb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/etcdpb etcd_meta.proto || { echo 'generate etcd_meta.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/indexcgopb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/indexcgopb index_cgo_msg.proto || { echo 'generate index_cgo_msg failed '; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/cgopb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/cgopb cgo_msg.proto || { echo 'generate cgo_msg failed '; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/rootcoordpb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/rootcoordpb root_coord.proto || { echo 'generate root_coord.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/internalpb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/internalpb internal.proto || { echo 'generate internal.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/proxypb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/proxypb proxy.proto|| { echo 'generate proxy.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/indexpb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/indexpb index_coord.proto|| { echo 'generate index_coord.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/datapb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/datapb data_coord.proto|| { echo 'generate data_coord.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/querypb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/querypb query_coord.proto|| { echo 'generate query_coord.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/planpb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/planpb plan.proto|| { echo 'generate plan.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/segcorepb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/segcorepb segcore.proto|| { echo 'generate segcore.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/clusteringpb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/clusteringpb clustering.proto|| { echo 'generate clustering.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/workerpb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/workerpb worker.proto|| { echo 'generate worker.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/messagespb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/messagespb messages.proto || { echo 'generate messagespb.proto failed'; exit 1; }
${protoc_opt} --go_out=paths=source_relative:${PROTO_OUT_DIR}/streamingpb --go-grpc_out=require_unimplemented_servers=false,paths=source_relative:${PROTO_OUT_DIR}/streamingpb streaming.proto || { echo 'generate streamingpb.proto failed'; exit 1; }
popd
