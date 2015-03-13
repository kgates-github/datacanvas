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

