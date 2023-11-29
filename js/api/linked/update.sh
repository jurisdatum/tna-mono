aws lambda update-function-code \
    --function-name api-leg-types \
    --s3-bucket mono-code \
    --s3-key api/linked.zip \
    --no-cli-pager \
    --profile jd-tna
aws lambda update-function-code \
    --function-name api-leg-years \
    --s3-bucket mono-code \
    --s3-key api/linked.zip \
    --no-cli-pager \
    --profile jd-tna
aws lambda update-function-code \
    --function-name api-leg-docs \
    --s3-bucket mono-code \
    --s3-key api/linked.zip \
    --no-cli-pager \
    --profile jd-tna
aws lambda update-function-code \
    --function-name api-leg-search \
    --s3-bucket mono-code \
    --s3-key api/linked.zip \
    --no-cli-pager \
    --profile jd-tna
