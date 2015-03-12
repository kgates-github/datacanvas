import sqlite3
from flask import Flask, render_template


app = Flask(__name__)
db = sqlite3.connect('db/datacanvas.db')


@app.route('/')
def index():
    return render_template('index.html')


# @app.route('/metric/<metric>/')
# def metric_data():
#     sql_query = 'select city f
#     df = pd.read_sql('select () from metrics group by ')
