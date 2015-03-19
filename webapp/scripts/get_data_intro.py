#! /usr/bin/env python

import sys
import datetime
import requests
import pandas as pd


def get_datacanvas(directory, from_dt, before_dt, metric='mean', city=None, sensor=None, resolution='1h'):
    api_params = {}
    api_url = 'http://sensor-api.localdata.com/api/v1/aggregations'
    if sensor:
        api_params['each.sources'] = sensor
        # api_url = 'http://sensor-api.localdata.com/api/v1/sources/' + sensor + '/entries'
    if city:
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


def get_sensors(directory, from_dt, before_dt, metric='mean', city=None, resolution='1h'):
    # cities = ['Shanghai', 'Singapore', 'Bangalore', 'Geneva', 'Rio de Janeiro', 'Boston', 'San Francisco']
    #count = 0
    data_df = None
    city_tz = {}
    city_tz['Shanghai'] = 'Asia/Shanghai'
    city_tz['Singapore'] = 'Asia/Singapore'
    city_tz['Bangalore'] = 'Asia/Kolkata'
    city_tz['Geneva'] = 'Europe/Zurich'
    city_tz['Rio de Janeiro'] = 'America/Sao_Paulo'
    city_tz['Boston'] = 'America/New_York'
    city_tz['San Francisco'] = 'America/Los_Angeles'
    sensors_df = pd.read_csv('../data/sensor_ids.csv')
    cities = sensors_df.City.unique()
    sensor_ids = sensors_df.Id.unique()
    for sensor_id, city in zip(sensor_ids, cities):
        df = get_datacanvas(directory, from_dt, before_dt, metric, sensor=sensor_id, resolution=resolution)
        if df is not None:
            df['city'] = city
            # Convert to local timezone
            df['timestamp'] = pd.to_datetime(df['timestamp'], utc=True)
            df.set_index('timestamp', inplace=True)
            df.index = df.index.tz_localize('UTC').tz_convert(city_tz[city]).tz_localize(None)
            df.reset_index(inplace=True)
            if data_df is None:
                data_df = df
            else:
                data_df = data_df.append(df)
        #count += 1
    data_df.to_csv(directory + 'sensors-' + metric + '-' + from_dt + '-to-' + before_dt + '.csv', index=False)


def get_cities(directory, from_dt, before_dt, metric='mean', city=None, resolution='1h'):
    cities = ['Shanghai', 'Singapore', 'Bangalore', 'Geneva', 'Rio de Janeiro', 'Boston', 'San Francisco']
    cities = [city]
    #count = 0
    cities_df = None
    for city in cities:
        df = get_datacanvas(directory, from_dt, before_dt, metric, city, resolution)
        if cities_df is None:
            cities_df = df
        else:
            cities_df = cities_df.append(df)
        #count += 1
    cities_df.to_csv(directory + 'cities-' + metric + '-' + from_dt + '-to-' + before_dt + '.csv', index=False)

if __name__ == '__main__':
    if len(sys.argv) < 5:
        print "Need arguments from_dt, before_dt, metric, city, resolution"
        print "python get_data_intro.py ../data/ 2015-02-01 2015-02-16 mean all 2h"
        print "python get_data_by_city.py '../data/prototype/' '2015-02-15' '2015-02-16' 'mean' 'Shanghai' '2h'"
        #print "For example: '..data/' '2015-02-01', '2015-02-03', 'mean', 'Shanghai', 1h'"
        sys.exit(0)
    _, directory, from_dt, before_dt, metric, city, resolution  = sys.argv

    get_sensors(directory, from_dt, before_dt, metric, city, resolution)





