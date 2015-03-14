import sqlite3
from flask import Flask, render_template
import pandas as pd


app = Flask(__name__)
db = sqlite3.connect('db/datacanvas.db')


@app.route('/')
def index():
    df = pd.read_csv('data/cities.csv')
    return render_template('index.html', data=df.to_json())

@app.route('/city/<name>/')
@app.route('/city/')
def city(name='Shanghai'):
  #df = pd.read_csv('data/cities.csv', parse_dates=['timestamp'])
  #df = df[df.city == name]
  #df.set_index('timestamp', inplace=True)
  #df = df.ix['2015-02-15', :]
  #df.reset_index(inplace=True)
  #data = df.to_json()
  data = [
    {
      'dimension': 'airquality_raw',
      'chart': 'timeseries',
      'date_from': '2015-01-01',
      'date_to': '2015-03-15',
      'time_from': 'T17:00:00.000Z',
      'time_to': 'T19:00:00.000Z',
      'data': [
        {
          'date': '2015-01-01',
          'max': 120,
          'upper': 100,
          'median': 64,
          'lower': 29,
          'min': 20
        },
        {
          'date': '2015-01-02',
          'max': 100,
          'upper': 87,
          'median': 54,
          'lower': 34,
          'min': 20
        },
        {
          'date': '2015-01-03',
          'max': 150,
          'upper': 145,
          'median': 54,
          'lower': 34,
          'min': 20
        },
        {
          'date': '2015-01-04',
          'max': 120,
          'upper': 64,
          'median': 20,
          'lower': 17,
          'min': 20
        },
        {
          'date': '2015-01-05',
          'max': 100,
          'upper': 93,
          'median': 67,
          'lower': 45,
          'min': 20
        },
        {
          'date': '2015-01-06',
          'max': 60,
          'upper': 84,
          'median': 23,
          'lower': 20,
          'min': 20
        },
        {
          'date': '2015-01-07',
          'max': 50,
          'upper': 80,
          'median':25,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-08',
          'max': 250,
          'upper': 90,
          'median': 125,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-09',
          'max': 250,
          'upper': 80,
          'median': 125,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-10',
          'max': 250,
          'upper': 90,
          'median': 125,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-11',
          'max': 150,
          'upper': 100,
          'median': 65,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-12',
          'max': 120,
          'upper': 100,
          'median': 64,
          'lower': 29,
          'min': 20
        },
        {
          'date': '2015-01-13',
          'max': 100,
          'upper': 87,
          'median': 54,
          'lower': 34,
          'min': 20
        },
        {
          'date': '2015-01-14',
          'max': 150,
          'upper': 145,
          'median': 54,
          'lower': 34,
          'min': 20
        },
        {
          'date': '2015-01-15',
          'max': 120,
          'upper': 64,
          'median': 20,
          'lower': 17,
          'min': 20
        },
        {
          'date': '2015-01-16',
          'max': 100,
          'upper': 93,
          'median': 67,
          'lower': 45,
          'min': 20
        },
        {
          'date': '2015-01-17',
          'max': 60,
          'upper': 84,
          'median': 23,
          'lower': 20,
          'min': 20
        },
        {
          'date': '2015-01-18',
          'max': 50,
          'upper': 80,
          'median':25,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-19',
          'max': 250,
          'upper': 90,
          'median': 125,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-20',
          'max': 250,
          'upper': 80,
          'median': 125,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-21',
          'max': 250,
          'upper': 90,
          'median': 125,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-22',
          'max': 150,
          'upper': 100,
          'median': 65,
          'lower': 14,
          'min': 20
        }
      ]
    },
    {
      'dimension': 'airquality_raw',
      'chart': 'ranking',
      'date_from': '2015-01-01',
      'date_to': '2015-03-15',
      'time_from': 'T17:00:00.000Z',
      'time_to': 'T19:00:00.000Z',
      'data': [
        {
          'name': 'Shanghai',
          'upper': 100,
          'median': 64,
          'lower': 29
        },
        {
          'name': 'Singapore',
          'upper': 87,
          'median': 54,
          'lower': 34
        },
        {
          'name': 'Bangalore',
          'upper': 145,
          'median': 54,
          'lower': 34
        },
        {
          'name': 'Geneva',
          'upper': 34,
          'median': 20,
          'lower': 17
        },
        {
          'name': 'Rio de Janeiro',
          'upper': 93,
          'median': 67,
          'lower': 45
        },
        {
          'name': 'Boston',
          'upper': 44,
          'median': 23,
          'lower': 10
        },
        {
          'name': 'San Francisco',
          'upper': 30,
          'median': 25,
          'lower': 14
        }
      ]
    }
  ]
  return render_template('city.html', city=name, data=data)

