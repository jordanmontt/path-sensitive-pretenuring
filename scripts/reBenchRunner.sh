#!/bin/bash

# Set the HOME variable explicitly
export HOME=`pwd`

# Pass all arguments to Pharo
exec "$@"