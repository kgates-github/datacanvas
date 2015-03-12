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
    df = pd.read_csv('data/cities.csv', parse_dates=['timestamp'])
    df = df[df.city == name]
    df.set_index('timestamp', inplace=True)
    df = df.ix['2015-02-15', :]
    df.reset_index(inplace=True)
    data = df.to_json()
    return render_template('city.html', city=name, data=data)

