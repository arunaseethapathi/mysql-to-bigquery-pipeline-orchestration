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

