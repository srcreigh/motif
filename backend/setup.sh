#!/bin/bash

if [[ $OSTYPE == darwin* ]]; then
	if [ ! -f ~/.pydistutils.cfg ]; then
		echo "Applying mac osx pip ~/.pydistutils.cfg workaround..."
		echo $'[install]\nprefix=' > ~/.pydistutils.cfg
	fi
fi

echo "Installing python requirements"
sudo pip install -r requirements.txt -t lib/
