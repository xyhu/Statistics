import os

from jinja2 import Environment, PackageLoader
import psycopg2

def render_template(template, package_name, template_folder, **context):
    env = Environment(loader=PackageLoader(package_name, template_folder))
    return env.get_template(template).render(**context)

def exec_sql_redshift(sql_query, conn):
    CURSOR = conn.cursor()
    CURSOR.execute(sql_query)
    conn.commit()
    CURSOR.close()


def create_tables_redshift(package_name, template_folder, conn, template, dry_run=False, **context):
    """Create tables in ther redshift"""
    sql_completed = render_template(template, package_name, template_folder, **context)
    # LOG.info('Create tables in redshift: \n %s', sql_completed)
    if dry_run:
        print sql_completed
    if not dry_run:
        exec_sql_redshift(sql_completed, conn)


REDSHIFT_DB = os.environ['REDSHIFT_DB']
REDSHIFT_HOST = os.environ['REDSHIFT_HOST']
REDSHIFT_HOST_HDD = os.environ['REDSHIFT_HOST_HDD']
REDSHIFT_PORT = os.environ['REDSHIFT_PORT']
REDSHIFT_USER = os.environ['REDSHIFT_USER']
REDSHIFT_PASSWORD = os.environ['REDSHIFT_PASSWORD']


DSN = 'dbname={db} host={host} port={port} user={user} password={pwd}'.format(
        db=REDSHIFT_DB, host=REDSHIFT_HOST, port=REDSHIFT_PORT, user=REDSHIFT_USER, pwd=REDSHIFT_PASSWORD
    )

DSN_HDD = 'dbname={db} host={host} port={port} user={user} password={pwd}'.format(
        db=REDSHIFT_DB, host=REDSHIFT_HOST_HDD, port=REDSHIFT_PORT, user=REDSHIFT_USER, pwd=REDSHIFT_PASSWORD
    )
