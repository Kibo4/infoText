#!/bin/bash
awk '{ print " "$0" "}' $0> $0.qttex
