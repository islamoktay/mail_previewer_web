#!/bin/bash
set -e

fvm flutter clean

fvm flutter pub get

fvm flutter build web

firebase deploy --only hosting