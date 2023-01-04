aws cloudformation update-stack \
  --stack-name mono \
  --template-body file://mono.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --profile jd-tna
