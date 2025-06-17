#!/bin/sh

kpt live destroy kpt/metallb-system
kpt live destroy kpt/alpha
kpt live destroy kpt/beta
