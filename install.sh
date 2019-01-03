#!/bin/bash

source_uri="https://github.com/ChrisSwinchatt/BashRC.git"
target_dir=".bash"

pushd "${HOME}"
git clone "${source_uri}" "${target_dir}"
rm ".bashrc"
ln -s "${target_dir}/.bashrc"
popd
