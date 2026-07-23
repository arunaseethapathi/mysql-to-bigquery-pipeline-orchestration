# mysql-to-bigquery-pipeline-orchestration
**#1.Mysql in GCP**
mysql is going to be the source Database.
**Procedure:**
1)searched cloud SQL in GCP products
2)Created cloud SQL mysql instance ==> retailer-mysql-db 
Note:by default instance of enterprise development comes with single location,us-east in development using 4 cpu's,16 GB RAM,32 GB memory
3)added new user in section:
Note:added new user myusr password Mypass@2026 then connections used my local IP for host IP mysql server is created
4)using sql query created 5 tables in mysql in retailer DB
Note: For 1 Day it costed 953 INR rupees.
**#2.cloud storage in GCP**
cloud storage is to have landing data place before gets moved to biguquery.to maintain all type of production data,configdetails and logs.
**Procedure:**
1)searched cloud storage in GCP products
2)Created cloud bucket retailer-datalake-project-270326
3)Created folder config/ to maintain config files,landing/ to maintain bigquery temporary data,temp/ to maintain logs
**#3.Mock API**
In real world scenario we will receive data from API.will receive customer review via api call
**Procedure:**
1)In https://mockapi.io/projects created review endpoint which contains cusotmer id,product id,review rating,review text,review date and generated 77 mock reviews
**#4.Data Proc(pyspark)**
enable mysql to gcs to bigquery connectivity
1)created spark cluster with 2 worker nodes
2)created spark job jupyter notebook by using jupyter lab interface inside GCP
3)establised bigquery,cloud storage and mysql connectivity using spark session
4)Moved old json files of mysql tables into archive to the respective year,mothh folder maitanined separete json file for every table every day
5)created new folder in landing folder from where it will be moved into biqgquery
Note:Bigquery write access & dataproc service account is mandatory
**#6.Composer(Airflow)**
Note:Run this in CLI to enable required API'S to create composer environment
gcloud services enable cloudbuild.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable iamcredentials.googleapis.com
