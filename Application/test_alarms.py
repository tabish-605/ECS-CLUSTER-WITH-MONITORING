#!/usr/bin/env python3
import boto3
import time
import requests
import json
import argparse
from datetime import datetime, timedelta

class ECSAlarmTester:
    def __init__(self, cluster_name, service_name, region='us-east-1'):
        self.cluster_name = cluster_name
        self.service_name = service_name
        self.region = region
        
        self.ecs = boto3.client('ecs', region_name=region)
        self.cloudwatch = boto3.client('cloudwatch', region_name=region)
        self.application_endpoint = None
        
    def set_application_endpoint(self, endpoint):
        """Set the application endpoint URL"""
        self.application_endpoint = endpoint
        
    def test_cpu_reservation_alarm(self, duration_minutes=15):
        """Test CPU reservation high alarm"""
        print("Testing CPU Reservation Alarm...")
        
        # Scale up tasks to increase CPU reservation
        response = self.ecs.describe_services(
            cluster=self.cluster_name,
            services=[self.service_name]
        )
        
        current_count = response['services'][0]['desiredCount']
        target_count = current_count * 3  # Scale up to increase reservation
        
        print(f"Scaling service from {current_count} to {target_count} tasks...")
        self.ecs.update_service(
            cluster=self.cluster_name,
            service=self.service_name,
            desiredCount=target_count
        )
        
        # Wait for scaling
        time.sleep(300)  # Wait 5 minutes for tasks to stabilize
        
        # Trigger CPU spikes in each task
        if self.application_endpoint:
            tasks = self.ecs.list_tasks(
                cluster=self.cluster_name,
                serviceName=self.service_name
            )
            
            for task_arn in tasks['taskArns']:
                try:
                    task = self.ecs.describe_tasks(
                        cluster=self.cluster_name,
                        tasks=[task_arn]
                    )
                    # This would require getting task IPs and making requests
                    print(f"Triggering CPU spike for task {task_arn}")
                except Exception as e:
                    print(f"Error triggering CPU spike: {e}")
        
        print(f"Waiting {duration_minutes} minutes for alarm evaluation...")
        time.sleep(duration_minutes * 60)
        
        return self.check_alarm_state("prod-ecs-cluster-ecs-cpu-reservation-high")
    
    def test_memory_reservation_alarm(self):
        """Test memory reservation high alarm"""
        print("Testing Memory Reservation Alarm...")
        
        if not self.application_endpoint:
            print("No application endpoint set")
            return None
            
        # Trigger memory allocation
        try:
            response = requests.post(f"{self.application_endpoint}/memory-spike/200")
            if response.status_code == 200:
                print("Triggered memory allocation (200MB)")
                
                # Wait for alarm evaluation
                time.sleep(600)  # 10 minutes
                
                return self.check_alarm_state("prod-ecs-cluster-ecs-memory-reservation-high")
        except Exception as e:
            print(f"Error testing memory alarm: {e}")
            
        return None
    
    def test_running_tasks_low_alarm(self):
        """Test running tasks low alarm"""
        print("Testing Running Tasks Low Alarm...")
        
        # Scale down to 0 to trigger alarm
        self.ecs.update_service(
            cluster=self.cluster_name,
            service=self.service_name,
            desiredCount=0
        )
        
        print("Scaled service to 0 tasks")
        time.sleep(120)  # Wait 2 minutes
        
        alarm_state = self.check_alarm_state("prod-api-service-running-tasks-low")
        
        # Scale back up
        self.ecs.update_service(
            cluster=self.cluster_name,
            service=self.service_name,
            desiredCount=2
        )
        
        return alarm_state
    
    def test_task_stopped_spike_alarm(self):
        """Test task stopped spike alarm"""
        print("Testing Task Stopped Spike Alarm...")
        
        if not self.application_endpoint:
            print("No application endpoint set")
            return None
            
        try:
            # Send stop command to tasks
            response = requests.post(f"{self.application_endpoint}/stop-task")
            if response.status_code == 202:
                print("Triggered task stop")
                time.sleep(300)  # Wait 5 minutes
                return self.check_alarm_state("prod-api-service-task-stopped-spike")
        except Exception as e:
            print(f"Error testing task stopped alarm: {e}")
            
        return None
    
    def check_alarm_state(self, alarm_name):
        """Check the current state of an alarm"""
        try:
            response = self.cloudwatch.describe_alarms(
                AlarmNames=[alarm_name]
            )
            
            if response['MetricAlarms']:
                alarm = response['MetricAlarms'][0]
                return {
                    'alarm_name': alarm['AlarmName'],
                    'state': alarm['StateValue'],
                    'reason': alarm.get('StateReason', ''),
                    'timestamp': alarm.get('StateUpdatedTimestamp')
                }
        except Exception as e:
            print(f"Error checking alarm {alarm_name}: {e}")
            
        return None
    
    def run_all_tests(self, application_endpoint=None):
        """Run all alarm tests"""
        if application_endpoint:
            self.set_application_endpoint(application_endpoint)
            
        results = {}
        
        # Test sequence
        tests = [
            ("CPU Reservation", self.test_cpu_reservation_alarm),
            ("Memory Reservation", self.test_memory_reservation_alarm),
            ("Running Tasks Low", self.test_running_tasks_low_alarm),
            ("Task Stopped Spike", self.test_task_stopped_spike_alarm),
        ]
        
        for test_name, test_func in tests:
            print(f"\n{'='*50}")
            print(f"Starting test: {test_name}")
            print(f"{'='*50}")
            
            try:
                result = test_func()
                results[test_name] = result
                print(f"Result: {result}")
            except Exception as e:
                print(f"Test {test_name} failed: {e}")
                results[test_name] = {"error": str(e)}
            
            # Wait between tests
            time.sleep(300)
        
        return results

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Test ECS Alarms')
    parser.add_argument('--cluster', required=True, help='ECS cluster name')
    parser.add_argument('--service', required=True, help='ECS service name')
    parser.add_argument('--endpoint', help='Application endpoint URL')
    parser.add_argument('--region', default='us-east-1', help='AWS region')
    
    args = parser.parse_args()
    
    tester = ECSAlarmTester(args.cluster, args.service, args.region)
    results = tester.run_all_tests(args.endpoint)
    
    print("\n" + "="*50)
    print("TEST SUMMARY")
    print("="*50)
    for test_name, result in results.items():
        print(f"{test_name}: {result}")