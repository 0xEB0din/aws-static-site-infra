# aws-static-site-infra
Infrastructure as code for deploying a static website on AWS S3, accelerated by CloudFront CDN and CI/CD pipeline with Jenkins

1. **Introduction**:
   - Objective: End-to-end service deployments via automation using GitHub, Jenkins, Terraform, and AWS.

2. **Degree of Automation Achieved**:
   - Jenkins-Terraform integration: Replicable and consistent infrastructure deployment.

3. **Areas of Improvement**:
   - Robust error handling in Jenkins.
   - Modularised Terraform main file.

4. **Benefits**:
   - **Consistency**: Avoids manual errors and assures uniform deployments.
   - **Cost-Efficient**: 
     - We're avoiding EC2 instances and using ALB's redirect rules to direct traffic to S3's static website URL.
     - This method involves no additional running costs besides the ALB. S3 costs will be minimal for a small static site.
     - Automated deployments mean no excess and lingering resources, ensuring you only pay for what you use.
     - Infrastructure as Code (IaC) allows for replicable deployments, reducing overhead and administrative costs.

5. **Conclusion**:
   - Automation, especially in cloud deployments, is not just about efficiency but significant cost savings. Our setup epitomizes this principle by ensuring swift, error-free, and cost-effective infrastructure management.