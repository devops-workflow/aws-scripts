#
# TODO:
#   Arg: regions to report on
#   Report # of objects
#       NumberOfObjects AllStorageTypes
#   Report if public
#   def get_bucket_stats return dict, merge dict for each region, def report
#   Output formats: markdown, json, table

import argparse
import boto3
import datetime

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

def main(argv=None):
    args = get_args(argv)
    now = datetime.datetime.now()
    session = boto3.Session(profile_name=args.profile, region_name=args.region)
    cw = session.client('cloudwatch')
    s3client = session.client('s3')

    # Get a list of all buckets
    #   Get all names: s3client.buckets.all()
    allbuckets = s3client.list_buckets()

    # Header Line for the output going to standard out
    #print('Bucket'.ljust(45) + 'Size in Bytes'.rjust(25))

    # Iterate through each bucket
    for bucket in allbuckets['Buckets']:
        # For each bucket item, look up the cooresponding metrics from CloudWatch
        response = cw.get_metric_statistics(Namespace='AWS/S3',
                                            MetricName='BucketSizeBytes',
                                            Dimensions=[
                                                {'Name': 'BucketName', 'Value': bucket['Name']},
                                                {'Name': 'StorageType', 'Value': 'StandardStorage'}
                                            ],
                                            Statistics=['Average'],
                                            Period=3600,
                                            StartTime=(now-datetime.timedelta(days=1)).isoformat(),
                                            EndTime=now.isoformat()
                                            )
        # The cloudwatch metrics will have the single datapoint, so we just report on it.
        for item in response["Datapoints"]:
            print("| {} | {:,} |".format(bucket["Name"], int(item["Average"])))
            #print(bucket["Name"].ljust(45) + str("{:,}".format(int(item["Average"]))).rjust(25))
            # Note the use of "{:,}".format.
            # This is a new shorthand method to format output.
            # I just discovered it recently.

if __name__ == '__main__':
  exit(main())
