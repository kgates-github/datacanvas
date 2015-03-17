#! /usr/bin/env python

import sys
import datetime
import requests
import pandas as pd


def get_datacanvas(directory, from_dt, before_dt, metric='mean', city=None, resolution='1h'):
    api_url = 'http://sensor-api.localdata.com/api/v1/aggregations'
    print api_url

    api_params = {}
    api_params['over.city'] = city
    api_params['op'] = metric
    api_params['fields'] = 'temperature,light,airquality_raw,sound,humidity,dust'
    api_params['resolution'] = resolution
    api_params['from'] = from_dt
    api_params['before'] = before_dt
    resp = requests.get(api_url, params=api_params)
    raw_json = resp.json()
    raw_json = raw_json['data']
    return pd.DataFrame(raw_json)
    #.to_csv(directory + city + '.csv', index=False)


def get_cities(directory, from_dt, before_dt, metric='mean', city=None, resolution='1h'):
    cities = ['Shanghai', 'Singapore', 'Bangalore', 'Geneva', 'Rio de Janeiro', 'Boston', 'San Francisco']
    #count = 0
    cities_df = None
    for city in cities:
        df = get_datacanvas(directory, from_dt, before_dt, metric, city, resolution)
        if cities_df is None:
            cities_df = df
        else:
            cities_df = cities_df.append(df)
        #count += 1
    cities_df.to_csv('cities.csv', index=False)

if __name__ == '__main__':
    if len(sys.argv) < 5:
        print "Need arguments from_dt, before_dt, metric, city, resolution"
        print "python get_data_intro.py ../data/ 2015-02-01 2015-02-16 mean all 2h"
        print "python get_data_by_city.py '../data/prototype/' '2015-02-15' '2015-02-16' 'mean' 'Shanghai' '2h'"
        #print "For example: '..data/' '2015-02-01', '2015-02-03', 'mean', 'Shanghai', 1h'"
        sys.exit(0)
    _, directory, from_dt, before_dt, metric, city, resolution  = sys.argv

    get_cities(directory, from_dt, before_dt, metric, city, resolution)





