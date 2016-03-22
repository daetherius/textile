# Textile Company

### Setup

* Clone repo into your local machine

* Run `bundle install`

* Create the database with `rake db:create db:migrate`

* Run `rake db:seed` to create the admin account. **Optional:** Use the `SAMPLE_DATA` env variable to indicate number of employee fake accounts to generate.
  Example: `rake db:seed SAMPLE_DATA=50`

* Provide the `GMAIL_USERNAME` and `GMAIL_PASSWORD` env vars to enable email notifications through GMail.
* Start the server with `rails s` and visit http://localhost:3000

* Login using the default admin credentials
  * **E-mail** `admin@textile.com`
  * **Password**: `chang3m3` (all auto-generated accounts have this password)


### Assumptions

Employee accounts can be **created only by the administrator** and need to be **confirmed** before use.

When creating a new account, the system will generate a friendly **temporary password** which will be delivered in the same e-mail confirmation notification. Also, it'll include a link where the employee can set their own password.

Users can login, edit their profile information, request a password recovery and **on a specific day** of month, can **review** their check-in and check-out **history** of the last **2 weeks**.

**Delayed arrivals** and **Early departures** are shown in **yellow** in the user's history.
**Missed days** are shown in **red**.

Most of the time/date related rules are defined in the `/lib/time_rules.rb` file for easy customization.

The **admin user** can use the **filters** in their dashboard to perform some queries on the user list. It's divided in **two** main filters.

* By **barcode**
* By **conditions**:
  * **With**
  First, the admin must to select a **user history criteria** to search upon, like:
    * **At least one**
    * **More than one**
    * **None**

    Then, the **type of records** to look for.

    * **Chek-in (on time)**
    * **Chek-out (on time)**
    * **Delayed arrivals**
    * **Early departures**
    * **Attended days** (includes On-time and Delayed arrivals)
    * **Missed days**

  * **Between dates** to narrow the query to a range of dates. These are **optional**.

