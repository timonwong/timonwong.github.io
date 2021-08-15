---
title: "使用 Minio 为阿里云 OSS 提供 AWS S3 兼容 API"
date: 2017-10-17T16:56:23
tags:
  - AWS
  - S3
  - OSS
---

## Summary

不可否认，现在互联网的一个大「单点」就是对象存储 [Amazon S3] 了，大量的应用使用了 S3 的 API，这带来了一个问题，就是应用难于迁移。虽然改客户端这层这个方法，但毕竟侵入性太大，对于一个拥有众多服务的系统来说，实现的成本比较高。

还有另外一种方案，就是提供一个 Gateway，提供与 S3 兼容的 API 供原来的客户端使用；中转请求后打入其它类型的对象存储中（本文为阿里云 [OSS]）。

<!--more-->

## [Minio]

> [Minio] 是一个对象存储服务，基于 Apache License v2.0 协议。它完全兼容亚马逊的S3云储存服务，非常适合于存储很多非结构化的数据，例如图片、视频、日志文件、备份数据和容器/虚拟机镜像等，而一个对象文件可以是任意大小，从几 kb 到最大 5T 不等。

为了快速实现原型，这里使用 [Minio] 为例，因为它提供了一套兼容 [Amazon S3] 的 API，根据 [Minio] 内部的 Gateway 接口，我们是可以自己提供一个 Gateway 实现，用来转发到阿里云 [OSS] 。

注意，这里略过一些性能及功能方面的考量。

## Minio Gateway

翻阅源代码，Minio 已经具有下面几个 Gateway 实现：

- [Amazon S3](https://github.com/minio/minio/blob/3d2d63f71e04404be70fda9653394915f4e7458a/cmd/gateway-s3.go)
- [Google Cloud Storage](https://github.com/minio/minio/blob/3d2d63f71e04404be70fda9653394915f4e7458a/cmd/gateway-gcs.go) 其实本质上是 AWS S3 兼容 API
- [Azure Storage](https://github.com/minio/minio/blob/3d2d63f71e04404be70fda9653394915f4e7458a/cmd/gateway-azure.go)
- [Backblaze B2](https://github.com/minio/minio/blob/3d2d63f71e04404be70fda9653394915f4e7458a/cmd/gateway-b2.go)

以上 Gateway 的最终用户使用文档可以在这里看到: https://github.com/minio/minio/tree/3d2d63f71e04404be70fda9653394915f4e7458a/docs/gateway

### Interface

一个 Gateway 需要实现 GatewayLayer 接口，如下所示:

```go
// ObjectLayer implements primitives for object API layer.
type ObjectLayer interface {
    // Storage operations.
    Shutdown() error
    StorageInfo() StorageInfo

    // Bucket operations.
    MakeBucketWithLocation(bucket string, location string) error
    GetBucketInfo(bucket string) (bucketInfo BucketInfo, err error)
    ListBuckets() (buckets []BucketInfo, err error)
    DeleteBucket(bucket string) error
    ListObjects(bucket, prefix, marker, delimiter string, maxKeys int) (result ListObjectsInfo, err error)

    // Object operations.
    GetObject(bucket, object string, startOffset int64, length int64, writer io.Writer) (err error)
    GetObjectInfo(bucket, object string) (objInfo ObjectInfo, err error)
    PutObject(bucket, object string, data *HashReader, metadata map[string]string) (objInfo ObjectInfo, err error)
    CopyObject(srcBucket, srcObject, destBucket, destObject string, metadata map[string]string) (objInfo ObjectInfo, err error)
    DeleteObject(bucket, object string) error

    // Multipart operations.
    ListMultipartUploads(bucket, prefix, keyMarker, uploadIDMarker, delimiter string, maxUploads int) (result ListMultipartsInfo, err error)
    NewMultipartUpload(bucket, object string, metadata map[string]string) (uploadID string, err error)
    CopyObjectPart(srcBucket, srcObject, destBucket, destObject string, uploadID string, partID int, startOffset int64, length int64) (info PartInfo, err error)
    PutObjectPart(bucket, object, uploadID string, partID int, data *HashReader) (info PartInfo, err error)
    ListObjectParts(bucket, object, uploadID string, partNumberMarker int, maxParts int) (result ListPartsInfo, err error)
    AbortMultipartUpload(bucket, object, uploadID string) error
    CompleteMultipartUpload(bucket, object, uploadID string, uploadedParts []completePart) (objInfo ObjectInfo, err error)

    // Healing operations.
    HealBucket(bucket string) error
    ListBucketsHeal() (buckets []BucketInfo, err error)
    HealObject(bucket, object string) (int, int, error)
    ListObjectsHeal(bucket, prefix, marker, delimiter string, maxKeys int) (ListObjectsInfo, error)
    ListUploadsHeal(bucket, prefix, marker, uploadIDMarker,
        delimiter string, maxUploads int) (ListMultipartsInfo, error)
}

// GatewayLayer - Interface to implement gateway mode.
type GatewayLayer interface {
    ObjectLayer

    AnonGetObject(bucket, object string, startOffset int64, length int64, writer io.Writer) (err error)
    AnonGetObjectInfo(bucket, object string) (objInfo ObjectInfo, err error)

    AnonPutObject(bucket string, object string, size int64, data io.Reader, metadata map[string]string, sha256sum string) (ObjectInfo, error)

    SetBucketPolicies(string, policy.BucketAccessPolicy) error
    GetBucketPolicies(string) (policy.BucketAccessPolicy, error)
    DeleteBucketPolicies(string) error
    AnonListObjects(bucket, prefix, marker, delimiter string, maxKeys int) (result ListObjectsInfo, err error)
    AnonListObjectsV2(bucket, prefix, continuationToken, delimiter string, maxKeys int, fetchOwner bool, startAfter string) (result ListObjectsV2Info, err error)
    ListObjectsV2(bucket, prefix, continuationToken, delimiter string, maxKeys int, fetchOwner bool, startAfter string) (result ListObjectsV2Info, err error)
    AnonGetBucketInfo(bucket string) (bucketInfo BucketInfo, err error)
}
```

对于部分不支持的操作，可以使用留桩代码返回 `NotImplemented` 错误，官方提供了一个 [`gatewayUnsupported`](https://github.com/minio/minio/blob/3d2d63f71e04404be70fda9653394915f4e7458a/cmd/gateway-unsupported.go) 可供参考。

### Implementation

将上面的内容搞清楚后，剩下的工作就只是将相应的代码套进上面的接口了，没有太多技术含量。

阿里云 OSS API 风格有很重的 AWS S3 痕迹，所以这个「翻译」工作很没有挑战性😜。

**EDIT(2017-10-23)** Pull Request 请看 [minio/minio#5103](https://github.com/minio/minio/pull/5103)

**EDIT(2017-12-19)** Minio 上游已经合并了 PR，以后就能直接使用了 :)

想吐槽的是 minio 里面结构比较乱，加一个 Gateway 要改很多文件，所以又提交了一个 PR: [minio/minio#5111](https://github.com/minio/minio/pull/5111)

[OSS]: https://www.aliyun.com/product/oss
[Amazon S3]: https://aws.amazon.com/s3
[Minio]: https://www.minio.io
