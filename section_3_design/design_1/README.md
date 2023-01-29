We will use Amazon Athena Federated Query to connect to the mentioned database. The access to Athena are provided with SAML 2.0 federated users to access the AWS Management Console. 

In short, users will be logged to AWS Management Console with SSO using the company email and assumed a particular IAM role design specifically for their team needs. Also, if the database mentioned are deployed using RDS, we can enable IAM database authentication as well. Based on the description of each team needs, the permissions will be granted at column level. 

In details:

### Logistics
- Read access to all columns in `transactions` table except columns `item_price` and `item_total_price`
- Write access to update the values of column `status` in table n `transactions` table.

### Analytics
- Only read access to the following columns in `members` table:
  - id
  - created_at
  - updated_at
  - deleted_at
  - date_of_birth
  - mobile_number
- Other columns in `members` table contain personal data, so they should not be allowed to access. 

### Sales
- Full read and write access to `items` to item table 
- By default, all tables in the database does not allow DELETE action, instead sales team member will remove old items from the tables by updating the status in column `is_deleted` and `deleted_at`