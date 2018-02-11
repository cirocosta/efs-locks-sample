
    EFS-LOCKS-SAMPLE

        Sample showing how easy it is to get to the EFS locks quota.


    DEPENDENCIES
        
        Terraform:  to provision EC2 resources
        GCC:        to compile the stress sample
        Docker:     to run a sample mysql instance


    USAGE
    
        1)          provision the AWS infrastructure

                      go to ./infrastructure
                      change `profile` to your aws profile
                      modify the variables to match your setup
                      apply the TF config

        2)          mount the EFS target in your instance

        3)          run the mysql sample with the mysql data
                    volume mounted in the EFS mount point of the
                    host

        4)          run the `create-many-tables.sh` script under `./scripts`

        5)          see mysql failing



    MORE

        Read more at https://ops.tips/blog/limits-aws-efs-nfs-locks/

