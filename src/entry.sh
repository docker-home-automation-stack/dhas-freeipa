#!/bin/bash
set -e

if [ -s /data/ipa.csr ]; then
  while [ true ]; do
    if [ -s /certs/ipa.csr.signed ]; then
      break
    elif [ -s /certs/ipa.csr.error ]; then
      echo "CSR signing error:"
      cat /certs/ipa.csr.error.txt
      exit 10
    elif [ -f /certs/ipa.csr.processing ]; then
      echo "CA is processing CSR: $(cat /certs/ipa.csr.processing) ..."
    else
      echo "Waiting for CA to sign CSR ..."
      cp -n /data/ipa.csr /certs/ipa.csr
    fi
    sleep 10
  done
fi

if [ ! -s /etc/ipa/ca.crt ] && [ -s /data/ipa.csr ] && [ -s /certs/ipa.crt ]; then
  echo "Detected externally signed CA certificate - continuing local CA configuration"
  exec $@ --external-cert-file=/certs/ipa.crt --external-cert-file=/certs/ca.crt
else
  exec $@
fi

exit $?
