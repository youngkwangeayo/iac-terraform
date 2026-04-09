for domain in dev-sm.nextpay.co.kr dev-sm-api.nextpay.co.kr dev-sm-cms.nextpay.co.kr dev-signage-hub.nextpay.co.kr; do
  echo "=== $domain ==="
  nslookup $domain 8.8.8.8 2>&1 | grep -E "Name|Address|CNAME|answer|error|NXDOMAIN"
  echo ""
  echo "=== $domain ==="
  nslookup $domain 168.126.63.1 2>&1 | grep -E "Name|Address|CNAME|answer|error|NXDOMAIN"
  echo ""
  echo "=== $domain ==="
  nslookup $domain 219.250.36.130 2>&1 | grep -E "Name|Address|CNAME|answer|error|NXDOMAIN"
  echo ""
done


