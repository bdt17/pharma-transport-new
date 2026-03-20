#!/usr/bin/env bash
cd ~/pharma-transport-clean
python3 ./git-filter-repo --replace-text replacements.txt --force --refs main
git push --force-with-lease origin main
