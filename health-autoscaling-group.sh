#!/bin/bash
#
# Check the health of the instances in an autoscaling group
#
asg=$1
asg='pcs_asg20171111034055611400000003'
#for ((I=1; I <= 10; I++))
for I in {1..16}; do
  sleep 10
  asgState=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${asg})
  instancesHealth=$(echo "${asgState}" | jq -r .AutoScalingGroups[].Instances[].HealthStatus)
  instancesState=$(echo "${asgState}" | jq -r .AutoScalingGroups[].Instances[].LifecycleState)
  instanceIds=$(echo "${asgState}" | jq -r .AutoScalingGroups[].Instances[].InstanceId)

  echo "Instance Ids: ${instanceIds}"
  echo -e "\tHealths: ${instancesHealth}"
  # Good: Healthy
  # Bad: Unhealthy
  echo -e "\tStates: ${instancesState}"
  # Good: InService
  # Bad: Terminating, Pending,
  if [ "$(echo "${instancesHealth}"| sort -u)" = "Healthy" -a \
       "$(echo "${instancesState}"| sort -u)" = "InService" ]; then
    echo -e "\tASG State: GOOD"
    stateLast='GOOD'
  else
    echo -e "\tASG State: BAD"
    stateBad='true'
    stateLast='BAD'
  fi
  # TODO: instances age. Would need amazon time (accurate NTP)
  instancesDesc=$(aws ec2 describe-instances --instance-ids ${instanceIds})
  launchTimes=$(echo "${instancesDesc}" | jq -r .Reservations[].Instances[].LaunchTime)
  # 2017-11-15T18:11:34.000Z
  echo -e "\tInstance Launch Times: ${launchTimes}"
done
echo -e "\nLast state: ${stateLast}, State ever bad: ${stateBad}"
