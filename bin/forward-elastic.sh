#!/bin/sh
kubectl port-forward svc/elasticsearch-elasticsearch-coordinating-only 9200:9200
