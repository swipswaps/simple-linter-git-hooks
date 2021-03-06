#!/usr/bin/env bash

# Prerequisites:
# - [Git version control system](https://git-scm.com/)
#   Check if it is installed by running:
#
#       bash -c 'command -v git'
#
#   ... if that returns a path, then this script should work fine.
#   Presumably, if you are using git pre-commit hooks, it is safe to say that
#   you probably have git installed.

# This is based upon another script which had the following license:
#
# Copyright (c) 2010, Benjamin C. Meyer <ben@meyerhome.net>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the project nor the
#    names of its contributors may be used to endorse or promote products
#    derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ''AS IS'' AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# shellcheck disable=SC2034
GREP_OPTIONS=""

function test_file {
    file="${1}"

    if [ ! -f "${file}" ] ; then
        return
    fi

    echo "Running whitespace lint..."
    # Set -e before and +e after for _required_ linters (i.e.: that will prevent
    # commit, e.g.: syntax linters).
    # Set +e before and -e after for _optional_ linters (i.e.: that will only
    # output messages upon commit, e.g.: style linters).
    set +e
    if git rev-parse --verify HEAD >/dev/null 2>&1 ; then
        head="HEAD"
    else
        # First commit, use an empty tree
        head="4b825dc642cb6eb9a060e54bf8d69288fbee4904"
    fi
    git diff-index --check --cached "${head}" -- "$file"
    set -e
}

case "${1}" in
    --about )
        echo "Check for introduced trailing whitespace or an indent that uses a space before a tab."
    ;;

    * )
        for file in $(git diff-index --cached --name-only HEAD | grep -v -E '\.(gif|gz|ico|jpeg|jpg|png|phar|exe|svgz|tff)') ; do
            test_file "${file}"
        done
    ;;
esac
