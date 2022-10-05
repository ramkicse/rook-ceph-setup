

# if u need to increase max pg per osd
```
ceph config set mon mon_max_pg_per_osd 500
```

# Ceph Object Storage Setup

## Step 1 : Create SSL Certificate for Ceph Object deamon usinf Cert manager

```
kubectl apply -f ceph-s3-certificate.yaml
```

This will create SSL certificate secret named ceph-object-store-tls in rook-ceph namespace

## Step 2 : Install CephObjectStore resource

```
kubectl apply -f object-ec.yaml
```


## Step 3 : Install Istio Virtual Service resource for externel access

```
kubectl apply -f ceph-object-storage-virtual-service.yaml
```


## Step 4 : Install Storage Class resource for Object Storage 

```
kubectl apply -f storageclass-bucket.yaml
```


## Step 5 : Install ObjectBucketClaim resource for creating the bucket

```
kubectl apply -f object-bucket-claim.yaml -n ceph
```

### config-map, secret, OBC will part of ceph if no specific name space mentioned

```
export AWS_HOST=$(kubectl -n ceph get cm data-bucket -o jsonpath='{.data.BUCKET_HOST}')
export PORT=$(kubectl -n ceph get cm data-bucket -o jsonpath='{.data.BUCKET_PORT}')
export BUCKET_NAME=$(kubectl -n ceph get cm data-bucket -o jsonpath='{.data.BUCKET_NAME}')
export AWS_ACCESS_KEY_ID=$(kubectl -n ceph get secret data-bucket -o jsonpath='{.data.AWS_ACCESS_KEY_ID}' | base64 --decode)
export AWS_SECRET_ACCESS_KEY=$(kubectl -n ceph get secret data-bucket -o jsonpath='{.data.AWS_SECRET_ACCESS_KEY}' | base64 --decode)
```

print the values 

```
echo $AWS_HOST
echo $PORT
echo $BUCKET_NAME
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
```

## Step 6 : Verify the S3 Object Storage
### Install S5Cmd Command
```
wget https://github.com/peak/s5cmd/releases/download/v2.0.0/s5cmd_2.0.0_Linux-64bit.tar.gz
tar -xzvf s5cmd_2.0.0_Linux-64bit.tar.gz
```



