import sqlite3
from flask import Flask, render_template
import pandas as pd
import models


app = Flask(__name__)
db = sqlite3.connect('db/datacanvas.db')


@app.route('/')
def index():
    df = models.load_cities()
    return render_template('index.html', data=df.to_json())


@app.route('/city2/<name>/')
@app.route('/city2/')
def city2(name='Shanghai'):
    data = [{'chart': 'time_of_day',
    'city': 'Boston',
    'data': [{'time': 0, 'value': 24.6057026256},
    {'time': 2, 'value': 25.1086013401},
    {'time': 4, 'value': 20.7533277868},
    {'time': 6, 'value': 19.7628957319},
    {'time': 8, 'value': 20.6753163885},
    {'time': 10, 'value': 21.8122107727},
    {'time': 12, 'value': 21.7004656496},
    {'time': 14, 'value': 21.6315007934},
    {'time': 16, 'value': 20.0206864119},
    {'time': 18, 'value': 19.8306577216},
    {'time': 20, 'value': 18.2843295551},
    {'time': 22, 'value': 16.8915329451}],
    'name': 'airquality_raw'},
    {'chart': 'month',
    'city': 'Boston',
    'data': [{'time': '2015-02-02', 'value': 20.9231023102}],
    'name': 'airquality_raw'},
    {'chart': 'time_of_day',
    'city': 'Boston',
    'data': [{'time': 0, 'value': 1210.4312546301},
    {'time': 2, 'value': 1186.6457581494},
    {'time': 4, 'value': 1165.6996862144},
    {'time': 6, 'value': 1151.8115355446},
    {'time': 8, 'value': 1168.9290161807},
    {'time': 10, 'value': 1169.8307433642},
    {'time': 12, 'value': 1236.9297997251},
    {'time': 14, 'value': 1349.4289192612},
    {'time': 16, 'value': 1709.9247806554},
    {'time': 18, 'value': 1644.1440076174},
    {'time': 20, 'value': 1772.1255598759},
    {'time': 22, 'value': 1689.9513415426}],
    'name': 'sound'},
    {'chart': 'month',
    'city': 'Boston',
    'data': [{'time': '2015-02-02', 'value': 1371.3210335634}],
    'name': 'sound'}]
    return render_template('city.html', city=name, data=data)


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
      'chart': 'filter',
      'dimension': 'none',
      'date_from': '2015-01-01',
      'date_to': '2015-03-15',
      'time_from': 'T17:00:00.000Z',
      'time_to': 'T19:00:00.000Z',
      'data': [
        {
          'dimension': 'airquality_raw',
          'data': [
            {
              'chart': 'monthly',
              'data': [
                {
                  'date': '2015-01-02',
                  'median': 64
                } ,{
                  'date': '2015-02-02',
                  'median': 44
                } ,{
                  'date': '2015-03-02',
                  'median': 34
                }
              ]
            },{
              'chart': 'time_of_day',
              'data': [
                {
                  'date': '12-2am',
                  'value': 24
                },{
                  'name': '2-4am',
                  'median': 44
                },{
                  'name': '4-6am',
                  'median': 44
                },{
                  'name': '8-10am',
                  'median': 24
                },{
                  'name': '10-12pm',
                  'median': 44
                },{
                  'name': '12-2pm',
                  'median': 44
                }
              ]
            }
          ]
        },{
          'dimension': 'sound',
          'data': [
            {

              'chart': 'monthly',
              'data': [
                {
                  'date': '2015-01-02',
                  'median': 64
                } ,{
                  'date': '2015-02-02',
                  'median': 44
                } ,{
                  'date': '2015-03-02',
                  'median': 34
                }
              ]
            },{
              'chart': 'time_of_day',
              'data': [
                {
                  'name': '12-2am',
                  'median': 24
                },{
                  'name': '2-4am',
                  'median': 44
                },{
                  'name': '4-6am',
                  'median': 44
                },{
                  'name': '8-10am',
                  'median': 24
                },{
                  'name': '10-12pm',
                  'median': 44
                },{
                  'name': '12-2pm',
                  'median': 44
                }
              ]
            }
          ]
        }
      ]
    },
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
          'max': 180,
          'upper': 90,
          'median': 65,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-09',
          'max': 186,
          'upper': 80,
          'median': 72,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-10',
          'max': 250,
          'upper': 90,
          'median': 79,
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
          'median': 40,
          'lower': 32,
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
          'median': 43,
          'lower': 30,
          'min': 20
        },
        {
          'date': '2015-01-18',
          'max': 50,
          'upper': 80,
          'median':55,
          'lower': 24,
          'min': 20
        },
        {
          'date': '2015-01-19',
          'max': 197,
          'upper': 90,
          'median': 50,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-20',
          'max': 220,
          'upper': 180,
          'median': 125,
          'lower': 14,
          'min': 20
        },
        {
          'date': '2015-01-21',
          'max': 250,
          'upper': 90,
          'median': 65,
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

