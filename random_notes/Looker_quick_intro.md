# Looker Quick Introduction

## Resources
The following resources will help you navigate through your need for more advanced specs

* [Looker Documentation](http://www.looker.com/docs):
  Nearly everything of Looker is documented here. I would recommend to bookmark the following links though they are all in the documentation
    1. [Dimension Type LookML](http://www.looker.com/docs/reference/field-reference/dimension-type-reference)
    2. [Measure Type LookML](http://www.looker.com/docs/reference/field-reference/measure-type-reference)
    3. [Derived Tables](http://www.looker.com/docs/data-modeling/learning-lookml/derived-tables)

* [Looker Discourse](https://discourse.looker.com):
  A forum place like the Stack Overflow, where you can ask questions and search for answers to questions. Most of the high quality posts are actually posted by they their Help team

* Looker Online Help:
  Lower left corner of the screen on your account homepage. It will be green if the Looker Help team is online. Otherwise, you can also leave messages so that they can reply when they get back to work.

## Introduction to the terms
When I first started using Looker, I got really confused by their terminologies and the following explains them by SQL correspondences (based on my understanding). The list is not exhaustive. It only includes the ones that can help you quickly start on Looker

Looker terminology | SQL terminology
--- | ---
model (e.g. glow_rs) | the database (e.g. our redshift database)
view | = view OR = table (if it is a persistent derived table in Looker, though the '=' is not a full complete equation)
dimension | the columns in the table
measure | the aggregate functions (e.g. `SUM`, `COUNT` etc)

Other terms | Explanation
--- | ---
Explore | a UI where you can explore the data tables by clicking.
LookML | a language used by looker, which powers/defines the "Explore"
Persistent derived table (PDT) | it is like a table in SQL. The difference is that in SQL, the table is static. It won't change once you create it. The PDT will persist for a length of time (e.g 12 hours) and then be updated by the SQL query used in the LookML view file. You can also set up a trigger to let the PDT update on itself. The table will show up under the "looker_scratch" schema. In the dev mode, all the PDT will persist for 24 hours regardless of your specs definition in the LookML. If you edits the LookML, it will generate another one in the schema. It will have a series of randomly generated letters/numbers in front of the view/table name to distinguish from different versions. The old one generated before you edit the LookML will stay in the "looker_scratch" schema for 24 hours and then be dropped automatically.

## Adding a view
### Create the view directly from the tables in the database
This process is very simple and you can create the view in LookML without writing anything. Simply follow the UI by clicking several buttons.

### Create the view defined by your self
I'll show an example of PDT view below

```
- view: ntf_unilogs
  derived_table:
    sql: |
      SELECT
        ntf_type
        , TO_DATE(TIMESTAMP 'epoch' + server_ts * INTERVAL '1 second', 'YYYY-MM-DD') AS date
        , _subject_user_id AS user_id
        , event_name
        , _context_app AS app
        , open_at
      FROM public.unilogs_views_latest_three_months
      WHERE _context_app IN ('nurture', 'glow')
      AND event_name IN ('android_notification_sent', 'button_click_open_push_notification_with_button','button_click_in_app_notification', 'android_open_notification')
      AND TO_DATE(TIMESTAMP 'epoch' + server_ts * INTERVAL '1 second', 'YYYY-MM-DD') BETWEEN CURRENT_DATE - 37 AND CURRENT_DATE - 1
    sql_trigger_value: SELECT FLOOR((EXTRACT(epoch from GETDATE()) - 60*60*14)/(60*60*24))

  fields:
  - dimension: ntf_type
    type: string
    sql: ${TABLE}.ntf_type

  - dimension: date
    type: date_date
    sql: ${TABLE}.date

  - dimension: user_id
    type: int
    sql: ${TABLE}.user_id

  - dimension: event_name
    type: string
    sql: ${TABLE}.event_name

  - dimension: app
    type: string
    sql: ${TABLE}.app

  - dimension: open_at
    type: string
    sql: ${TABLE}.open_at

```

Here the name of the view is `ntf_unilogs`, it is a derived table, thus we use parameter `derived_table`, then the SQL query that defines the table. The table is derived from `public.unilogs_views_latest_three_months` which is a table in the redshift database, so we can use it directly as we did in writing a SQL query. `sql_trigger_value` defines when the table will be regenerated using the SQL query. Here it is updated daily on the 14th hour of the day (2pm UTC time). More information and examples can be found [here](http://www.looker.com/docs/reference/view-params/sql_trigger_value).

```
- dimension: ntf_type
  type: string
  sql: ${TABLE}.ntf_type
```
The `ntf_type` right after the `dimension` is the name shown in the Looker Explore, You can think of it as the column name you write after `AS` in SQL. The `type` is pretty straightforward and you can find available ones [here](http://www.looker.com/docs/reference/field-reference/dimension-type-reference). The thing after `sql:` defines the actual column it refers to in the table. In this example `${TABLE}` refers to `ntf_unilogs` and the column `ntf_type` in it will be displayed as 'ntf_type' in the "Explore".

A shortcut to generate the LookML above is to go to "SQL Runner" on the left panel of the page and paste the code in it. Remember to apply `LIMIT` to the results and then hit run. If you scroll down till after the results, you will see the LookML for creating a view.

However, it ONLY works if the table is derived from an existing table in the database. If *the table is derived from another persistent derived table*, then you might have to write the view file. To reference another derived table, see the example below:
```
- view: ntf_sent_30d
  derived_table:
    sql: |
      SELECT ntf_type
        , app
        , category
        , COUNT(DISTINCT user_id) AS unq_users_sent_total
        , ROW_NUMBER() OVER (PARTITION BY category, app ORDER BY unq_users_sent_total DESC) AS rank
      FROM ${ntf_unilogs.SQL_TABLE_NAME} AS a
      INNER JOIN
      ${ntf_spreadsheet.SQL_TABLE_NAME} AS b
      ON a.ntf_type = b.type
      GROUP BY 1,2,3
    sql_trigger_value: SELECT FLOOR((EXTRACT(epoch from GETDATE()) - 60*60*14.5)/(60*60*24))



  fields:
  - dimension: ntf_type
    type: string
    sql: ${TABLE}.ntf_type

  - dimension: app
    type: string
    sql: ${TABLE}.app

  - dimension: category
    type: string
    sql: ${TABLE}.category

  - dimension: unq_users_sent_total
    type: int
    sql: ${TABLE}.unq_users_sent_total

  - dimension: rank
    type: int
    sql: ${TABLE}.rank
```
This table relies on two PDTs: `${ntf_unilogs.SQL_TABLE_NAME}` and `${ntf_spreadsheet.SQL_TABLE_NAME}`. `ntf_unilogs` and `ntf_spreadsheet` are PDT created already. `SQL_TABLE_NAME` is a literal string that need to be exactly the same every time you refer to a PDT. More information can be found [here](http://www.looker.com/docs/data-modeling/learning-lookml/derived-tables).
