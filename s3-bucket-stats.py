#
# TODO:
#   Arg: regions to report on
#   Report # of objects
#       NumberOfObjects AllStorageTypes
#   Report if public
#   def get_bucket_stats return dict, merge dict for each region, def report
#   Output formats: markdown, json, table

import argparse
import bitmath
import boto3
import datetime
import json

version = '0.0.1'

def get_args(argv=None):
    ### Handle arguments
    parser = argparse.ArgumentParser(description='AWS S3 Bucket size reporter', version=version)
    parser.add_argument('--profile',
        help='AWS profile to use',
    )
    parser.add_argument('--region',
        help='AWS region to use',
    )
    args = parser.parse_args(argv)
    return args

def get_s3_buckets_stats(profile, region):
    # Get stats (object & size) on all buckets in region
    now = datetime.datetime.now()
    session = boto3.Session(profile_name=profile, region_name=region)
    cw = session.client('cloudwatch')
    s3 = session.client('s3')
    # Get a list of all buckets
    #   Get all names: for bucket in s3resource.buckets.all(): print(bucket.name) ?? Is this also by region?
    allbuckets = s3.list_buckets()
    # Iterate through each bucket
    buckets = {}
    for bucket in allbuckets['Buckets']:
        # For each bucket, look up the cooresponding metrics from CloudWatch
        name = bucket['Name']
        buckets[name] = {}
        buckets[name]['region'] = region
        response = cw.get_metric_statistics(Namespace='AWS/S3',
                                            MetricName='NumberOfObjects',
                                            Dimensions=[
                                                {'Name': 'BucketName', 'Value': name},
                                                {'Name': 'StorageType', 'Value': 'AllStorageTypes'}
                                            ],
                                            Statistics=['Average'],
                                            Period=3600,
                                            StartTime=(now-datetime.timedelta(days=1)).isoformat(),
                                            EndTime=now.isoformat()
                                            )
        if len(response["Datapoints"]) > 0:
            buckets[name]['objects'] = int(response["Datapoints"][0]["Average"])
        else:
            buckets[name]['objects'] = 0
        response = cw.get_metric_statistics(Namespace='AWS/S3',
                                            MetricName='BucketSizeBytes',
                                            Dimensions=[
                                                {'Name': 'BucketName', 'Value': name},
                                                {'Name': 'StorageType', 'Value': 'StandardStorage'}
                                            ],
                                            Statistics=['Average'],
                                            Period=3600,
                                            StartTime=(now-datetime.timedelta(days=1)).isoformat(),
                                            EndTime=now.isoformat()
                                            )
        if len(response["Datapoints"]) > 0:
            buckets[name]['size'] = int(response["Datapoints"][0]["Average"])
        else:
            buckets[name]['size'] = 0
    return buckets

def report_json(buckets):
    print(json.dumps(buckets, indent=2))

def report_markdown(buckets):
    # Header
    print('| S3 Bucket | Objects | Size | Region |')
    print('| --- | --- | --- | --- |')
    # Body
    #if human:
    #    format = '| {} | {:,} | {} | {} |'
    #else:
    #    format = '| {} | {} | {} | {} |'
    for bucket in sorted(buckets):
        #if human:
        #    size = bitmath.Byte(bytes=int(buckets[bucket]['size'])).best_prefix(system=bitmath.SI).format("{value:.2f} {unit}")
        #else:
        #    size = buckets[bucket]['size']
        format = '| {} | {:,} | {} | {} |'
        size = bitmath.Byte(bytes=int(buckets[bucket]['size'])).best_prefix(system=bitmath.SI).format("{value:.2f} {unit}")
        print(format.format(bucket, buckets[bucket]['objects'],
            size, buckets[bucket]['region']))

def report_text(buckets):
    # Format as a justified table
    # TODO: determine longest values and format to handle
    # Header
    #print('Bucket'.ljust(45) + 'Size in Bytes'.rjust(25))
    #if human:
    #    format = '{:<45} - {:,} - {:>7} - {:^9}'
    #else:
    #    format = '{} - {} - {} - {}'
    # Body
    for bucket in sorted(buckets):
        #if human:
        #    size = bitmath.Byte(bytes=int(buckets[bucket]['size'])).best_prefix(system=bitmath.SI).format("{value:.2f} {unit}")
        #else:
        #    size = buckets[bucket]['size']
        size = bitmath.Byte(bytes=int(buckets[bucket]['size'])).best_prefix(system=bitmath.SI).format("{value:.2f} {unit}")
        print('{} - {:,} - {} - {}'.format(bucket, buckets[bucket]['objects'], buckets[bucket]['size'], buckets[bucket]['region']))

def report(buckets, output):
    # TODO: support raw & human readable numbers
    # Have functions return text blob, then this can print or write to file
    formats = {
        'json'      : report_json(),
        'markdown'  : report_markdown(),
        'md'        : report_markdown(),
        'text'      : report_text(),
    }
    report = formats.get(output, 'text')(buckets)
    #print(report(buckets))

def main(argv=None):
    args = get_args(argv)
    buckets = get_s3_buckets_stats(args.profile, args.region)
    report(buckets, 'text')
    return

    #    for item in response["Datapoints"]:
    #        print("| {} | ".format(bucket["Name"]) + bitmath.Byte(bytes=int(item["Average"])).best_prefix(system=bitmath.SI).format("{value:.2f} {unit} |"))
            #print("| {} | {:,} |".format(bucket["Name"], int(item["Average"])))
            #print(bucket["Name"].ljust(45) + str("{:,}".format(int(item["Average"]))).rjust(25))
            # Note the use of "{:,}".format.
            # This is a new shorthand method to format output.
            # I just discovered it recently.

if __name__ == '__main__':
  exit(main())
