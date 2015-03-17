import sqlite3
import json
from flask import Flask, render_template, request, jsonify
import models


app = Flask(__name__)
db = sqlite3.connect('db/datacanvas.db')


@app.route('/')
def index():
    df = models.load_cities()
    return render_template('index.html', data=df.to_json())


def get_data(date_from, date_to, name):
    df = models.load_cities_data()
    city_data = []
    for metric in ['airquality_raw', 'sound', 'dust', 'humidity', 'temperature', 'light', 'noise']:
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
    return city_data


@app.route('/city2/<name>/')
@app.route('/city2/')
def city(name='Shanghai'):
    print request.args
    date_from = '2015-01-01'
    date_to = '2015-03-31'
    data = get_data(date_from, date_to, name)
    return render_template('city.html', city=name, data=json.dumps(data))


@app.route('/update/')
def update():
    print request.args
    name = request.args['city']
    month = request.args['month']
    time_of_day = request.args['time_of_day']
    if month == 'Jan':
        date_from = '2015-01-01'
        date_to = '2015-01-31'
    elif month == 'Feb':
        date_from = '2015-02-01'
        date_to = '2015-02-28'
    else:
        date_from = '2015-03-01'
        date_to = '2015-03-31'
    data = get_data(date_from, date_to, name)
    return jsonify(data=data)
