import sqlite3
import json
from flask import Flask, render_template
import models


app = Flask(__name__)
db = sqlite3.connect('db/datacanvas.db')


@app.route('/')
def index():
    df = models.load_cities()
    return render_template('index.html', data=df.to_json())


@app.route('/city2/<name>/')
@app.route('/city2/')
def city(name='Shanghai'):

    date_from = '2015-01-01'
    date_to = '2015-03-31'
    city_data = []
    df = models.load_cities_data()
    for metric in ['airquality_raw', 'sound']:
        # Build Filter Results
        chart_data = {}
        chart_data['chart'] = 'filter'
        chart_data['dimension'] = 'none'
        chart_data['data'] = []
        data = models.get_metric_data(df, name, metric, date_from, date_to, 'hour')
        chart_data['data'].append(data)
        data = models.get_metric_data(df, name, metric, date_from, date_to, 'YearMonth')
        chart_data['data'].append(data)
        city_data.append(chart_data)

        # Build TimeSeries Results
        chart_data = models.get_ts_data(df, name, metric, date_from, date_to)
        city_data.append(chart_data)
        chart_data = models.get_city_agg_data(df, metric, date_from, date_to)
        city_data.append(chart_data)
    return render_template('city.html', city=name, data=json.dumps(city_data))
